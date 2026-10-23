import { badRequest } from './errors.js';

export function pageLimit(url: URL) {
  const value = url.searchParams.get('limit');
  if (value === null) return 20;
  if (!/^[1-9]\d?$/.test(value) || Number(value) > 50) badRequest('limit must be 1–50.');
  return Number(value);
}

export function encodeCursor(value: object) {
  return Buffer.from(JSON.stringify(value)).toString('base64url');
}

export function decodeCursor(url: URL): Record<string, unknown> | null {
  const value = url.searchParams.get('cursor');
  if (value === null) return null;
  if (value.length > 1024 || !/^[A-Za-z0-9_-]+$/.test(value)) badRequest('Invalid cursor.');
  try {
    const decoded: unknown = JSON.parse(Buffer.from(value, 'base64url').toString('utf8'));
    if (!decoded || typeof decoded !== 'object' || Array.isArray(decoded)) badRequest('Invalid cursor.');
    return decoded as Record<string, unknown>;
  } catch { return badRequest('Invalid cursor.'); }
}

export function validPlayerId(value: unknown): value is string {
  return typeof value === 'string' && /^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/.test(value);
}
