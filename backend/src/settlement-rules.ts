import { createHash } from 'node:crypto';
import { readFileSync } from 'node:fs';
import { rulesRevision } from './config.js';
import { ApiError, badRequest } from './errors.js';
import { onlyKeys } from './http.js';
import type { Card, Player } from './model.js';
import type { ActorHistory, CalculatedActor, QuestDefinition, RoundHistory } from './settlement-model.js';

interface Configuration {
  productionReady: boolean;
  rules: Record<string, number | string | boolean>;
  quests: {
    revision: string; development_only: boolean; daily_selection: string;
    daily_cycle: QuestDefinition[]; weekly_objectives: QuestDefinition[];
  };
}
export const settlementConfiguration: Configuration = JSON.parse(readFileSync('config/backend-config.json', 'utf8')).configuration;

export function requireSettlementConfiguration(isolatedExerciseRevision?: string) {
  if (isolatedExerciseRevision !== undefined) {
    if (process.env.VERCEL || isolatedExerciseRevision !== rulesRevision) {
      throw new ApiError(503, 'CONFIGURATION_NOT_APPROVED', 'Isolated exercise configuration is unavailable.');
    }
    // This capability is passed only by the private localhost exercise harness
    // after creator agreement. Public handlers never read it from requests/env.
    return;
  }
  if (!settlementConfiguration.productionReady || settlementConfiguration.quests.development_only) {
    throw new ApiError(503, 'CONFIGURATION_NOT_APPROVED', 'Production rules and quest catalogue require creator approval.');
  }
}

export function digest(value: unknown): string {
  return createHash('sha256').update(JSON.stringify(value)).digest('hex');
}
export function object(value: unknown): Record<string, unknown> {
  if (!value || typeof value !== 'object' || Array.isArray(value)) badRequest('Expected an object.');
  return value as Record<string, unknown>;
}
export function identifier(value: unknown): string {
  if (typeof value !== 'string' || !/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(value)) {
    badRequest('Expected a UUID.');
  }
  return value.toLowerCase();
}
function integer(value: unknown): number {
  if (typeof value !== 'number' || !Number.isSafeInteger(value) || value < 0) badRequest('Expected a nonnegative integer.');
  return value;
}
const cards: Card[] = ['Rock', 'Paper', 'Scissor'];
function card(value: unknown): Card {
  if (!cards.includes(value as Card)) badRequest('Invalid card.');
  return value as Card;
}
const phases = ['option', 'identity_claim', 'switch_claim', 'final_choice'] as const;
const durationFields = ['option_seconds', 'identity_claim_seconds', 'switch_claim_seconds', 'final_choice_seconds'];

// Compact backend wire history. M12 may translate the richer Godot RoundLog;
// neither presentation state nor a client-calculated reward is accepted here.
export function validateHistory(input: unknown, matchId: string, participantIds: string[]): RoundHistory {
  const log = object(input);
  onlyKeys(log, ['matchId', 'rulesRevision', 'condition', 'phases', 'actors']);
  if (log.matchId !== matchId || log.rulesRevision !== rulesRevision) badRequest('History identity/revision mismatch.');
  if (!['devil', 'angel', 'none'].includes(log.condition as string)) badRequest('Invalid arena condition.');
  if (!Array.isArray(log.phases) || log.phases.length !== 4) badRequest('Four locked phases are required.');
  const timing: RoundHistory['phases'] = [];
  for (let index = 0; index < phases.length; index++) {
    const row = object(log.phases[index]);
    onlyKeys(row, ['phase', 'started', 'deadline', 'locked']);
    const phase = phases[index]!;
    const started = integer(row.started);
    const deadline = integer(row.deadline);
    const locked = integer(row.locked);
    const duration = Number(settlementConfiguration.rules[durationFields[index]!]) * 1000;
    if (row.phase !== phase || deadline - started !== duration || locked < deadline
      || (index > 0 && started < timing[index - 1]!.locked)) badRequest('Invalid phase timing/order.');
    timing.push({ phase, started, deadline, locked });
  }
  if (!Array.isArray(log.actors) || log.actors.length !== 2) badRequest('Exactly two actor histories are required.');
  const actors: ActorHistory[] = [];
  const globalSequences = new Set<number>();
  for (const playerId of participantIds) {
    const candidates = log.actors.filter(value => object(value).actorId === playerId);
    if (candidates.length !== 1) badRequest('History participants must match registration.');
    const row = object(candidates[0]);
    onlyKeys(row, ['actorId', 'startingOrder', 'initialCard', 'identityClaim', 'switchClaim', 'finalCard', 'events']);
    if (!Array.isArray(row.startingOrder) || row.startingOrder.length !== 3
      || new Set(row.startingOrder.map(card)).size !== 3) badRequest('Starting order must be an RPS permutation.');
    if (row.switchClaim !== 'keep' && row.switchClaim !== 'switch') badRequest('Invalid intention claim.');
    const actor: ActorHistory = {
      actorId: playerId, startingOrder: row.startingOrder.map(card), initialCard: card(row.initialCard),
      identityClaim: card(row.identityClaim), switchClaim: row.switchClaim, finalCard: card(row.finalCard), events: []
    };
    if (!Array.isArray(row.events) || row.events.length < 4 || row.events.length > 64) badRequest('Expected bounded phase decision history.');
    let previousSequence = -1;
    let previousElapsed = -1;
    let previousPhase = -1;
    const lastValues = new Map<string, string>();
    const revisions = new Map<string, number>();
    for (const raw of row.events) {
      const event = object(raw);
      onlyKeys(event, ['phase', 'sequence', 'revision', 'elapsedMsec', 'value']);
      const phaseIndex = phases.indexOf(event.phase as typeof phases[number]);
      if (phaseIndex < 0 || phaseIndex < previousPhase) badRequest('Invalid event phase ordering.');
      const phase = phases[phaseIndex]!;
      const sequence = integer(event.sequence);
      const revision = integer(event.revision);
      const elapsedMsec = integer(event.elapsedMsec);
      const boundary = timing[phaseIndex]!;
      if (sequence <= previousSequence || globalSequences.has(sequence) || elapsedMsec < previousElapsed
        || elapsedMsec < boundary.started || elapsedMsec > boundary.locked
        || revision !== (revisions.get(phase) ?? 0)) badRequest('Invalid event sequence, revision or timing.');
      let value: Card | 'keep' | 'switch';
      if (phase === 'switch_claim') {
        if (event.value !== 'keep' && event.value !== 'switch') badRequest('Invalid intention event.');
        value = event.value;
      } else {
        value = card(event.value);
      }
      actor.events.push({ phase, sequence, revision, elapsedMsec, value });
      lastValues.set(phase, value);
      revisions.set(phase, revision + 1);
      globalSequences.add(sequence);
      previousSequence = sequence;
      previousElapsed = elapsedMsec;
      previousPhase = phaseIndex;
    }
    if (lastValues.get('option') !== actor.initialCard || lastValues.get('identity_claim') !== actor.identityClaim
      || lastValues.get('switch_claim') !== actor.switchClaim || lastValues.get('final_choice') !== actor.finalCard) {
      badRequest('Final decisions must agree with accepted phase events.');
    }
    actors.push(actor);
  }
  return { matchId, rulesRevision, condition: log.condition as RoundHistory['condition'], phases: timing, actors };
}

