import { spawnSync } from 'node:child_process';
import { copyFileSync, mkdirSync, mkdtempSync, readFileSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { dirname, resolve, join } from 'node:path';
import { createHash } from 'node:crypto';

const project = resolve('../rock-paper-scissor');
const directory = mkdtempSync(join(tmpdir(), 'rps-config-'));
try {
  // Resource-only scratch project prevents gameplay/SDK autoloads from starting.
  // Copies are exact build inputs; all authored data stays in the original .tres files.
  const inputs = [
    'scripts/resources/arena_rules.gd', 'scripts/quests/quest_catalogue.gd', 'scripts/quests/quest_definition.gd',
    'resources/arena/option_rules.tres', 'resources/quests/development_catalogue.tres',
    ...['scissors', 'wins', 'weekly_play', 'weekly_switch', 'weekly_lie'].map(name => `resources/quests/${name}.tres`)
  ];
  writeFileSync(join(directory, 'project.godot'), 'config_version=5\n');
  for (const path of inputs) {
    mkdirSync(dirname(join(directory, path)), { recursive: true });
    copyFileSync(join(project, path), join(directory, path));
  }
  const output = join(directory, 'resource-export.json');
  const godot = process.env.GODOT_BIN || '/Applications/Godot.app/Contents/MacOS/Godot';
  const run = spawnSync(godot, ['--headless', '--log-file', join(directory, 'godot.log'), '--path', directory, '--script', resolve('scripts/export-config.gd'), '--', output], { stdio: 'inherit' });
  if (run.error || run.status !== 0) throw new Error('Native Resource export failed.');
  const payload = JSON.parse(readFileSync(output, 'utf8'));
  const revision = `sha256:${createHash('sha256').update(JSON.stringify(payload)).digest('hex')}`;
  writeFileSync('config/backend-config.json', JSON.stringify({ revision, ...payload }, null, 2) + '\n');
  console.log(`Exported ${revision}; productionReady=${payload.configuration.productionReady}`);
} finally { rmSync(directory, { recursive: true, force: true }); }
