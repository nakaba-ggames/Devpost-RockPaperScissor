import { randomUUID } from 'node:crypto';
import { existsSync, mkdirSync, readFileSync, writeFileSync } from 'node:fs';

// Small creator walk-through only. Broader scoped M11 verification is separate.
const mode = process.argv[2];
const base = process.env.API_BASE;
if (!base || new URL(base).hostname !== '127.0.0.1') throw new Error('Set API_BASE to the isolated localhost adapter URL.');
const path = '.local/m11-tryout.json';
function save(value, first = false) {
  let flag = 'w';
  if (first) flag = 'wx';
  writeFileSync(path, JSON.stringify(value, null, 2), { mode: 0o600, flag });
}
async function request(method, path, credential, body) {
  const headers = {};
  if (credential) headers.Authorization = `Bearer ${credential}`;
  if (body) headers['Content-Type'] = 'application/json';
  const response = await fetch(new URL(path, base), { method, headers, body: body && JSON.stringify(body) });
  const data = await response.json();
  if (!response.ok) throw new Error(`API HTTP ${response.status}: ${data.error?.code ?? 'unknown'}`);
  return data;
}
function check(condition, message) { if (!condition) throw new Error(message); }
try {
  if (mode === 'prepare') {
    check(!existsSync(path), 'Try-out identities exist. Preserve the file and use play/inspect/replay; never recreate them.');
    mkdirSync('.local', { recursive: true, mode: 0o700 });
    const a = await request('POST', '/api/anonymous', undefined, { mode: 'create' });
    const saved = { a, matchNonce: randomUUID() };
    save(saved, true); // Persist each issued credential immediately, privately.
    saved.b = await request('POST', '/api/anonymous', undefined, { mode: 'create' });
    save(saved);
    for (const [key, name] of [['a', 'M11 Try A'], ['b', 'M11 Try B']]) {
      await request('PATCH', '/api/profile', saved[key].credential, { displayName: name });
      await request('POST', '/api/menu', saved[key].credential, { requestId: randomUUID() });
    }
    console.log('Prepared two dedicated real zero-history API identities. Credentials saved privately; no M10 identities changed.');
  } else {
    const saved = JSON.parse(readFileSync(path, 'utf8'));
    check(saved.a && saved.b, 'Preparation incomplete. Preserve the file and investigate; do not recreate accounts.');
    const a = saved.a;
    const b = saved.b;
    if (mode === 'play') {
      const registration = await request('POST', '/api/matches/register', a.credential, {
        matchNonce: saved.matchNonce, peerPlayerId: b.playerId, fallbackRequested: false, rulesRevision: a.rulesRevision
      });
      await request('POST', '/api/matches/join', b.credential, { matchId: registration.matchId, matchNonce: saved.matchNonce });
      if (!saved.finalization) {
        const phases = ['option', 'identity_claim', 'switch_claim', 'final_choice'];
        function actor(actorId, initialCard, finalCard, offset) {
          let switchClaim = 'keep';
          if (initialCard !== finalCard) switchClaim = 'switch';
          return { actorId, startingOrder: ['Rock', 'Paper', 'Scissor'], initialCard, identityClaim: initialCard, switchClaim, finalCard,
            events: phases.map((phase, index) => ({ phase, sequence: index * 2 + offset, revision: 0,
              elapsedMsec: index * 15_000 + 1_000, value: [initialCard, initialCard, switchClaim, finalCard][index] })) };
        }
        saved.finalization = { matchId: registration.matchId, rulesRevision: a.rulesRevision, departures: [],
          roundLog: { matchId: registration.matchId, rulesRevision: a.rulesRevision, condition: 'none',
            phases: phases.map((phase, index) => ({ phase, started: index * 15_000, deadline: (index + 1) * 15_000, locked: (index + 1) * 15_000 })),
            actors: [actor(a.playerId, 'Scissor', 'Rock', 1), actor(b.playerId, 'Scissor', 'Scissor', 2)] } };
        save(saved);
      }
      const result = await request('POST', '/api/matches/finalize', a.credential, saved.finalization);
      saved.receiptId = result.savedResult.receiptId;
      save(saved);
      console.log(`Committed controlled history: match ${result.matchId}; receipt ${saved.receiptId}.`);
    } else if (mode === 'replay') {
      check(saved.finalization && saved.receiptId, 'Run play first.');
      async function snapshot() {
        const profile = await request('GET', `/api/player?playerId=${a.playerId}`);
        const records = await request('GET', '/api/records', a.credential);
        const quests = await request('GET', '/api/quests', a.credential);
        return JSON.stringify({ profile, records, daily: quests.dailyHistory, weekly: quests.weeklyQuests });
      }
      const before = await snapshot();
      const result = await request('POST', '/api/matches/finalize', a.credential, saved.finalization);
      check(result.savedResult.receiptId === saved.receiptId, 'Replay receipt changed.');
      check(before === await snapshot(), 'Replay changed profile, records or quest counters.');
      console.log('Same committed receipt; profile, records and quest progress unchanged through API reads. Storage-level evidence is a separate verification step.');
    } else if (mode !== 'inspect') throw new Error('Use prepare, play, inspect or replay.');
    if (saved.finalization) {
      const result = await request('GET', `/api/matches/result?matchId=${saved.finalization.matchId}`, a.credential);
      const { profile } = await request('GET', `/api/player?playerId=${a.playerId}`);
      const { records } = await request('GET', '/api/records', a.credential);
      const quests = await request('GET', '/api/quests', a.credential);
      console.log(JSON.stringify({ matchId: result.matchId, receiptId: result.savedResult?.receiptId,
        overallPoints: profile.overallPoints, completedMatches: profile.completedMatches, wins: profile.wins,
        recordCount: records.length, daily: quests.dailyHistory.map(row => ({ title: row.definition.title, counter: row.counter, status: row.status })),
        weekly: quests.weeklyQuests.map(row => ({ title: row.definition.title, counter: row.counter })) }, null, 2));
    }
  }
} catch (error) {
  if (error instanceof Error && error.message.startsWith('API HTTP')) console.error(error.message);
  else console.error('M11 try-out incomplete. Preserve .local/m11-tryout.json and investigate without recreating identities.');
  process.exitCode = 1;
}
