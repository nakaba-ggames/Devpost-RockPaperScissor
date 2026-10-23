import { randomUUID } from 'node:crypto';
import type { ClientSession } from 'mongodb';
import { rulesRevision } from './config.js';
import { collections } from './db.js';
import { ApiError, badRequest } from './errors.js';
import { onlyKeys } from './http.js';
import { publicProfile, type Player } from './model.js';
import type { Binding, Receipt, RegisteredMatch } from './settlement-model.js';
import { applyCompetitiveResult, calculateActors, digest, identifier, validateHistory } from './settlement-rules.js';
import { settlementCollections, settlementTransaction } from './settlement-store.js';
import { captureQuests, contributeQuests } from './authoritative-quests.js';
import type { ServerClock } from './server-time.js';

function boundParticipant(match: RegisteredMatch, playerId: string) {
  if (!match.bindings.some(binding => binding.playerId === playerId && binding.controlKind === 'human')) {
    throw new ApiError(403, 'MATCH_PARTICIPANT_REQUIRED', 'Only a bound participant can access this match.');
  }
}
async function registrationView(match: RegisteredMatch, viewerPlayerId: string, session: ClientSession) {
  const { players } = await collections();
  const opponent = match.bindings.find(binding => binding.playerId !== viewerPlayerId);
  let opponentPublicProfile = null;
  if (opponent) {
    const player = await players.findOne({ playerId: opponent.playerId }, { session });
    if (player) opponentPublicProfile = publicProfile(player);
  }
  return {
    matchId: match.matchId, status: match.status, rulesRevision: match.rulesRevision,
    opponentPublicProfile,
    participantBindings: match.bindings.map(binding => ({ playerId: binding.playerId, displayName: binding.displayName, boundAt: binding.boundAt }))
  };
}
function resultView(match: RegisteredMatch) {
  if (match.status === 'committed' && match.receipt) {
    return { matchId: match.matchId, status: match.status, savedResult: match.receipt };
  }
  return { matchId: match.matchId, status: match.status, savedResult: null };
}

