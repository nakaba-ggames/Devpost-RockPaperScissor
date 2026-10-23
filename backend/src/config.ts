import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';
import { createHash } from 'node:crypto';

// Read the exported deployment artifact, never a client-provided rule/payout value.
const artifact = JSON.parse(readFileSync(resolve('config/backend-config.json'), 'utf8'));
const { revision, ...payload } = artifact;
const digest = createHash('sha256').update(JSON.stringify(payload)).digest('hex');
if (revision !== `sha256:${digest}` || payload.schemaVersion !== 1) {
  throw new Error('Invalid backend configuration revision. Re-export approved Resources.');
}
export const rulesRevision: string = revision;

export const releaseConfiguration = payload.configuration.release as { collection_prefix: string; fallback_seed_key: string; fallback_personality_id: string };
