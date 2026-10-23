import { putHistoryChunk, readHistoryChunk, natural } from './history-upload.js';
import { authenticate } from './auth.js';
import { jsonBody, onlyKeys, onlyQuery, route } from './http.js';
import { badRequest } from './errors.js';
import { identifier, requireSettlementConfiguration } from './settlement-rules.js';
import { requireSettlementIndexes, settlementTransaction } from './settlement-store.js';
import { matchSettlement } from './match-settlement.js';
import { payMenuRewards, questView } from './authoritative-quests.js';
import { serverClock, type ServerClock } from './server-time.js';

interface M11Options {
  clock?: ServerClock;
  // Private in-process capability for the agreed localhost exercise only.
  // Never populated from a public request, header, query or environment value.
  isolatedExerciseRevision?: string;
  allowExerciseEmber?: boolean;
}
export function createM11Handlers(options: M11Options = {}) {
  if (options.clock && options.isolatedExerciseRevision === undefined) {
    throw new Error('An injected clock requires the private isolated-exercise capability.');
  }
  const clock = options.clock ?? serverClock;
  const matches = matchSettlement(clock, options.allowExerciseEmber === true);
  async function ready() {
    requireSettlementConfiguration(options.isolatedExerciseRevision);
    await requireSettlementIndexes();
  }
  return {
    register: route('POST', async (req, url) => {
      onlyQuery(url, []);
      const caller = await authenticate(req);
      const body = await jsonBody(req);
      await ready();
      return { body: await matches.register(caller, body) };
    }),
    join: route('POST', async (req, url) => {
      onlyQuery(url, []);
      const caller = await authenticate(req);
      const body = await jsonBody(req);
      await ready();
      return { body: await matches.join(caller, body) };
    }),
    historyUpload: route('POST', async (req, url) => {
      onlyQuery(url, []);
      const caller = await authenticate(req);
      const body = await jsonBody(req, 64 * 1024);
      await ready();
      return { body: await putHistoryChunk(caller.playerId, body) };
    }),
    history: route('GET', async (req, url) => {
      onlyQuery(url, ['matchId', 'index']);
      const caller = await authenticate(req);
      const raw = url.searchParams.get('index');
      if (raw === null || !/^\d{1,15}$/.test(raw)) badRequest('Invalid history page.');
      return { body: await readHistoryChunk(caller.playerId, identifier(url.searchParams.get('matchId')), natural(Number(raw))) };
    }),
    finalize: route('POST', async (req, url) => {
      onlyQuery(url, []);
      const caller = await authenticate(req);
      const body = await jsonBody(req);
      await ready();
      return { body: await matches.finalize(caller, body) };
    }),
    departure: route('POST', async (req, url) => {
      onlyQuery(url, []);
      const caller = await authenticate(req);
      const body = await jsonBody(req);
      await ready();
      return { body: await matches.depart(caller, body) };
    }),
    result: route('GET', async (req, url) => {
      onlyQuery(url, ['matchId']);
      const caller = await authenticate(req);
      // Reads remain available if production readiness later changes.
      return { body: await matches.result(caller, identifier(url.searchParams.get('matchId'))) };
    }),
    menu: route('POST', async (req, url) => {
      onlyQuery(url, []);
      const caller = await authenticate(req);
      const body = await jsonBody(req);
      onlyKeys(body, ['requestId']);
      const requestId = identifier(body.requestId);
      await ready();
      return { body: await settlementTransaction(async session => {
        const now = clock();
        await payMenuRewards(caller.playerId, requestId, now, session);
        return questView(caller.playerId, now, session, requestId);
      }) };
    }),
    quests: route('GET', async (req, url) => {
      onlyQuery(url, ['historyBefore']);
      const caller = await authenticate(req);
      let historyBefore: number | undefined;
      const before = url.searchParams.get('historyBefore');
      if (before !== null) {
        if (!/^\d{1,12}$/.test(before)) badRequest('Invalid quest history boundary.');
        historyBefore = Number(before);
      }
      await ready();
      return { body: await settlementTransaction(session => questView(caller.playerId, clock(), session, undefined, historyBefore)) };
    })
  };
}

// Deployed functions always use the real clock and production readiness gate.
export const m11Handlers = createM11Handlers();
