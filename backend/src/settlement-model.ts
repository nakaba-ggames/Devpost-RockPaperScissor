import type { Card } from './model.js';

export type Outcome = 'win' | 'draw' | 'loss';
export interface QuestDefinition {
  definition_id: string;
  title: string;
  objective: string;
  card: Card;
  target: number;
  reward_points: number;
}
export interface ActorHistory {
  actorId: string;
  startingOrder: Card[];
  initialCard: Card;
  identityClaim: Card;
  switchClaim: 'keep' | 'switch';
  finalCard: Card;
  events: DecisionEvent[];
}
export interface DecisionEvent {
  phase: 'option' | 'identity_claim' | 'switch_claim' | 'final_choice';
  sequence: number;
  revision: number;
  elapsedMsec: number;
  value: Card | 'keep' | 'switch';
}
export interface RoundHistory {
  matchId: string;
  rulesRevision: string;
  condition: 'devil' | 'angel' | 'none';
  phases: { phase: DecisionEvent['phase']; started: number; deadline: number; locked: number }[];
  actors: ActorHistory[];
}
export interface CalculatedActor {
  playerId: string;
  outcome: Outcome;
  points: number;
  identityTruth: boolean;
  intentionTruth: boolean;
  actualSwitch: boolean;
  classification: 'honest' | 'lying';
  conditionFulfilled: boolean;
  eligible: boolean;
}
export interface Binding {
  playerId: string;
  displayName: string;
  controlKind: 'human' | 'fallback_bot';
  questInstanceIds: string[];
  boundAt: Date;
}
export interface Receipt {
  receiptId: string;
  resultId: string;
  matchId: string;
  committedAt: Date;
  rulesRevision: string;
  history: RoundHistory;
  departures: string[];
  actors: CalculatedActor[];
}
export interface RegisteredMatch {
  matchId: string;
  matchNonce: string;
  creatorPlayerId: string;
  registrationDigest: string;
  expectedPeerPlayerId: string | null;
  rulesRevision: string;
  bindings: Binding[];
  status: 'waiting' | 'ready' | 'committed';
  createdAt: Date;
  submissionDigest?: string;
  receipt?: Receipt;
}
export interface QuestInstance {
  questInstanceId: string;
  ownerPlayerId: string;
  kind: 'daily' | 'weekly';
  sequence: number;
  definition: QuestDefinition;
  rulesRevision: string;
  periodStart: Date;
  expiresAt: Date;
  activatedAt: Date;
  counter: number;
  status: 'active' | 'completed' | 'paid' | 'expired';
  completedAt?: Date;
  paidAt?: Date;
  expiredAt?: Date;
}
export interface QuestOwner {
  ownerPlayerId: string;
  revision: number;
  dayStart: Date;
  weekStart: Date;
  dailySequence: number;
  dailyInstanceId: string;
  weeklyInstanceIds: string[];
}
export interface QuestContribution {
  questInstanceId: string;
  matchId: string;
  ownerPlayerId: string;
  contributedAt: Date;
}
export interface QuestGrant {
  questInstanceId: string;
  ownerPlayerId: string;
  requestId: string;
  points: number;
  paidAt: Date;
}
export interface MenuEntry {
  ownerPlayerId: string;
  requestId: string;
  enteredAt: Date;
}
