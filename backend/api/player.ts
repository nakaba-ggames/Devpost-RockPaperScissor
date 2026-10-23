import { collections } from '../src/db.js';
import { ApiError, badRequest } from '../src/errors.js';
import { onlyQuery, route } from '../src/http.js';
import { publicProfile, publicProjection } from '../src/model.js';
import { validPlayerId } from '../src/pagination.js';

export default route('GET', async (_req, url) => {
  onlyQuery(url, ['playerId']);
  const playerId = url.searchParams.get('playerId');
  if (!validPlayerId(playerId)) badRequest('A valid playerId is required.');
  const { players } = await collections();
  const player = await players.findOne({ playerId }, { projection: publicProjection });
  if (!player) throw new ApiError(404, 'PLAYER_NOT_FOUND', 'Player not found.');
  return { body: { profile: publicProfile(player) } };
});
