import type { ClientSession } from 'mongodb';
import { settlementCollections } from './settlement-store.js';
import { ApiError, badRequest } from './errors.js';
import { onlyKeys } from './http.js';
import { digest, identifier, object, validateHistory } from './settlement-rules.js';
import { createHash } from 'node:crypto';
import type { DecisionEvent, RegisteredMatch } from './settlement-model.js';

export const HISTORY_CHUNK_BYTES = 48 * 1024;
export const hashText = (text: string) => createHash('sha256').update(text).digest('hex');
const phases = ['option', 'identity_claim', 'switch_claim', 'final_choice'] as const;
const cards = ['Rock', 'Paper', 'Scissor'] as const;
export interface HistoryChunk {
  matchId: string; uploadId: string; index: number; encodedEvents: string; digest: string;
}
export function natural(value: unknown): number {
  if (typeof value !== 'number' || !Number.isSafeInteger(value) || value < 0) badRequest('Expected a nonnegative integer.');
  return value;
}
function participant(match: RegisteredMatch, playerId: string) {
  if (!match.bindings.some(row => row.playerId === playerId && row.controlKind === 'human')) {
    throw new ApiError(403, 'MATCH_PARTICIPANT_REQUIRED', 'Only a bound human may access history.');
  }
}
function parseEvents(text: unknown): unknown[] {
  if (typeof text !== 'string' || Buffer.byteLength(text) > HISTORY_CHUNK_BYTES) badRequest('History chunk exceeds its byte limit.');
  let rows: unknown;
  try { rows = JSON.parse(text); } catch { badRequest('Invalid encoded events.'); }
  if (!Array.isArray(rows) || rows.length === 0) badRequest('History chunk must contain events.');
  return rows;
}
export async function putHistoryChunk(playerId: string, body: Record<string, unknown>) {
  onlyKeys(body, ['matchId', 'uploadId', 'index', 'encodedEvents']);
  const matchId = identifier(body.matchId);
  const uploadId = identifier(body.uploadId);
  const index = natural(body.index);
  parseEvents(body.encodedEvents);
  const encodedEvents = body.encodedEvents as string;
  const { matches, historyChunks } = await settlementCollections();
  const match = await matches.findOne({ matchId });
  if (!match) throw new ApiError(404, 'MATCH_NOT_FOUND', 'Registration does not exist.');
  participant(match, playerId);
  if (match.status === 'waiting') throw new ApiError(409, 'MATCH_NOT_READY', 'Bindings must finish before history upload.');
  const row: HistoryChunk = { matchId, uploadId, index, encodedEvents, digest: hashText(encodedEvents) };
  const existing = await historyChunks.findOne({ matchId, uploadId, index });
  if (existing) {
    if (existing.digest !== row.digest) throw new ApiError(409, 'HISTORY_CHUNK_CONFLICT', 'History chunks are immutable.');
    return { index, digest: existing.digest };
  }
  if (match.status === 'committed') throw new ApiError(409, 'MATCH_COMMITTED', 'A committed result cannot gain history.');
  await historyChunks.updateOne({ matchId, uploadId, index }, { $setOnInsert: row }, { upsert: true });
  const saved = await historyChunks.findOne({ matchId, uploadId, index });
  if (saved?.digest !== row.digest) throw new ApiError(409, 'HISTORY_CHUNK_CONFLICT', 'History chunks are immutable.');
  return { index, digest: row.digest };
}

// Tuple v1: actor index, phase index, global sequence, per-phase revision,
// host elapsed milliseconds, card/intention index, decision(0)/default(1).
export function decodeEvent(raw: unknown): { actorIndex: number; event: DecisionEvent } {
  if (!Array.isArray(raw) || raw.length !== 7) badRequest('Expected a seven-field history tuple.');
  const values = raw.map(natural);
  const [actorIndex, phaseIndex, sequence, revision, elapsedMsec, valueIndex, kindIndex] = values as [number, number, number, number, number, number, number];
  if (actorIndex > 1 || phaseIndex > 3 || kindIndex > 1) badRequest('Invalid history tuple.');
  const phase = phases[phaseIndex]!;
  let value: DecisionEvent['value'];
  if (phase === 'switch_claim') {
    if (valueIndex > 1) badRequest('Invalid intention index.');
    value = 'keep';
    if (valueIndex === 1) value = 'switch';
  } else {
    if (valueIndex > 2) badRequest('Invalid card index.');
    value = cards[valueIndex]!;
  }
  let kind: 'decision' | 'default' = 'decision';
  if (kindIndex === 1) kind = 'default';
  return { actorIndex, event: { phase, sequence, revision, elapsedMsec, value, kind } };
}

export async function validateUploadedHistory(match: RegisteredMatch, body: Record<string, unknown>, session: ClientSession) {
  const uploadId = identifier(body.uploadId);
  const chunkCount = natural(body.chunkCount);
  const { historyChunks } = await settlementCollections();
  const cursor = historyChunks.find({ matchId: match.matchId, uploadId, index: { $lt: chunkCount } }, { session }).sort({ index: 1 });
  return validateHistoryChunks(match, body, cursor);
}

