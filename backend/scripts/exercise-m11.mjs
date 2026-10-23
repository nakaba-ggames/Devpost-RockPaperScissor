import { randomUUID } from 'node:crypto';
import { existsSync, mkdirSync, readFileSync, writeFileSync } from 'node:fs';
import { startM11Exercise } from '../dist/scripts/m11-local-server.js';
import { rulesRevision } from '../dist/src/config.js';
import { database, mongoClient, closeDatabase } from '../dist/src/db.js';

// Only the creator-authorized basic M11 checks. Controlled histories travel
// through real HTTP handlers and real Atlas transactions; no live-game claim.
const privatePath = '.local/m11-contract.json';
const evidencePath = '.local/m11-evidence.json';
mkdirSync('.local', { recursive: true, mode: 0o700 });
let saved = { identities: {}, cases: {}, menuIds: {}, baselines: {}, completed: {} };
if (existsSync(privatePath)) saved = JSON.parse(readFileSync(privatePath, 'utf8'));
function save() { writeFileSync(privatePath, JSON.stringify(saved), { mode: 0o600 }); }
let evidence = {};
if (existsSync(evidencePath)) evidence = JSON.parse(readFileSync(evidencePath, 'utf8'));
let time = new Date('2026-10-23T03:00:00Z');
let api;
let db;
let committedTransactions = 0;
let activeStep = 'startup';
function check(value, message) { if (!value) throw new Error(message); }
function record(name, value) {
  evidence[name] = value;
  writeFileSync(evidencePath, JSON.stringify(evidence, null, 2), { mode: 0o600 });
  console.log(`PASS ${name}: ${JSON.stringify(value)}`);
}
async function step(name, action) {
  activeStep = name;
  if (saved.completed[name]) { console.log(`Previously verified ${name}; preserved evidence.`); return; }
  await action();
  saved.completed[name] = true;
  save();
}
async function request(method, path, identity, body, expected = 200) {
  const headers = {};
  if (identity) headers.Authorization = `Bearer ${identity.credential}`;
  if (body) headers['Content-Type'] = 'application/json';
  const response = await fetch(new URL(path, api.base), { method, headers, body: body && JSON.stringify(body) });
  const data = await response.json();
  check(response.status === expected, `${method} ${path.split('?')[0]} expected ${expected}, received ${response.status}/${data.error?.code ?? 'unknown'}`);
  return data;
}
async function identity(key) {
  if (!saved.identities[key]) {
    const created = await request('POST', '/api/anonymous', undefined, { mode: 'create' }, 201);
    saved.identities[key] = { playerId: created.playerId, credential: created.credential };
    save(); // Never lose or replace an issued credential after partial failure.
  }
  const player = saved.identities[key];
  await request('PATCH', '/api/profile', player, { displayName: `M11 ${key}` });
  return player;
}
async function menu(key, player) {
  if (!saved.menuIds[key]) { saved.menuIds[key] = randomUUID(); save(); }
  return request('POST', '/api/menu', player, { requestId: saved.menuIds[key] });
}
async function profile(player) {
  return db.collection('players').findOne({ playerId: player.playerId }, { projection: { _id: 0, credentialHash: 0 } });
}
async function baseline(key, player) {
  if (!saved.baselines[key]) { saved.baselines[key] = await profile(player); save(); }
  return saved.baselines[key];
}
function historyActor(actorId, initialCard, finalCard, identityClaim, switchClaim, offset) {
  const phases = ['option', 'identity_claim', 'switch_claim', 'final_choice'];
  return { actorId, startingOrder: ['Rock', 'Paper', 'Scissor'], initialCard, finalCard, identityClaim, switchClaim,
    events: phases.map((phase, index) => ({ phase, sequence: index * 2 + offset, revision: 0,
      elapsedMsec: index * 15_000 + 1_000, value: [initialCard, identityClaim, switchClaim, finalCard][index] })) };
}
const honestRock = ['Rock', 'Rock', 'Rock', 'keep'];
const honestScissor = ['Scissor', 'Scissor', 'Scissor', 'keep'];
async function registration(key, a, b, fallback = false) {
  if (!saved.cases[key]) { saved.cases[key] = { nonce: randomUUID() }; save(); }
  const item = saved.cases[key];
  const body = { matchNonce: item.nonce, fallbackRequested: fallback, rulesRevision };
  if (b) body.peerPlayerId = b.playerId;
  const registered = await request('POST', '/api/matches/register', a, body);
  item.matchId = registered.matchId;
  item.bindings = registered.participantBindings;
  save();
  if (b) await request('POST', '/api/matches/join', b, { matchId: item.matchId, matchNonce: item.nonce });
  return item;
}
async function finalize(key, a, b, condition, left, right, departures = [], fallback = false) {
  const item = await registration(key, a, b, fallback);
  if (!item.body) {
    let otherId = b?.playerId;
    if (fallback) otherId = item.bindings.find(row => row.playerId !== a.playerId).playerId;
    const phases = ['option', 'identity_claim', 'switch_claim', 'final_choice'];
    item.body = { matchId: item.matchId, rulesRevision, departures,
      roundLog: { matchId: item.matchId, rulesRevision, condition,
        phases: phases.map((phase, index) => ({ phase, started: index * 15_000, deadline: (index + 1) * 15_000, locked: (index + 1) * 15_000 })),
        actors: [historyActor(a.playerId, ...left, 1), historyActor(otherId, ...right, 2)] } };
    save();
  }
  const beforeCommits = committedTransactions;
  const response = await request('POST', '/api/matches/finalize', a, item.body);
  const stored = await db.collection('matches').findOne({ matchId: item.matchId });
  check(stored.status === 'committed' && stored.receipt.receiptId === response.savedResult.receiptId, 'Receipt was not stored.');
  check(+stored.receipt.committedAt === +new Date(response.savedResult.committedAt), 'Commit timestamp mismatch.');
  check(committedTransactions > beforeCommits, 'No acknowledged transaction observed.');
  return response.savedResult;
}
async function storageSnapshot(players, matchId) {
  const ids = players.map(row => row.playerId);
  const result = {};
  result.players = await db.collection('players').find({ playerId: { $in: ids } }, { projection: { _id: 0, credentialHash: 0 } }).sort({ playerId: 1 }).toArray();
  for (const name of ['records', 'questInstances', 'questContributions', 'questGrants', 'questOwners', 'menuEntries']) {
    result[name] = await db.collection(name).find({ ownerPlayerId: { $in: ids } }, { projection: { _id: 0 } }).sort({ _id: 1 }).toArray();
  }
  result.match = await db.collection('matches').findOne({ matchId }, { projection: { _id: 0 } });
  return JSON.stringify(result);
}
function own(receipt, player) { return receipt.actors.find(row => row.playerId === player.playerId); }
function quest(view, title) { return view.weeklyQuests.find(row => row.definition.objective === title); }

