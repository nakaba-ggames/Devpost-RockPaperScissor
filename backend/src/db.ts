import { MongoClient } from 'mongodb';
import { releaseConfiguration } from './config.js';
import { ApiError } from './errors.js';
import type { Player, SavedRecord } from './model.js';
import { requestTimings, timed } from './request-timing.js';
import { performance } from 'node:perf_hooks';

// One connection promise per warm process, shared across concurrent requests.
// maxPoolSize is per server; topology monitoring uses additional connections.
export const poolOptions = {
  maxPoolSize: 5, minPoolSize: 0, maxConnecting: 2, maxIdleTimeMS: 60_000,
  waitQueueTimeoutMS: 5_000, serverSelectionTimeoutMS: 5_000,
  connectTimeoutMS: 5_000, socketTimeoutMS: 10_000, timeoutMS: 10_000
};
let connection: Promise<MongoClient> | undefined;
let client: MongoClient | undefined;

export function mongoClient(): Promise<MongoClient> {
  if (connection) return connection;
  const uri = process.env.MONGODB_URI;
  const name = process.env.MONGODB_DB;
  if (!uri || !name) throw new ApiError(503, 'SERVICE_NOT_CONFIGURED', 'Database configuration is required.', true);
  client = new MongoClient(uri, { ...poolOptions, appName: 'devils-rps-m10', monitorCommands: true });
  const commands = new Map<number, { start: number; context: NonNullable<ReturnType<typeof requestTimings.getStore>> }>();
  client.on('commandStarted', event => {
    const context = requestTimings.getStore();
    if (context) commands.set(event.requestId, { start: performance.now(), context });
  });
  const completed = (event: { requestId: number }) => {
    const command = commands.get(event.requestId);
    if (!command) return;
    commands.delete(event.requestId);
    command.context.commands++;
    const spans = command.context.spans;
    spans.set('db', (spans.get('db') ?? 0) + performance.now() - command.start);
  };
  client.on('commandSucceeded', completed);
  client.on('commandFailed', completed);
  const pendingClient = client;
  connection = timed('connect', () => pendingClient.connect()).catch(async () => {
    connection = undefined;
    await pendingClient.close().catch(() => undefined);
    throw new ApiError(503, 'DATABASE_UNAVAILABLE', 'Saved profiles are temporarily unavailable.', true);
  });
  return connection;
}

export async function database() {
  return (await mongoClient()).db(process.env.MONGODB_DB);
}

export function collectionName(name: string) {
  // Same Atlas database, isolated M12 functionality collections. Existing
  // exercise accounts/history stay in their original collections, untouched.
  const prefix = releaseConfiguration?.collection_prefix ?? '';
  if (!/^[a-zA-Z0-9_]{0,40}$/.test(prefix)) throw new ApiError(503, 'SERVICE_NOT_CONFIGURED', 'Invalid collection namespace.');
  return prefix + name;
}

export async function collections() {
  const db = await database();
  return { players: db.collection<Player>(collectionName('players')), records: db.collection<SavedRecord>(collectionName('records')) };
}

// Only the local server/process scripts close the pool; functions never close per request.
export async function closeDatabase() {
  if (client) await client.close();
  client = undefined;
  connection = undefined;
}
