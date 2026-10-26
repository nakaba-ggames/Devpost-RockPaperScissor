import { botRoster } from '../src/bot-roster.js';
import { randomUUID } from 'node:crypto';
import { closeDatabase, collections } from '../src/db.js';
import { newBot } from '../src/model.js';

// Only permanent zero-history identities; existing profiles are never reset.
const roster = [...botRoster(true), ...botRoster(false)];

try {
  const { players } = await collections();
  await players.createIndex({ botSeedKey: 1 }, {
    unique: true, partialFilterExpression: { botSeedKey: { $type: 'string' } }
  });
  for (const { seedKey, displayName } of roster) {
    const result = await players.updateOne(
      { botSeedKey: seedKey },
      { $setOnInsert: newBot(randomUUID(), displayName, seedKey) },
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
  }
} catch {
  console.error('Bot seed unavailable or conflicting. No private details printed; existing profiles are not overwritten.');
  process.exitCode = 1;
} finally { await closeDatabase(); }
