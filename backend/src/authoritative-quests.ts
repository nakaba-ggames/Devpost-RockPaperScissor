import { randomUUID } from 'node:crypto';
import type { ClientSession, Filter } from 'mongodb';
import { rulesRevision } from './config.js';
import { collections } from './db.js';
import { ApiError } from './errors.js';
import { publicProfile } from './model.js';
import type { ActorHistory, CalculatedActor, QuestDefinition, QuestInstance, QuestOwner } from './settlement-model.js';
import { questQualifies, settlementConfiguration } from './settlement-rules.js';
import { settlementCollections } from './settlement-store.js';
import { questPeriods } from './server-time.js';

function assignment(ownerPlayerId: string, kind: QuestInstance['kind'], sequence: number,
  definition: QuestDefinition, now: Date): QuestInstance {
  const periods = questPeriods(now);
  let periodStart = periods.dayStart;
  let expiresAt = periods.dayEnd;
  if (kind === 'weekly') { periodStart = periods.weekStart; expiresAt = periods.weekEnd; }
  return { questInstanceId: randomUUID(), ownerPlayerId, kind, sequence, definition,
    rulesRevision, periodStart, expiresAt, activatedAt: now, counter: 0, status: 'active' };
}

async function daily(ownerPlayerId: string, sequence: number, now: Date, session: ClientSession) {
  const { questInstances } = await settlementCollections();
  const catalogue = settlementConfiguration.quests;
  if (catalogue.daily_selection !== 'ordered_cycle' || catalogue.daily_cycle.length === 0) {
    throw new ApiError(503, 'QUEST_SELECTION_UNCONFIGURED', 'Quest selection requires authored configuration.');
  }
  const instance = assignment(ownerPlayerId, 'daily', sequence, catalogue.daily_cycle[sequence % catalogue.daily_cycle.length]!, now);
  await questInstances.insertOne(instance, { session });
  return instance.questInstanceId;
}
async function weekly(ownerPlayerId: string, now: Date, session: ClientSession) {
  const { questInstances } = await settlementCollections();
  const ids: string[] = [];
  for (const [index, definition] of settlementConfiguration.quests.weekly_objectives.entries()) {
    const instance = assignment(ownerPlayerId, 'weekly', index, definition, now);
    await questInstances.insertOne(instance, { session });
    ids.push(instance.questInstanceId);
  }
  return ids;
}

// Every quest operation acquires this owner's document write in its transaction.
// This serializes assignment, registration captures, contribution, reset and pay,
// including operations that would otherwise query disjoint instance documents.
export async function currentQuests(ownerPlayerId: string, now: Date, session: ClientSession): Promise<QuestOwner> {
  const { questOwners, questInstances } = await settlementCollections();
  const periods = questPeriods(now);
  let owner = await questOwners.findOne({ ownerPlayerId }, { session });
  if (!owner) {
    const created: QuestOwner = {
      ownerPlayerId, revision: 1, dayStart: periods.dayStart, weekStart: periods.weekStart,
      dailySequence: 0, dailyInstanceId: await daily(ownerPlayerId, 0, now, session),
      weeklyInstanceIds: await weekly(ownerPlayerId, now, session)
    };
    await questOwners.insertOne(created, { session });
    return created;
  }
  await questOwners.updateOne({ ownerPlayerId }, { $inc: { revision: 1 } }, { session });
  if (now < owner.dayStart || now < owner.weekStart) {
    throw new ApiError(503, 'CLOCK_MOVED_BACKWARD', 'Quest authority cannot move backwards for an existing owner.');
  }
  await questInstances.updateMany({ ownerPlayerId, status: { $in: ['active', 'completed'] }, expiresAt: { $lte: now } },
    { $set: { status: 'expired', expiredAt: now } }, { session });
  if (+owner.dayStart !== +periods.dayStart) {
    owner.dayStart = periods.dayStart;
    owner.dailySequence = 0;
    owner.dailyInstanceId = await daily(ownerPlayerId, 0, now, session);
  }
  if (+owner.weekStart !== +periods.weekStart) {
    owner.weekStart = periods.weekStart;
    owner.weeklyInstanceIds = await weekly(ownerPlayerId, now, session);
  }
  await questOwners.updateOne({ ownerPlayerId }, { $set: {
    dayStart: owner.dayStart, weekStart: owner.weekStart, dailySequence: owner.dailySequence,
    dailyInstanceId: owner.dailyInstanceId, weeklyInstanceIds: owner.weeklyInstanceIds
  } }, { session });
  return owner;
}

export async function captureQuests(ownerPlayerId: string, now: Date, session: ClientSession) {
  const owner = await currentQuests(ownerPlayerId, now, session);
  const { questInstances } = await settlementCollections();
  const active = await questInstances.find({ ownerPlayerId, questInstanceId: { $in: [owner.dailyInstanceId, ...owner.weeklyInstanceIds] }, status: 'active' }, { session }).toArray();
  return active.map(row => row.questInstanceId);
}