export function calculateActors(history: RoundHistory, departures: string[]): CalculatedActor[] {
  return history.actors.map((actor, index) => {
    const other = history.actors[1 - index]!;
    let outcome: CalculatedActor['outcome'] = 'loss';
    if (actor.finalCard === other.finalCard) outcome = 'draw';
    else if ((actor.finalCard === 'Rock' && other.finalCard === 'Scissor')
      || (actor.finalCard === 'Paper' && other.finalCard === 'Rock')
      || (actor.finalCard === 'Scissor' && other.finalCard === 'Paper')) outcome = 'win';
    const actualSwitch = actor.initialCard !== actor.finalCard;
    const identityTruth = actor.identityClaim === actor.initialCard;
    const intentionTruth = (actor.switchClaim === 'switch') === actualSwitch;
    let classification: CalculatedActor['classification'] = 'lying';
    if (identityTruth && intentionTruth) classification = 'honest';
    const conditionFulfilled = (history.condition === 'devil' && classification === 'lying')
      || (history.condition === 'angel' && classification === 'honest');
    const rules = settlementConfiguration.rules;
    let points = Number(rules[`${outcome}_points`]);
    if (conditionFulfilled && outcome !== 'loss') points += Number(rules[`${history.condition}_${outcome}_bonus`]);
    return { playerId: actor.actorId, outcome, points: Math.max(0, points), identityTruth, intentionTruth,
      actualSwitch, classification, conditionFulfilled, eligible: !departures.includes(actor.actorId) };
  });
}

export function applyCompetitiveResult(player: Player, actor: ActorHistory, result: CalculatedActor, now: Date) {
  player.overallPoints += result.points;
  player.completedMatches++;
  player.initialCardCounts[actor.initialCard]++;
  player.finalCardCounts[actor.finalCard]++;
  if (result.classification === 'lying') player.lieCount++;
  else player.honestCount++;
  if (result.actualSwitch) player.switchCount++;
  if (result.outcome === 'win') {
    player.wins++;
    player.winStreak++;
    player.winningFinalCardCounts[actor.finalCard]++;
    if (result.classification === 'lying') player.lyingWins++;
    else player.honestWins++;
  } else if (result.outcome === 'loss') {
    player.losses++;
    player.winStreak = 0;
  } else player.draws++;
  const percent = (count: number, denominator: number) => {
    if (denominator === 0) return null;
    return 100 * count / denominator;
  };
  player.winRate = percent(player.wins, player.completedMatches);
  player.lyingWinPercentage = percent(player.lyingWins, player.wins);
  player.honestWinPercentage = percent(player.honestWins, player.wins);
  player.liePercentage = percent(player.lieCount, player.completedMatches);
  player.switchPercentage = percent(player.switchCount, player.completedMatches);
  for (const value of cards) {
    player.winningCardPercentages[value] = percent(player.winningFinalCardCounts[value], player.wins);
    player.initialCardPercentages[value] = percent(player.initialCardCounts[value], player.completedMatches);
  }
  player.revision++;
  player.updatedAt = now;
}

export function questQualifies(definition: QuestDefinition, actor: ActorHistory, result: CalculatedActor) {
  switch (definition.objective) {
    case 'play': return true;
    case 'initial_card': return actor.initialCard === definition.card;
    case 'final_card': return actor.finalCard === definition.card;
    case 'win': case 'loss': case 'draw': return result.outcome === definition.objective;
    case 'lie': return result.classification === 'lying';
    case 'win_lying': return result.outcome === 'win' && result.classification === 'lying';
    case 'win_honest': return result.outcome === 'win' && result.classification === 'honest';
    case 'switch': return result.actualSwitch;
    default: throw new ApiError(503, 'INVALID_QUEST_CONFIGURATION', 'Unsupported authored quest objective.');
  }
}
