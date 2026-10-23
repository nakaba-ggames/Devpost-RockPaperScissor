import { closeDatabase, collections, database, mongoClient, poolOptions } from '../src/db.js';
import { metrics } from '../src/model.js';

try {
  const first = mongoClient();
  const reused = first === mongoClient();
  const { players, records } = await collections();
  await players.createIndex({ playerId: 1 }, { unique: true });
  await players.createIndex({ credentialHash: 1 }, {
    unique: true, partialFilterExpression: { credentialHash: { $type: 'string' } }
  });
  for (const metric of metrics) await players.createIndex({ [metric]: -1, playerId: 1 });
  await records.createIndex({ recordId: 1 }, { unique: true });
  await records.createIndex({ ownerPlayerId: 1, eligible: 1, committedAt: -1, recordId: 1 });
  const db = await database();
  const build = await db.command({ buildInfo: 1 });
  console.log(JSON.stringify({ serverVersion: build.version, connectionPromiseReused: reused, pool: poolOptions, indexesReady: true }));
} catch {
  console.error('Database setup unavailable. Check protected environment, Atlas user and network access. No private details printed.');
  process.exitCode = 1;
} finally { await closeDatabase(); }