export async function contributeQuests(ownerPlayerId: string, capturedIds: string[], boundAt: Date,
  matchId: string, actor: ActorHistory, result: CalculatedActor, now: Date, session: ClientSession) {
  const owner = await currentQuests(ownerPlayerId, now, session);
  const { questInstances, questContributions, questOwners } = await settlementCollections();
  const active = await questInstances.find({ ownerPlayerId, questInstanceId: { $in: capturedIds },
    status: 'active', activatedAt: { $lte: boundAt }, expiresAt: { $gt: now } }, { session }).toArray();
  for (const instance of active) {
    if (!questQualifies(instance.definition, actor, result)) continue;
    if (await questContributions.findOne({ questInstanceId: instance.questInstanceId, matchId }, { session })) continue;
    await questContributions.insertOne({ questInstanceId: instance.questInstanceId, matchId, ownerPlayerId, contributedAt: now }, { session });
    const counter = instance.counter + 1;
    if (counter >= instance.definition.target) {
      await questInstances.updateOne({ questInstanceId: instance.questInstanceId, status: 'active' },
        { $set: { counter: instance.definition.target, status: 'completed', completedAt: now } }, { session });
      if (instance.kind === 'daily' && owner.dailyInstanceId === instance.questInstanceId) {
        const sequence = owner.dailySequence + 1;
        const next = await daily(ownerPlayerId, sequence, now, session);
        await questOwners.updateOne({ ownerPlayerId }, { $set: { dailySequence: sequence, dailyInstanceId: next } }, { session });
      }
    } else {
      await questInstances.updateOne({ questInstanceId: instance.questInstanceId, status: 'active' }, { $set: { counter } }, { session });
    }
  }
}

export async function payMenuRewards(ownerPlayerId: string, requestId: string, now: Date, session: ClientSession) {
  await currentQuests(ownerPlayerId, now, session); // Expiry always precedes payment.
  const { menuEntries, questInstances, questGrants } = await settlementCollections();
  const { players } = await collections();
  if (await menuEntries.findOne({ ownerPlayerId, requestId }, { session })) return;
  await menuEntries.insertOne({ ownerPlayerId, requestId, enteredAt: now }, { session });
  const payable = await questInstances.find({ ownerPlayerId, status: 'completed', expiresAt: { $gt: now } }, { session }).toArray();
  let points = 0;
  for (const instance of payable) {
    const updated = await questInstances.updateOne({ questInstanceId: instance.questInstanceId, status: 'completed', expiresAt: { $gt: now } },
      { $set: { status: 'paid', paidAt: now } }, { session });
    if (updated.modifiedCount !== 1) throw new Error('Quest payment invariant failed.');
    await questGrants.insertOne({ questInstanceId: instance.questInstanceId, ownerPlayerId, requestId,
      points: instance.definition.reward_points, paidAt: now }, { session });
    points += instance.definition.reward_points;
  }
  if (points > 0) await players.updateOne({ playerId: ownerPlayerId },
    { $inc: { overallPoints: points, revision: 1 }, $set: { updatedAt: now } }, { session });
}

export async function questView(ownerPlayerId: string, now: Date, session: ClientSession, requestId?: string, historyBefore?: number) {
  const owner = await currentQuests(ownerPlayerId, now, session);
  const { questInstances, questGrants } = await settlementCollections();
  const { players } = await collections();
  const player = await players.findOne({ playerId: ownerPlayerId }, { session });
  if (!player) throw new ApiError(404, 'PLAYER_NOT_FOUND', 'Player does not exist.');
  const dailyQuest = await questInstances.findOne({ questInstanceId: owner.dailyInstanceId }, { session, projection: { _id: 0 } });
  const weeklyQuests = await questInstances.find({ questInstanceId: { $in: owner.weeklyInstanceIds } }, { session, projection: { _id: 0 } }).sort({ sequence: 1 }).toArray();
  const historyFilter: Filter<QuestInstance> = { ownerPlayerId, kind: 'daily', periodStart: owner.dayStart };
  if (historyBefore !== undefined) historyFilter.sequence = { $lt: historyBefore };
  const dailyHistory = await questInstances.find(historyFilter, { session, projection: { _id: 0 } })
    .sort({ sequence: -1 }).limit(101).toArray();
  let dailyHistoryNextBefore: number | null = null;
  if (dailyHistory.length > 100) { dailyHistory.pop(); dailyHistoryNextBefore = dailyHistory.at(-1)!.sequence; }
  let grants: unknown[] = [];
  if (requestId) grants = await questGrants.find({ ownerPlayerId, requestId }, { session, projection: { _id: 0 } }).toArray();
  const profile = publicProfile(player);
  return { profile, stats: profile, dailyQuest, weeklyQuests, dailyHistory, dailyHistoryNextBefore, grants,
    serverTime: now, periods: questPeriods(now), rulesRevision,
    developmentOnly: settlementConfiguration.quests.development_only };
}
