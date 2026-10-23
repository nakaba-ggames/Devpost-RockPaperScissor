import type { Document } from 'mongodb';

export const metrics = ['overallPoints', 'winRate', 'lieCount', 'honestCount'] as const;
export type Metric = typeof metrics[number];
export type Card = 'Rock' | 'Paper' | 'Scissor';
type Cards<T> = { Rock: T; Paper: T; Scissor: T };

export interface Player {
  playerId: string;
  kind: 'human' | 'bot';
  displayName: string | null;
  credentialHash?: string;
  overallPoints: number;
  completedMatches: number;
  wins: number;
  losses: number;
  draws: number;
  winStreak: number;
  initialCardCounts: Cards<number>;
  finalCardCounts: Cards<number>;
  winningFinalCardCounts: Cards<number>;
  lieCount: number;
  honestCount: number;
  lyingWins: number;
  honestWins: number;
  switchCount: number;
  winRate: number | null;
  winningCardPercentages: Cards<number | null>;
  lyingWinPercentage: number | null;
  honestWinPercentage: number | null;
  initialCardPercentages: Cards<number | null>;
  liePercentage: number | null;
  switchPercentage: number | null;
  revision: number;
  createdAt: Date;
  updatedAt: Date;
}

export interface SavedRecord {
  recordId: string;
  matchId: string;
  ownerPlayerId: string;
  eligible: boolean;
  committedAt: Date;
  self: { playerId: string; displayName: string; initialCard: Card; finalCard: Card };
  opponent: { playerId: string; displayName: string; initialCard: Card; finalCard: Card };
  result: 'win' | 'loss' | 'draw';
}

const publicFields = [
  'playerId', 'displayName', 'overallPoints', 'completedMatches', 'wins', 'losses', 'draws',
  'winStreak', 'lieCount', 'honestCount', 'lyingWins', 'honestWins', 'switchCount',
  'winRate', 'lyingWinPercentage', 'honestWinPercentage', 'liePercentage', 'switchPercentage'
] as const;
const cardFields = [
  'initialCardCounts', 'finalCardCounts', 'winningFinalCardCounts',
  'winningCardPercentages', 'initialCardPercentages'
] as const;

// Inclusion projection: adding future private fields cannot expose them here.
export const publicProjection: Document = { _id: 0 };
for (const field of publicFields) publicProjection[field] = 1;
for (const field of cardFields) {
  for (const card of ['Rock', 'Paper', 'Scissor']) publicProjection[`${field}.${card}`] = 1;
}

export function publicProfile(player: Player) {
  const profile: Record<string, unknown> = {};
  for (const field of publicFields) profile[field] = player[field];
  for (const field of cardFields) {
    profile[field] = { Rock: player[field].Rock, Paper: player[field].Paper, Scissor: player[field].Scissor };
  }
  return profile;
}

export function newHuman(playerId: string, credentialHash: string): Player {
  const zero = () => ({ Rock: 0, Paper: 0, Scissor: 0 });
  const na = () => ({ Rock: null, Paper: null, Scissor: null });
  const now = new Date();
  return {
    playerId, kind: 'human', displayName: null, credentialHash,
    overallPoints: 0, completedMatches: 0, wins: 0, losses: 0, draws: 0, winStreak: 0,
    initialCardCounts: zero(), finalCardCounts: zero(), winningFinalCardCounts: zero(),
    lieCount: 0, honestCount: 0, lyingWins: 0, honestWins: 0, switchCount: 0,
    winRate: null, winningCardPercentages: na(), lyingWinPercentage: null,
    honestWinPercentage: null, initialCardPercentages: na(), liePercentage: null,
    switchPercentage: null, revision: 1, createdAt: now, updatedAt: now
  };
}
