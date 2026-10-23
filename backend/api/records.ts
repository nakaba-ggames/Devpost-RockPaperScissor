import type { Filter } from 'mongodb';
import { authenticate } from '../src/auth.js';
import { collections } from '../src/db.js';
import { ApiError, badRequest } from '../src/errors.js';
import { onlyQuery, route } from '../src/http.js';
import type { SavedRecord } from '../src/model.js';
import { decodeCursor, encodeCursor, pageLimit } from '../src/pagination.js';

export default route('GET', async (req, url) => {
  const owner = await authenticate(req);
  onlyQuery(url, ['playerId', 'limit', 'cursor']);
  const requested = url.searchParams.get('playerId');
  if (requested !== null && requested !== owner.playerId) {
    throw new ApiError(403, 'OWNER_MISMATCH', 'Records belong to the authenticated owner.');
  }
  const limit = pageLimit(url);
  const cursor = decodeCursor(url);
  const filter: Filter<SavedRecord> = { ownerPlayerId: owner.playerId, eligible: true };
  if (cursor) {
    if (cursor.v !== 1 || cursor.owner !== owner.playerId || typeof cursor.recordId !== 'string'
      || !/^[0-9a-f-]{36}$/.test(cursor.recordId) || typeof cursor.at !== 'string'
      || !Number.isFinite(Date.parse(cursor.at))) badRequest('Invalid records cursor.');
    const at = new Date(cursor.at);
    filter.$or = [{ committedAt: { $lt: at } }, { committedAt: at, recordId: { $gt: cursor.recordId } }];
  }
  const { records } = await collections();
  const rows = await records.find(filter, { projection: {
    _id: 0, recordId: 1, matchId: 1, committedAt: 1, result: 1,
    'self.playerId': 1, 'self.displayName': 1, 'self.initialCard': 1, 'self.finalCard': 1,
    'opponent.playerId': 1, 'opponent.displayName': 1, 'opponent.initialCard': 1, 'opponent.finalCard': 1
  } }).sort({ committedAt: -1, recordId: 1 }).limit(limit + 1).toArray();
  let nextCursor: string | null = null;
  if (rows.length > limit) {
    rows.pop();
    const last = rows.at(-1)!;
    nextCursor = encodeCursor({ v: 1, owner: owner.playerId, at: last.committedAt.toISOString(), recordId: last.recordId });
  }
  return { body: { records: rows, nextCursor } };
});
