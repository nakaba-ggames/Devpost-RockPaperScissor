import { randomUUID } from 'node:crypto';
import { credentialHash, issueCredential, authenticate } from '../src/auth.js';
import { collections } from '../src/db.js';
import { badRequest } from '../src/errors.js';
import { jsonBody, onlyKeys, onlyQuery, route } from '../src/http.js';
import { newHuman, publicProfile } from '../src/model.js';
import { rulesRevision } from '../src/config.js';

export default route('POST', async (req, url) => {
  onlyQuery(url, []);
  const body = await jsonBody(req);
  onlyKeys(body, ['mode']);
  if (body.mode === 'resume') {
    const player = await authenticate(req);
    return { body: { playerId: player.playerId, profile: publicProfile(player), needsDisplayName: player.displayName === null, rulesRevision } };
  }
  if (body.mode !== 'create') badRequest('mode must be create or resume.');
  const credential = issueCredential();
  const player = newHuman(randomUUID(), credentialHash(credential));
  const { players } = await collections();
  await players.insertOne(player);
  return { status: 201, body: { playerId: player.playerId, credential, profile: publicProfile(player), needsDisplayName: true, rulesRevision } };
});
