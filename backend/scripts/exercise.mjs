import { mkdirSync, readFileSync, writeFileSync, existsSync, chmodSync } from 'node:fs';
import { resolve } from 'node:path';

// Deliberately small M10 exercise. Credentials only go into an ignored 0600 file.
const base = process.env.API_BASE || 'http://127.0.0.1:3100';
const parsedBase = new URL(base);
if (parsedBase.protocol !== 'https:' && !['127.0.0.1', 'localhost'].includes(parsedBase.hostname)) {
  throw new Error('Use HTTPS outside localhost.');
}
const path = resolve('.local/m10-identities.json');
const check = (condition, message) => { if (!condition) throw new Error(message); };
const request = async (method, path, credential, body) => {
  const headers = {};
  if (credential) headers.Authorization = `Bearer ${credential}`;
  if (body) headers['Content-Type'] = 'application/json';
  const response = await fetch(new URL(path, base), { method, headers, body: body && JSON.stringify(body) });
  return { status: response.status, data: await response.json() };
};
const noPrivateFields = value => {
  const text = JSON.stringify(value);
  check(!/credential|quest|ownerPlayerId|kind|history/i.test(text), 'Private fields in public response.');
};
const zeroProfile = profile => {
  check(profile.overallPoints === 0 && profile.completedMatches === 0 && profile.wins === 0
    && profile.losses === 0 && profile.draws === 0 && profile.lieCount === 0
    && profile.honestCount === 0 && profile.winStreak === 0 && profile.winRate === null
    && profile.lyingWinPercentage === null && profile.honestWinPercentage === null,
  'Expected a genuine zero-history profile with N/A percentages.');
};

try {
  if (process.argv[2] === 'resume') {
    const saved = JSON.parse(readFileSync(path, 'utf8'));
    check(saved.base === base, 'Exercise origin changed.');
    const later = await request('POST', '/api/anonymous', saved.a.credential, { mode: 'resume' });
    check(later.status === 200 && later.data.playerId === saved.a.playerId
      && later.data.profile.displayName === 'M10 Player', 'Persistent resume failed.');
    noPrivateFields(later.data);
    console.log('PASS: same saved player/name resumed after API restart (no credential output).');
    process.exit(0);
  }
  check(!existsSync(path), 'Exercise identities already exist. Use resume; do not accidentally create more accounts.');
  mkdirSync('.local', { recursive: true, mode: 0o700 });
  const a = await request('POST', '/api/anonymous', null, { mode: 'create' });
  check(a.status === 201, `Create unavailable: HTTP ${a.status}; ${a.data.error?.code || 'unknown'}.`);
  const saved = { base, a: a.data };
  // Save A immediately so a later failure cannot lose its issued credential.
  writeFileSync(path, JSON.stringify(saved), { flag: 'wx', mode: 0o600 });
  const b = await request('POST', '/api/anonymous', null, { mode: 'create' });
  check(b.status === 201, 'Second identity creation failed.');
  saved.b = b.data;
  writeFileSync(path, JSON.stringify(saved));
  chmodSync(path, 0o600);
  check(a.data.playerId !== b.data.playerId && a.data.credential !== b.data.credential, 'Identities must differ.');
  zeroProfile(a.data.profile); zeroProfile(b.data.profile);
  const named = await request('PATCH', '/api/profile', a.data.credential, { displayName: 'M10 Player' });
  check(named.status === 200 && named.data.profile.displayName === 'M10 Player', 'Normal name save failed.');
  noPrivateFields(named.data);
  const resumed = await request('POST', '/api/anonymous', a.data.credential, { mode: 'resume' });
  check(resumed.status === 200 && resumed.data.playerId === a.data.playerId && resumed.data.profile.displayName === 'M10 Player', 'Resume failed.');
  check(resumed.data.needsDisplayName === false, 'Saved name still requested.');
  noPrivateFields(resumed.data);
  const missing = await request('POST', '/api/anonymous', null, { mode: 'resume' });
  check(missing.status === 401 && missing.data.error.code === 'CREDENTIAL_MISSING', 'Missing credential not distinguished.');
  const invalid = await request('POST', '/api/anonymous', 'anon_' + 'A'.repeat(43), { mode: 'resume' });
  check(invalid.status === 401 && invalid.data.error.code === 'CREDENTIAL_INVALID', 'Invalid credential not distinguished.');
  const deniedRead = await request('GET', `/api/records?playerId=${a.data.playerId}`, b.data.credential);
  check(deniedRead.status === 403, 'Cross-owner history read accepted.');
  const deniedWrite = await request('PATCH', '/api/profile', b.data.credential, { playerId: a.data.playerId, displayName: 'Other' });
  check(deniedWrite.status === 400, 'Supplied playerId authorized write.');
  const publicA = await request('GET', `/api/player?playerId=${a.data.playerId}`, b.data.credential);
  check(publicA.status === 200 && publicA.data.profile.displayName === 'M10 Player', 'Public profile changed or inaccessible.');
  noPrivateFields(publicA.data); zeroProfile(publicA.data.profile);
  const second = await request('POST', '/api/anonymous', b.data.credential, { mode: 'resume' });
  check(second.status === 200 && second.data.profile.displayName === null, 'Second profile unexpectedly changed.');
  for (const identity of [a.data, b.data]) {
    const own = await request('GET', '/api/records?limit=1', identity.credential);
    check(own.status === 200 && own.data.records.length === 0 && own.data.nextCursor === null, 'Expected empty eligible owner records.');
  }
  for (const metric of ['overallPoints', 'winRate', 'lieCount', 'honestCount']) {
    const first = await request('GET', `/api/leaderboard?metric=${metric}&limit=1`);
    check(first.status === 200 && first.data.entries.length === 1 && first.data.nextCursor, 'Expected leaderboard pagination from two real profiles.');
    noPrivateFields(first.data);
    const next = await request('GET', `/api/leaderboard?metric=${metric}&limit=1&cursor=${first.data.nextCursor}`);
    check(next.status === 200 && next.data.entries.length === 1
      && next.data.entries[0].playerId !== first.data.entries[0].playerId, 'Leaderboard next page failed.');
    noPrivateFields(next.data);
  }
  console.log('PASS: two actual API identities, name/resume, zero/N/A, missing/invalid auth, owner isolation, public projections, empty records, all four leaderboard pages.');
  console.log('Restart API, then run: npm run exercise -- resume');
} catch (error) {
  // Only our own sanitized check messages reach output; never fetch/driver diagnostics.
  if (error?.message?.startsWith('Create unavailable:')) console.error(error.message);
  else console.error('M10 exercise incomplete. Review local setup/API status; credentials remain in .local only.');
  process.exitCode = 1;
}
