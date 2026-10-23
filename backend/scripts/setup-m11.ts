import { closeDatabase } from '../src/db.js';
import { setupSettlementIndexes } from '../src/settlement-store.js';

try {
  await setupSettlementIndexes();
  console.log('M11 unique settlement, owner-record, quest contribution/grant and menu indexes ready.');
} catch {
  console.error('M11 index setup unavailable; private database details withheld.');
  process.exitCode = 1;
} finally {
  await closeDatabase();
}
