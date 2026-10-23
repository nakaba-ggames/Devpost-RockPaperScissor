import { createHash, randomBytes } from 'node:crypto';
import type { IncomingMessage } from 'node:http';
import { collections } from './db.js';
import { ApiError } from './errors.js';

export function issueCredential() { return `anon_${randomBytes(32).toString('base64url')}`; }
export function credentialHash(credential: string) {
  // SHA-256 is appropriate for uniformly random 256-bit secrets (not human passwords).
  return createHash('sha256').update('devils-rps:anonymous:v1:').update(credential).digest('hex');
}

export async function authenticate(req: IncomingMessage) {
  const header = req.headers.authorization;
  if (!header) throw new ApiError(401, 'CREDENTIAL_MISSING', 'An anonymous credential is required.');
  const match = /^Bearer (anon_[A-Za-z0-9_-]{43})$/.exec(header);
  if (!match?.[1]) throw new ApiError(401, 'CREDENTIAL_INVALID', 'The anonymous credential is invalid.');
  const { players } = await collections();
  const player = await players.findOne({ credentialHash: credentialHash(match[1]), kind: 'human' });
  if (!player) throw new ApiError(401, 'CREDENTIAL_INVALID', 'The anonymous credential is invalid.');
  return player;
}
