import { randomUUID } from 'node:crypto';
import { closeDatabase, collections } from '../src/db.js';
import { newBot } from '../src/model.js';

// Creator approved this backend identity on 2026-10-23, separately from preview Ember.
// No personality, balances, fixture statistics, history or receipts are imported.
const seedKey = 'm10-ember-v1';

try {
  const { players } = await collections();
  await players.createIndex({ botSeedKey: 1 }, {
    unique: true, partialFilterExpression: { botSeedKey: { $type: 'string' } }
  });
  const result = await players.updateOne(
    { botSeedKey: seedKey },
    { $setOnInsert: newBot(randomUUID(), 'Ember', seedKey) },
    { upsert: true }
  );
  const saved = await players.findOne({ botSeedKey: seedKey });
  if (!saved || saved.kind !== 'bot' || Object.hasOwn(saved, 'credentialHash')) {
    throw new Error('Seed identity conflict. Existing data preserved.');
  }
  // Re-running preserves the permanent ID, display name and any future earned progress.
  console.log(JSON.stringify({
    seed: seedKey, inserted: result.upsertedCount === 1,
    overallPoints: saved.overallPoints, completedMatches: saved.completedMatches,
    hasCredential: false
  }));
} catch {
  console.error('Bot seed unavailable or conflicting. No private details printed; existing profiles are not overwritten.');
  process.exitCode = 1;
} finally { await closeDatabase(); }
