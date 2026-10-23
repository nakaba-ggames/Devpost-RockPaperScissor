import { createServer } from 'node:http';
import anonymous from '../api/anonymous.js';
import profile from '../api/profile.js';
import player from '../api/player.js';
import leaderboard from '../api/leaderboard.js';
import records from '../api/records.js';
import { closeDatabase } from '../src/db.js';
import { rulesRevision } from '../src/config.js';
import { m11Handlers } from '../src/m11-api.js';

const routes = new Map([
  ['/api/anonymous', anonymous], ['/api/profile', profile], ['/api/player', player],
  ['/api/leaderboard', leaderboard], ['/api/records', records],
  ['/api/menu', m11Handlers.menu], ['/api/quests', m11Handlers.quests],
  ['/api/matches/register', m11Handlers.register], ['/api/matches/join', m11Handlers.join],
  ['/api/matches/finalize', m11Handlers.finalize], ['/api/matches/result', m11Handlers.result]
]);
const port = Number(process.env.PORT ?? 3100);
const server = createServer((req, res) => {
  const handler = routes.get(new URL(req.url ?? '/', 'http://localhost').pathname);
  if (handler) { void handler(req, res); return; }
  res.writeHead(404, { 'Content-Type': 'application/json', 'Cache-Control': 'no-store' });
  res.end(JSON.stringify({ error: { code: 'NOT_FOUND', message: 'API route not found.', retryable: false } }));
});
server.listen(port, '127.0.0.1', () => {
  console.log(`Local Node API: http://127.0.0.1:${port}; Node ${process.version}`);
  console.log(`Configuration ${rulesRevision}; no static game files served.`);
});
for (const signal of ['SIGINT', 'SIGTERM'] as const) {
  process.on(signal, () => { server.close(() => { void closeDatabase().then(() => process.exit(0)); }); });
}
