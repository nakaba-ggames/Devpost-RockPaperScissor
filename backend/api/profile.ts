import { authenticate } from '../src/auth.js';
import { collections } from '../src/db.js';
import { ApiError, badRequest } from '../src/errors.js';
import { jsonBody, onlyKeys, onlyQuery, route } from '../src/http.js';
import { publicProfile } from '../src/model.js';

export default route('PATCH', async (req, url) => {
  const owner = await authenticate(req);
  onlyQuery(url, []);
  const body = await jsonBody(req);
  onlyKeys(body, ['displayName']);
  if (typeof body.displayName !== 'string') badRequest('displayName must be text.');
  const displayName = body.displayName.trim();
  const length = [...displayName].length;
  if (length < 1 || length > 24 || /[\p{Cc}\p{Cf}\p{Cs}\p{Zl}\p{Zp}]/u.test(displayName)) {
    badRequest('displayName must contain 1–24 Unicode characters without controls or invisible formatting.');
  }
  const { players } = await collections();
  const updated = await players.findOneAndUpdate(
    { playerId: owner.playerId, kind: 'human' },
    { $set: { displayName, updatedAt: new Date() }, $inc: { revision: 1 } },
    { returnDocument: 'after' }
  );
  if (!updated) throw new ApiError(401, 'CREDENTIAL_INVALID', 'The anonymous credential is invalid.');
  return { body: { profile: publicProfile(updated) } };
});
