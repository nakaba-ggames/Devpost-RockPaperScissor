import { createServer } from 'node:http';
import { pathToFileURL } from 'node:url';
import anonymous from '../api/anonymous.js';
import profile from '../api/profile.js';
import player from '../api/player.js';
import records from '../api/records.js';
import leaderboard from '../api/leaderboard.js';
import { createM11Handlers } from '../src/m11-api.js';
import { requireSettlementConfiguration } from '../src/settlement-rules.js';
import { requireSettlementIndexes } from '../src/settlement-store.js';
import { closeDatabase } from '../src/db.js';
import type { ServerClock } from '../src/server-time.js';

// This harness is not a Vercel entry point or upload input. Its clock is an
// in-process function only. There is no clock-setting HTTP endpoint/header.
export async function startM11Exercise(revision: string, allowEmber: boolean, clock?: ServerClock) {
  requireSettlementConfiguration(revision);
  await requireSettlementIndexes();
  const handlers = createM11Handlers({ isolatedExerciseRevision: revision, allowExerciseEmber: allowEmber, clock });
  const routes = new Map([
    ['/api/anonymous', anonymous], ['/api/profile', profile], ['/api/player', player],
    ['/api/records', records], ['/api/leaderboard', leaderboard],
    ['/api/menu', handlers.menu], ['/api/quests', handlers.quests],
    ['/api/matches/register', handlers.register], ['/api/matches/join', handlers.join],
    ['/api/matches/finalize', handlers.finalize], ['/api/matches/result', handlers.result]
  ]);
  const server = createServer((req, res) => {
    const handler = routes.get(new URL(req.url ?? '/', 'http://localhost').pathname);
    if (handler) { void handler(req, res); return; }
    res.writeHead(404, { 'Content-Type': 'application/json', 'Cache-Control': 'no-store' });
    res.end(JSON.stringify({ error: { code: 'NOT_FOUND', message: 'API route not found.', retryable: false } }));
  });
  await new Promise<void>((resolve, reject) => {
    server.once('error', reject);
    server.listen(0, '127.0.0.1', resolve);
  });
  const address = server.address();
  if (!address || typeof address === 'string') throw new Error('Local adapter address unavailable.');
  return {
    base: `http://127.0.0.1:${address.port}`,
    close: () => new Promise<void>((resolve, reject) => server.close(error => {
      if (error) reject(error); else resolve();
    }))
  };
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  const revision = process.argv[2];
  if (!revision) throw new Error('After creator agreement, supply the exact approved exercise revision as the first argument.');
  try {
    const server = await startM11Exercise(revision, process.argv[3] === '--approved-ember');
    console.log(`Isolated nonproduction M11 API at ${server.base}; real server clock; productionReady remains false.`);
    for (const signal of ['SIGINT', 'SIGTERM'] as const) {
      process.on(signal, () => { void server.close().then(closeDatabase).then(() => process.exit(0)); });
    }
  } catch {
    console.error('M11 adapter unavailable. Check agreement, explicit index setup and protected service configuration. Private details withheld.');
    await closeDatabase();
    process.exitCode = 1;
  }
}