try {
  db = await database();
  const client = await mongoClient();
  // Private harness observation only: count actual acknowledged driver commits,
  // without logging sessions, commands, credentials, hashes or connection data.
  const startSession = client.startSession.bind(client);
  client.startSession = (...args) => {
    const session = startSession(...args);
    const commit = session.commitTransaction.bind(session);
    session.commitTransaction = async (...parameters) => {
      await commit(...parameters);
      committedTransactions++;
    };
    return session;
  };
  api = await startM11Exercise(rulesRevision, true, () => new Date(time));
  await step('prepare', async () => {
    for (const key of ['A', 'B', 'Outsider', 'Daily', 'Weekly']) await identity(key);
    record('prepare', { dedicatedHumans: 5, rulesRevision, productionReady: false, localApi: true, realAtlas: true });
  });
  const { A: a, B: b, Outsider: outsider, Daily: daily, Weekly: weekly } = saved.identities;
  await step('results_and_sequence', async () => {
    const before = await baseline('normalA', a);
    await menu('initialA', a);
    await menu('initialB', b);
    // Relevant loss with initial Scissors completes the first daily; two false
    // claims contribute once to the active weekly lie objective.
    const loss = await finalize('normal-loss', a, b, 'devil', ['Scissor', 'Scissor', 'Paper', 'switch'], honestRock);
    check(own(loss, a).points === 0 && own(loss, a).classification === 'lying', 'Two-false loss classification/reward failed.');
    let view = await request('GET', '/api/quests', a);
    check(view.dailyQuest.definition.objective === 'win' && view.dailyQuest.counter === 0 && quest(view, 'lie').counter === 1, 'Fresh daily or once-per-match lying failed.');
    const win = await finalize('devil-win', a, b, 'devil', ['Scissor', 'Rock', 'Paper', 'switch'], honestScissor);
    check(own(win, a).points === 20 && !own(win, a).identityTruth && own(win, a).intentionTruth, 'Mixed Devil win failed.');
    const angel = await finalize('angel-win', a, b, 'angel', honestRock, honestScissor);
    check(own(angel, a).points === 25 && own(angel, a).classification === 'honest', 'Angel win failed.');
    const normal = await finalize('base-win', a, b, 'none', honestRock, honestScissor);
    check(own(normal, a).points === 10, 'Base win failed.');
    view = await request('GET', '/api/quests', a);
    check(view.dailyQuest.definition.objective === 'initial_card' && view.dailyQuest.counter === 0 && view.dailyQuest.sequence === 2, 'Repeated Scissors must start fresh.');
    const angelDraw = await finalize('angel-draw', a, b, 'angel', honestScissor, honestScissor);
    check(own(angelDraw, a).points === 10, 'Angel draw failed.');
    view = await request('GET', '/api/quests', a);
    check(view.dailyQuest.definition.objective === 'win' && view.dailyQuest.counter === 0, 'New Scissors draw must complete only the active daily.');
    const devilDraw = await finalize('devil-draw', a, b, 'devil', ['Rock', 'Rock', 'Paper', 'switch'], honestRock);
    check(own(devilDraw, a).points === 8 && own(devilDraw, a).classification === 'lying', 'Two-false Devil draw failed.');
    const baseDraw = await finalize('base-draw', a, b, 'none', honestRock, honestRock);
    check(own(baseDraw, a).points === 3, 'Base draw failed.');
    const stored = await profile(a);
    check(stored.overallPoints - before.overallPoints === 76 && stored.completedMatches - before.completedMatches === 7, 'Stored points/match totals incorrect.');
    check(stored.wins === 3 && stored.losses === 1 && stored.draws === 3 && stored.lieCount === 3 && stored.honestCount === 4, 'Stored aggregate classification incorrect.');
    check(stored.winStreak === 3 && stored.winRate === 300 / 7 && stored.winningFinalCardCounts.Rock === 3
      && stored.winningCardPercentages.Rock === 100 && stored.lyingWinPercentage === 100 / 3, 'Derived percentages/streak incorrect.');
    const records = await db.collection('records').find({ ownerPlayerId: a.playerId }).toArray();
    check(records.length === 7 && records.some(row => row.self.initialCard === 'Scissor' && row.self.finalCard === 'Rock'), 'Owner records lost initial/final distinction.');
    const weeklyView = await request('GET', '/api/quests', a);
    check(quest(weeklyView, 'play').status === 'completed' && quest(weeklyView, 'lie').counter === 3, 'Active weekly progress incorrect.');
    const paid = await menu('payA', a);
    const paidPoints = (await profile(a)).overallPoints;
    check(paid.grants.reduce((sum, row) => sum + row.points, 0) === 13 && paidPoints === 89, 'Menu grants incorrect.');
    await menu('payA', a);
    const repeat = await menu('payAagain', a);
    check(repeat.grants.length === 0 && (await profile(a)).overallPoints === paidPoints, 'Repeated menu double-paid.');
    record('results_and_sequence', { matchPoints: 76, matches: 7, wins: 3, losses: 1, draws: 3, lying: 3, honest: 4,
      winStreakAfterDraws: 3, winRate: stored.winRate, ownerRecords: 7, menuRewards: 13, paidTotal: paidPoints,
      repeatedDailyStartedAtZero: true, relevantLossAndDraw: true, weeklyLieCount: 3 });
  });
  await step('replay_and_access', async () => {
    const item = saved.cases['devil-win'];
    const before = await storageSnapshot([a, b], item.matchId);
    const first = await request('GET', `/api/matches/result?matchId=${item.matchId}`, a);
    const repeated = await request('POST', '/api/matches/finalize', a, item.body);
    check(first.savedResult.receiptId === repeated.savedResult.receiptId, 'Identical replay changed receipt.');
    check(await storageSnapshot([a, b], item.matchId) === before, 'Identical replay wrote extra storage.');
    const conflict = structuredClone(item.body);
    conflict.roundLog.condition = 'none';
    await request('POST', '/api/matches/finalize', a, conflict, 409);
    await request('GET', `/api/matches/result?matchId=${item.matchId}`, outsider, undefined, 403);
    check(await storageSnapshot([a, b], item.matchId) === before, 'Denied replay/result changed storage.');
    record('replay_and_access', { matchId: item.matchId, receiptId: first.savedResult.receiptId,
      identicalStorage: true, conflictingReplay: 409, unauthorizedResult: 403 });
  });
  await step('fallback_and_takeover', async () => {
    const ember = await db.collection('players').findOne({ botSeedKey: 'm10-ember-v1' }, { projection: { credentialHash: 0 } });
    check(ember, 'Agreed Ember profile missing.');
    const beforeBot = await baseline('ember', ember);
    const fallback = await finalize('ordinary-fallback', a, undefined, 'none', honestScissor, honestRock, [], true);
    const afterBot = await profile(ember);
    check(afterBot.completedMatches === beforeBot.completedMatches + 1 && afterBot.wins === beforeBot.wins + 1
      && afterBot.overallPoints === beforeBot.overallPoints + 10, 'Fallback bot credit incorrect.');
    check(await db.collection('records').countDocuments({ matchId: fallback.matchId, ownerPlayerId: ember.playerId }) === 1, 'Bot owner record missing.');
    check((await profile(a)).winStreak === 0, 'Loss did not reset streak.');
    const beforeDeparted = await baseline('departedB', b);
    const beforeSurvivor = await baseline('survivorA', a);
    const botSnapshot = JSON.stringify(await profile(ember));
    const departedQuests = JSON.stringify(await db.collection('questInstances').find({ ownerPlayerId: b.playerId }).sort({ _id: 1 }).toArray());
    const takeover = await finalize('takeover', a, b, 'angel', honestRock, honestScissor, [b.playerId]);
    check(JSON.stringify(await profile(b)) === JSON.stringify(beforeDeparted), 'Departed human received profile credit.');
    check(JSON.stringify(await profile(ember)) === botSnapshot, 'Takeover credited a bot profile.');
    check(JSON.stringify(await db.collection('questInstances').find({ ownerPlayerId: b.playerId }).sort({ _id: 1 }).toArray()) === departedQuests, 'Departed human quests changed.');
    check(await db.collection('records').countDocuments({ matchId: takeover.matchId }) === 1
      && (await profile(a)).overallPoints === beforeSurvivor.overallPoints + 25, 'Survivor-only attribution incorrect.');
    const recordRow = await db.collection('records').findOne({ matchId: takeover.matchId });
    check(recordRow.ownerPlayerId === a.playerId && recordRow.opponent.playerId === b.playerId, 'Survivor opponent snapshot incorrect.');
    record('fallback_and_takeover', { fallbackMatchId: fallback.matchId, emberPointDelta: 10, emberMatchDelta: 1,
      takeoverMatchId: takeover.matchId, survivorPointDelta: 25, takeoverRecords: 1, departedAndBotUnchanged: true });
  });
  time = new Date('2026-10-23T21:59:00Z'); // Saturday 04:59 GMT+7.
  await step('daily_boundaries', async () => {
    await menu('daily-initial', daily);
    await finalize('daily-before-cutoff', daily, b, 'none', honestScissor, honestRock);
    let view = await request('GET', '/api/quests', daily);
    check(view.dailyHistory.some(row => row.status === 'completed'), '04:59 completed daily missing.');
    await registration('inflight-reset', daily, b);
    const points = (await profile(daily)).overallPoints;
    time = new Date('2026-10-23T22:00:00Z');
    view = await request('GET', '/api/quests', daily);
    check(view.dailyHistory.length === 1 && view.dailyQuest.counter === 0 && view.periods.dayStart === time.toISOString(), '05:00 daily reset incorrect.');
    time = new Date('2026-10-23T22:01:00Z');
    const entered = await menu('daily-after', daily);
    check(entered.grants.length === 0 && (await profile(daily)).overallPoints === points, 'Expired unpaid daily was paid.');
    await finalize('inflight-reset', daily, b, 'none', honestScissor, honestRock);
    view = await request('GET', '/api/quests', daily);
    check(view.dailyQuest.counter === 0 && view.dailyQuest.definition.objective === 'initial_card', 'Old in-flight match advanced new daily.');
    await finalize('daily-new-event', daily, b, 'none', honestScissor, honestRock);
    const paid = await menu('daily-pay', daily);
    check(paid.grants.some(row => row.points === 1), 'New daily reward not paid.');
    const paidPoints = (await profile(daily)).overallPoints;
    time = new Date('2026-10-24T22:00:00Z');
    await menu('daily-later-reset', daily);
    check((await profile(daily)).overallPoints === paidPoints, 'Already-paid daily points expired.');
    const expired = await db.collection('questInstances').countDocuments({ ownerPlayerId: daily.playerId, status: 'expired' });
    check(expired >= 2, 'Expected unfinished and unpaid daily expiry in storage.');
    record('daily_boundaries', { localTimes: ['04:59', '05:00', '05:01'], expiredInstances: expired,
      unpaidRewardExpired: true, inflightExcludedFromNewDaily: true, paidPointsPreserved: paidPoints });
  });
  time = new Date('2026-10-25T21:59:00Z'); // Monday 04:59 GMT+7.
  await step('monday_boundaries', async () => {
    await menu('weekly-initial', weekly);
    for (let index = 0; index < 5; index++) {
      await finalize(`weekly-${index}`, weekly, b, 'none', honestRock, honestScissor);
    }
    let view = await request('GET', '/api/quests', weekly);
    check(quest(view, 'play').status === 'completed' && quest(view, 'lie').counter === 0, 'Pre-Monday weekly state incorrect.');
    const points = (await profile(weekly)).overallPoints;
    time = new Date('2026-10-25T22:00:00Z');
    view = await request('GET', '/api/quests', weekly);
    check(view.weeklyQuests.every(row => row.counter === 0 && row.status === 'active') && view.periods.weekStart === time.toISOString(), 'Monday 05:00 reset failed.');
    time = new Date('2026-10-25T22:01:00Z');
    const entered = await menu('weekly-after', weekly);
    check(entered.grants.length === 0 && (await profile(weekly)).overallPoints === points, 'Expired weekly reward paid.');
    const expired = await db.collection('questInstances').find({ ownerPlayerId: weekly.playerId, kind: 'weekly', status: 'expired' }).toArray();
    check(expired.length === 3, 'Completed-unpaid/unfinished weekly expiry not stored.');
    // A's previously paid weekly rewards survive Monday refresh unchanged.
    const aPoints = (await profile(a)).overallPoints;
    await menu('A-monday', a);
    check((await profile(a)).overallPoints === aPoints, 'Paid weekly points lost across Monday.');
    record('monday_boundaries', { expiredWeeklyInstances: 3, unpaidWeeklyRewardExpired: true, unfinishedWeeklyExpired: true,
      weeklyPlayerPointsPreserved: points, paidEarlierPlayerPointsPreserved: aPoints });
  });
  time = new Date('2026-10-25T22:01:00Z');
  await step('reads_and_transactions', async () => {
    const receipt = await request('GET', `/api/matches/result?matchId=${saved.cases.takeover.matchId}`, a);
    const publicRead = await request('GET', `/api/player?playerId=${a.playerId}`);
    const records = await request('GET', '/api/records?limit=50', a);
    const quests = await request('GET', '/api/quests', a);
    const stored = await profile(a);
    check(receipt.status === 'committed' && publicRead.profile.overallPoints === stored.overallPoints
      && publicRead.profile.completedMatches === stored.completedMatches, 'Committed public reads mismatch.');
    check(records.records.length === stored.completedMatches && quests.grants.length === 0, 'Owner records/quest read mismatch.');
    for (const metric of ['overallPoints', 'winRate', 'lieCount', 'honestCount']) {
      const board = await request('GET', `/api/leaderboard?metric=${metric}&limit=50`);
      const entry = board.entries.find(row => row.playerId === a.playerId);
      check(entry && entry[metric] === stored[metric], 'Stored leaderboard aggregate mismatch.');
    }
    const build = await db.command({ buildInfo: 1 });
    const indexes = {};
    for (const name of ['matches', 'records', 'questOwners', 'questInstances', 'questContributions', 'questGrants', 'menuEntries']) {
      indexes[name] = (await db.collection(name).listIndexes().toArray()).filter(row => row.unique).map(row => row.key);
    }
    record('reads_and_transactions', { serverVersion: build.version, observedAcknowledgedCommits: committedTransactions,
      receiptId: receipt.savedResult.receiptId, playerPoints: stored.overallPoints, completedMatches: stored.completedMatches,
      ownerRecordCount: records.records.length, leaderboardMetrics: 4, uniqueIndexes: indexes });
  });
  await step('finishing_event_freshness', async () => {
    // Target the subtle case: the third Win-3 event itself uses initial Scissors.
    // That event must not also complete the newly activated Scissors instance.
    const zeroWins = await profile(daily);
    check(zeroWins.wins === 0 && zeroWins.winningCardPercentages.Rock === null
      && zeroWins.lyingWinPercentage === null, 'Zero-win denominators must remain null.');
    await menu('fresh-proof-menu', daily);
    await finalize('fresh-proof-first', daily, weekly, 'none', honestScissor, honestRock);
    for (let index = 0; index < 3; index++) {
      await finalize(`fresh-proof-win-${index}`, daily, weekly, 'none', ['Scissor', 'Rock', 'Scissor', 'switch'], honestScissor);
    }
    const view = await request('GET', '/api/quests', daily);
    check(view.dailyQuest.definition.objective === 'initial_card' && view.dailyQuest.counter === 0
      && view.dailyQuest.sequence === 2, 'Finishing Win-3 event leaked into next Scissors quest.');
    const finishing = saved.cases['fresh-proof-win-2'];
    check(await db.collection('questContributions').countDocuments({ questInstanceId: view.dailyQuest.questInstanceId,
      matchId: finishing.matchId }) === 0, 'New daily has a finishing-event contribution.');
    record('finishing_event_freshness', { finishingMatchId: finishing.matchId, newInstanceId: view.dailyQuest.questInstanceId,
      newCounter: 0, finishingEventContributions: 0, priorZeroWinPercentagesNull: true, acknowledgedCommitsThisRun: committedTransactions });
  });
  console.log('M11 scoped contract checks complete. Controlled inputs, local HTTP, real Atlas; broad/race/failure/live-game checks remain deferred.');
} catch (error) {
  console.error(`M11 stopped at ${activeStep}.`);
  if (error instanceof Error && !/mongodb|anon_|credential|password|srv|uri/i.test(error.message)) console.error(error.message);
  else console.error('Private service details withheld. Preserve existing exercise data and credentials.');
  process.exitCode = 1;
} finally {
  if (api) await api.close();
  await closeDatabase();
}