export function matchSettlement(clock: ServerClock, allowExerciseEmber: boolean) {
  return {
    async register(caller: Player, body: Record<string, unknown>) {
      onlyKeys(body, ['matchNonce', 'lobbyId', 'peerPlayerId', 'fallbackRequested', 'rulesRevision']);
      const matchNonce = identifier(body.matchNonce);
      if (body.rulesRevision !== rulesRevision) badRequest('Unknown rules revision.');
      if (typeof body.fallbackRequested !== 'boolean') badRequest('Specify fallbackRequested.');
      let expectedPeerPlayerId: string | null = null;
      if (body.peerPlayerId !== undefined) expectedPeerPlayerId = identifier(body.peerPlayerId);
      if (expectedPeerPlayerId === caller.playerId || (body.fallbackRequested && expectedPeerPlayerId)) badRequest('Invalid requested opponent.');
      let lobbyId: string | null = null;
      if (body.lobbyId !== undefined) {
        if (typeof body.lobbyId !== 'string' || !/^[A-Za-z0-9_-]{1,128}$/.test(body.lobbyId)) badRequest('Invalid lobby ID.');
        lobbyId = body.lobbyId;
      }
      const registrationDigest = digest({ matchNonce, lobbyId, expectedPeerPlayerId,
        fallbackRequested: body.fallbackRequested, rulesRevision });
      return settlementTransaction(async session => {
        const { matches } = await settlementCollections();
        const { players } = await collections();
        const existing = await matches.findOne({ matchNonce }, { session });
        if (existing) {
          if (existing.creatorPlayerId !== caller.playerId) throw new ApiError(403, 'REGISTRATION_OWNER_REQUIRED', 'Registration belongs to another participant.');
          if (existing.registrationDigest !== registrationDigest) throw new ApiError(409, 'REGISTRATION_CONFLICT', 'Nonce already binds another registration.');
          return registrationView(existing, caller.playerId, session);
        }
        const now = clock();
        const human = await players.findOne({ playerId: caller.playerId, kind: 'human' }, { session });
        if (!human?.displayName) badRequest('Save a display name before registering.');
        if (expectedPeerPlayerId && !await players.findOne({ playerId: expectedPeerPlayerId, kind: 'human' }, { session })) {
          badRequest('Requested human does not exist.');
        }
        const first: Binding = { playerId: human.playerId, displayName: human.displayName, controlKind: 'human',
          questInstanceIds: await captureQuests(human.playerId, now, session), boundAt: now };
        const match: RegisteredMatch = {
          matchId: randomUUID(), matchNonce, creatorPlayerId: human.playerId, registrationDigest,
          expectedPeerPlayerId, rulesRevision, bindings: [first], status: 'waiting', createdAt: now
        };
        if (body.fallbackRequested) {
          if (!allowExerciseEmber) throw new ApiError(503, 'BOT_SELECTION_UNCONFIGURED', 'Fallback selection requires creator agreement.');
          const bot = await players.findOne({ kind: 'bot', botSeedKey: 'm10-ember-v1' }, { session });
          if (!bot?.displayName) throw new ApiError(503, 'BOT_PROFILE_UNAVAILABLE', 'Approved fallback profile is unavailable.');
          match.bindings.push({ playerId: bot.playerId, displayName: bot.displayName, controlKind: 'fallback_bot', questInstanceIds: [], boundAt: now });
          match.status = 'ready';
        }
        await matches.insertOne(match, { session });
        return registrationView(match, caller.playerId, session);
      });
    },

    async join(caller: Player, body: Record<string, unknown>) {
      onlyKeys(body, ['matchId', 'matchNonce']);
      const matchId = identifier(body.matchId);
      const matchNonce = identifier(body.matchNonce);
      return settlementTransaction(async session => {
        const { matches } = await settlementCollections();
        const { players } = await collections();
        const match = await matches.findOne({ matchId, matchNonce }, { session });
        if (!match) throw new ApiError(404, 'MATCH_NOT_FOUND', 'Registration does not exist.');
        if (match.bindings.some(binding => binding.playerId === caller.playerId)) return registrationView(match, caller.playerId, session);
        if (match.status !== 'waiting' || match.bindings.length !== 1
          || (match.expectedPeerPlayerId && match.expectedPeerPlayerId !== caller.playerId)) {
          throw new ApiError(403, 'PARTICIPANT_BINDING_CLOSED', 'This account cannot replace a participant binding.');
        }
        const now = clock();
        const human = await players.findOne({ playerId: caller.playerId, kind: 'human' }, { session });
        if (!human?.displayName) badRequest('Save a display name before joining.');
        const binding: Binding = { playerId: human.playerId, displayName: human.displayName, controlKind: 'human',
          questInstanceIds: await captureQuests(human.playerId, now, session), boundAt: now };
        const updated = await matches.updateOne({ matchId, status: 'waiting' }, { $push: { bindings: binding }, $set: { status: 'ready' } }, { session });
        if (updated.modifiedCount !== 1) throw new Error('Participant binding invariant failed.');
        match.bindings.push(binding);
        match.status = 'ready';
        return registrationView(match, caller.playerId, session);
      });
    },

    async finalize(caller: Player, body: Record<string, unknown>) {
      onlyKeys(body, ['matchId', 'rulesRevision', 'roundLog', 'departures']);
      const matchId = identifier(body.matchId);
      if (body.rulesRevision !== rulesRevision) badRequest('Unknown rules revision.');
      if (!Array.isArray(body.departures) || body.departures.length > 1) badRequest('Expected at most one pre-commit departure.');
      const departures = body.departures.map(identifier).sort();
      return settlementTransaction(async session => {
        const { matches } = await settlementCollections();
        const { players, records } = await collections();
        const match = await matches.findOne({ matchId }, { session });
        if (!match) throw new ApiError(404, 'MATCH_NOT_FOUND', 'Registration does not exist.');
        boundParticipant(match, caller.playerId);
        if (departures.includes(caller.playerId)) throw new ApiError(403, 'ELIGIBLE_SUBMITTER_REQUIRED', 'A remaining eligible human must submit.');
        if (match.bindings.length !== 2 || match.status === 'waiting') throw new ApiError(409, 'MATCH_NOT_READY', 'Human binding must finish before play.');
        if (match.rulesRevision !== rulesRevision) badRequest('Registration rules revision mismatch.');
        for (const departed of departures) {
          if (!match.bindings.some(binding => binding.playerId === departed && binding.controlKind === 'human')) badRequest('Only a bound human may depart into takeover.');
        }
        const history = validateHistory(body.roundLog, matchId, match.bindings.map(binding => binding.playerId));
        const submissionDigest = digest({ history, departures });
        if (match.status === 'committed') {
          if (match.submissionDigest !== submissionDigest) throw new ApiError(409, 'FINALIZATION_CONFLICT', 'Committed history and eligibility cannot be rewritten.');
          return resultView(match);
        }
        const now = clock(); // Re-evaluated if the driver retries the transaction.
        const actors = calculateActors(history, departures);
        const receipt: Receipt = { receiptId: randomUUID(), resultId: `${matchId}:result`, matchId,
          committedAt: now, rulesRevision, history, departures, actors };
        // Take the registration write lock before applying any credit.
        const locked = await matches.updateOne({ matchId, status: 'ready' },
          { $set: { status: 'committed', submissionDigest, receipt } }, { session });
        if (locked.modifiedCount !== 1) throw new Error('Finalization invariant failed.');
        // Stable owner ordering avoids opposite-participant lock ordering.
        const bindings = [...match.bindings].sort((a, b) => a.playerId.localeCompare(b.playerId));
        for (const binding of bindings) {
          const result = actors.find(value => value.playerId === binding.playerId)!;
          if (!result.eligible) continue;
          const actor = history.actors.find(value => value.actorId === binding.playerId)!;
          const other = history.actors.find(value => value.actorId !== binding.playerId)!;
          const opponent = match.bindings.find(value => value.playerId !== binding.playerId)!;
          const player = await players.findOne({ playerId: binding.playerId }, { session });
          if (!player) throw new Error('Bound player is missing.');
          applyCompetitiveResult(player, actor, result, now);
          await players.replaceOne({ playerId: binding.playerId }, player, { session });
          await records.insertOne({ recordId: randomUUID(), matchId, ownerPlayerId: binding.playerId, eligible: true, committedAt: now,
            self: { playerId: binding.playerId, displayName: binding.displayName, initialCard: actor.initialCard, finalCard: actor.finalCard },
            opponent: { playerId: opponent.playerId, displayName: opponent.displayName, initialCard: other.initialCard, finalCard: other.finalCard },
            result: result.outcome }, { session });
          if (binding.controlKind === 'human') {
            await contributeQuests(binding.playerId, binding.questInstanceIds, binding.boundAt, matchId, actor, result, now, session);
          }
        }
        match.status = 'committed';
        match.receipt = receipt;
        return resultView(match);
      });
    },

    async result(caller: Player, matchId: string) {
      const { matches } = await settlementCollections();
      const match = await matches.findOne({ matchId }, { readConcern: { level: 'majority' } });
      if (!match) throw new ApiError(404, 'MATCH_NOT_FOUND', 'Registration does not exist.');
      boundParticipant(match, caller.playerId);
      return resultView(match);
    }
  };
}
