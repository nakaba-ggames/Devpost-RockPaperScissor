import type { Filter } from 'mongodb';
import { collections } from '../src/db.js';
import { badRequest } from '../src/errors.js';
import { onlyQuery, route } from '../src/http.js';
import { metrics, publicProfile, publicProjection, type Metric, type Player } from '../src/model.js';
import { decodeCursor, encodeCursor, pageLimit, validPlayerId } from '../src/pagination.js';

export default route('GET', async (_req, url) => {
  onlyQuery(url, ['metric', 'limit', 'cursor']);
  const name = url.searchParams.get('metric');
  if (!metrics.includes(name as Metric)) badRequest('Unsupported leaderboard metric.');
  const metric = name as Metric;
  const limit = pageLimit(url);
  const cursor = decodeCursor(url);
  let filter: Filter<Player> = {};
  if (cursor) {
    if (cursor.v !== 1 || cursor.metric !== metric || !validPlayerId(cursor.playerId)) badRequest('Invalid leaderboard cursor.');
    const value = cursor.value;
    if (value !== null && (typeof value !== 'number' || !Number.isFinite(value) || value < 0)) badRequest('Invalid leaderboard cursor.');
    if (value === null && metric !== 'winRate') badRequest('Invalid leaderboard cursor.');
    const following: Filter<Player>[] = [{ [metric]: value, playerId: { $gt: cursor.playerId } }];
    if (value !== null) {
      following.push({ [metric]: { $lt: value } });
      if (metric === 'winRate') following.push({ winRate: null });
    }
    filter = { $or: following };
  }
  const { players } = await collections();
  const rows = await players.find(filter, { projection: publicProjection })
    .sort({ [metric]: -1, playerId: 1 }).limit(limit + 1).toArray();
  let nextCursor: string | null = null;
  if (rows.length > limit) {
    rows.pop();
    const last = rows.at(-1)!;
    nextCursor = encodeCursor({ v: 1, metric, value: last[metric], playerId: last.playerId });
  }
  return { body: { entries: rows.map(publicProfile), nextCursor } };
});
