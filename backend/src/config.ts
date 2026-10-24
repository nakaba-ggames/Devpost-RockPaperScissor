import { createHash } from 'node:crypto';
import artifact from '../config/backend-config.json' with { type: 'json' };

// A static module dependency is traced into each Vercel function. Never resolve
// this artifact against process.cwd(): a function's working directory can differ
// from the repository's backend root. No client-provided rule/payout values.
const { revision, ...payload } = artifact;
const digest = createHash('sha256').update(JSON.stringify(payload)).digest('hex');
if (revision !== `sha256:${digest}` || payload.schemaVersion !== 1) {
  throw new Error('Invalid backend configuration revision. Re-export approved Resources.');
}
export const rulesRevision: string = revision;
export const backendConfiguration = payload.configuration;

export const releaseConfiguration = payload.configuration.release as { collection_prefix: string; fallback_seed_key: string; fallback_personality_id: string };