export async function validateHistoryChunks(match: RegisteredMatch, body: Record<string, unknown>, chunks: AsyncIterable<HistoryChunk>) {
  const uploadId = identifier(body.uploadId);
  const chunkCount = natural(body.chunkCount);
  if (chunkCount === 0 || typeof body.headerJson !== 'string') badRequest('History manifest is required.');
  let header: Record<string, unknown>;
  try { header = object(JSON.parse(body.headerJson)); } catch { badRequest('Invalid history header.'); }
  if (!Array.isArray(header.actors) || header.actors.length !== 2 || !Array.isArray(header.phases) || header.phases.length !== 4) badRequest('Invalid history header.');
  // Reuse M11 header/timing/card validation, then validate actual streamed events.
  // Synthetic rows are validation inputs only: they are never stored or credited.
  const actors = header.actors.map((raw, actorIndex) => {
    const actor = object(raw);
    onlyKeys(actor, ['actorId', 'startingOrder', 'initialCard', 'identityClaim', 'switchClaim', 'finalCard']);
    const values = [actor.initialCard, actor.identityClaim, actor.switchClaim, actor.finalCard];
    return { ...actor, events: phases.map((phase, index) => ({ phase, sequence: index * 2 + actorIndex + 1,
      revision: 0, elapsedMsec: object((header.phases as unknown[])[index]).deadline, value: values[index] })) };
  });
  const history = validateHistory({ ...header, actors }, match.matchId, (header.actors as Record<string, unknown>[]).map(actor => identifier(actor.actorId)));
  if (digest(history.actors.map(actor => actor.actorId).sort()) !== digest(match.bindings.map(row => row.playerId).sort())) badRequest('History participants must match registration.');
  for (const actor of history.actors) actor.events = [];
  const states = history.actors.map(() => ({ phase: -1, time: -1, revisions: [0, 0, 0, 0], last: ['', '', '', ''] }));
  let historyDigest = hashText(body.headerJson);
  let nextIndex = 0;
  let previousSequence = -1;
  for await (const chunk of chunks) {
    if (chunk.index !== nextIndex) badRequest('History upload is incomplete.');
    nextIndex++;
    historyDigest = hashText(historyDigest + '\n' + chunk.digest);
    for (const raw of parseEvents(chunk.encodedEvents)) {
      const { actorIndex, event } = decodeEvent(raw);
      const phaseIndex = phases.indexOf(event.phase);
      const state = states[actorIndex]!;
      const boundary = history.phases[phaseIndex]!;
      if (event.sequence <= previousSequence || phaseIndex < state.phase || event.elapsedMsec < state.time
        || event.elapsedMsec < boundary.started || event.elapsedMsec > boundary.locked
        || event.revision !== state.revisions[phaseIndex]) badRequest('Invalid uploaded decision order, revision or timing.');
      if (event.kind === 'default' && (event.revision !== 0 || event.elapsedMsec < boundary.deadline)) badRequest('Invalid default event.');
      state.revisions[phaseIndex]++;
      state.last[phaseIndex] = event.value;
      state.phase = phaseIndex;
      state.time = event.elapsedMsec;
      previousSequence = event.sequence;
    }
  }
  if (nextIndex !== chunkCount) badRequest('History upload is incomplete.');
  history.actors.forEach((actor, index) => {
    const state = states[index]!;
    if (state.last.join('|') !== [actor.initialCard, actor.identityClaim, actor.switchClaim, actor.finalCard].join('|')) badRequest('Accepted decisions must match history.');
  });
  return { history, historyDigest, historyUploadId: uploadId, historyChunkCount: chunkCount };
}

export async function readHistoryChunk(playerId: string, matchId: string, index: number) {
  const { matches, historyChunks } = await settlementCollections();
  const match = await matches.findOne({ matchId }, { readConcern: { level: 'majority' } });
  if (!match) throw new ApiError(404, 'MATCH_NOT_FOUND', 'Registration does not exist.');
  participant(match, playerId);
  if (!match.receipt?.historyUploadId || index >= (match.receipt.historyChunkCount ?? 0)) {
    throw new ApiError(404, 'HISTORY_NOT_FOUND', 'Committed history page is unavailable.');
  }
  const chunk = await historyChunks.findOne({ matchId, uploadId: match.receipt.historyUploadId, index });
  if (!chunk) throw new ApiError(503, 'HISTORY_UNAVAILABLE', 'Committed history page is unavailable.', true);
  let nextIndex: number | null = null;
  if (index + 1 < match.receipt.historyChunkCount!) nextIndex = index + 1;
  return { index, encodedEvents: chunk.encodedEvents, digest: chunk.digest, nextIndex };
}
