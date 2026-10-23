import { createHash } from 'node:crypto';
import { existsSync, readFileSync } from 'node:fs';
import { resolve } from 'node:path';

const { revision, ...payload } = JSON.parse(readFileSync('config/backend-config.json', 'utf8'));
const digest = createHash('sha256').update(JSON.stringify(payload)).digest('hex');
if (revision !== `sha256:${digest}` || payload.schemaVersion !== 1) throw new Error('Invalid exported configuration revision.');
const project = resolve('../rock-paper-scissor');
// Vercel builds receive the versioned artifact, without requiring a Godot installation.
if (existsSync(resolve(project, 'project.godot'))) {
  for (const [path, expected] of Object.entries(payload.sourceFiles)) {
    const actual = createHash('sha256').update(readFileSync(resolve(project, path))).digest('hex');
    if (actual !== expected) throw new Error(`Resource source changed: ${path}. Run npm run config:export.`);
  }
}
console.log(`Configuration verified: ${revision}; productionReady=${payload.configuration.productionReady}`);
