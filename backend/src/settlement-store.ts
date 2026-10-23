import { MongoServerError, type ClientSession } from 'mongodb';
import { database, mongoClient } from './db.js';
import type { MenuEntry, QuestContribution, QuestGrant, QuestInstance, QuestOwner, RegisteredMatch } from './settlement-model.js';

export async function settlementCollections() {
  const db = await database();
  return {
    matches: db.collection<RegisteredMatch>('matches'),
    questOwners: db.collection<QuestOwner>('questOwners'),
    questInstances: db.collection<QuestInstance>('questInstances'),
    questContributions: db.collection<QuestContribution>('questContributions'),
    questGrants: db.collection<QuestGrant>('questGrants'),
    menuEntries: db.collection<MenuEntry>('menuEntries')
  };
}

export async function setupSettlementIndexes() {
  const c = await settlementCollections();
  await c.matches.createIndex({ matchId: 1 }, { unique: true });
  await c.matches.createIndex({ matchNonce: 1 }, { unique: true });
  await c.matches.createIndex({ 'receipt.receiptId': 1 }, {
    unique: true, partialFilterExpression: { 'receipt.receiptId': { $type: 'string' } }
  });
  await c.questOwners.createIndex({ ownerPlayerId: 1 }, { unique: true });
  await c.questInstances.createIndex({ questInstanceId: 1 }, { unique: true });
  await c.questInstances.createIndex({ ownerPlayerId: 1, kind: 1, periodStart: 1, sequence: 1 });
  await c.questInstances.createIndex({ ownerPlayerId: 1, status: 1, expiresAt: 1 });
  await c.questContributions.createIndex({ questInstanceId: 1, matchId: 1 }, { unique: true });
  await c.questGrants.createIndex({ questInstanceId: 1 }, { unique: true });
  await c.questGrants.createIndex({ ownerPlayerId: 1, requestId: 1 });
  await c.menuEntries.createIndex({ ownerPlayerId: 1, requestId: 1 }, { unique: true });
  const db = await database();
  await db.collection('records').createIndex({ matchId: 1, ownerPlayerId: 1 }, { unique: true });
}

let indexesChecked: Promise<void> | undefined;
export function requireSettlementIndexes() {
  if (!indexesChecked) {
    indexesChecked = checkIndexes().catch(error => { indexesChecked = undefined; throw error; });
  }
  return indexesChecked;
}
async function checkIndexes() {
  const db = await database();
  const expected: Record<string, string[][]> = {
    matches: [['matchId'], ['matchNonce'], ['receipt.receiptId']],
    questOwners: [['ownerPlayerId']], questInstances: [['questInstanceId']],
    questContributions: [['questInstanceId', 'matchId']], questGrants: [['questInstanceId']],
    menuEntries: [['ownerPlayerId', 'requestId']], records: [['matchId', 'ownerPlayerId']]
  };
  for (const [name, keys] of Object.entries(expected)) {
    const indexes = await db.collection(name).listIndexes().toArray();
    for (const fields of keys) {
      if (!indexes.some(index => index.unique === true && JSON.stringify(Object.keys(index.key)) === JSON.stringify(fields))) {
        throw new Error('Required settlement indexes are missing. Run the explicit setup command.');
      }
    }
  }
}

// withTransaction may repeat the callback. It must contain only database work
// on this session: no HTTP acknowledgement, logging of success or other effects.
// The returned value becomes visible to the API only after commit succeeds.
export async function settlementTransaction<T>(work: (session: ClientSession) => Promise<T>): Promise<T> {
  const client = await mongoClient();
  for (let attempt = 0; ; attempt++) {
    const session = client.startSession();
    try {
      return await session.withTransaction(() => work(session), {
        readConcern: { level: 'snapshot' }, writeConcern: { w: 'majority' },
        readPreference: 'primary', maxCommitTimeMS: 10_000, timeoutMS: 15_000
      });
    } catch (error) {
      // A competing first registration/quest-owner insert can lose a unique
      // index race. Read the winning document in a new transaction/snapshot.
      if (!(error instanceof MongoServerError) || error.code !== 11000 || attempt >= 2) throw error;
    } finally {
      await session.endSession();
    }
  }
}
