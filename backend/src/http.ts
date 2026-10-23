import type { IncomingMessage, ServerResponse } from 'node:http';
import { ApiError, badRequest } from './errors.js';

export type ApiRequest = IncomingMessage & { body?: unknown };
type Action = (req: ApiRequest, url: URL) => Promise<{ status?: number; body: unknown }>;

export function route(method: string, action: Action) {
  return async (req: ApiRequest, res: ServerResponse) => {
    res.setHeader('Content-Type', 'application/json; charset=utf-8');
    res.setHeader('Cache-Control', 'no-store');
    res.setHeader('X-Content-Type-Options', 'nosniff');
    try {
      if (req.method !== method) {
        res.setHeader('Allow', method);
        throw new ApiError(405, 'METHOD_NOT_ALLOWED', `Use ${method}.`);
      }
      const result = await action(req, new URL(req.url ?? '/', 'http://localhost'));
      res.statusCode = result.status ?? 200;
      res.end(JSON.stringify(result.body));
    } catch (error) {
      if (error instanceof ApiError) {
        res.statusCode = error.status;
        res.end(JSON.stringify({ error: { code: error.code, message: error.message, retryable: error.retryable } }));
        return;
      }
      // Never serialize driver errors, request bodies, Authorization, hashes or URIs.
      console.error('M10 API request failed (details withheld).');
      res.statusCode = 503;
      res.end(JSON.stringify({ error: { code: 'SERVICE_UNAVAILABLE', message: 'Saved data is temporarily unavailable.', retryable: true } }));
    }
  };
}

export async function jsonBody(req: ApiRequest): Promise<Record<string, unknown>> {
  if (req.headers['content-type']?.split(';')[0]?.trim() !== 'application/json') {
    throw new ApiError(415, 'JSON_REQUIRED', 'Use application/json.');
  }
  let body: unknown = req.body;
  if (body === undefined) {
    const chunks: Buffer[] = [];
    let size = 0;
    for await (const chunk of req) {
      const buffer = Buffer.from(chunk);
      size += buffer.length;
      if (size > 8192) throw new ApiError(413, 'BODY_TOO_LARGE', 'Request body exceeds 8 KiB.');
      chunks.push(buffer);
    }
    body = Buffer.concat(chunks).toString('utf8');
  }
  if (typeof body === 'string') {
    if (Buffer.byteLength(body) > 8192) throw new ApiError(413, 'BODY_TOO_LARGE', 'Request body exceeds 8 KiB.');
    try { body = JSON.parse(body); } catch { badRequest('Body must be valid JSON.'); }
  }
  if (!body || typeof body !== 'object' || Array.isArray(body)) badRequest('Body must be an object.');
  if (Buffer.byteLength(JSON.stringify(body)) > 8192) throw new ApiError(413, 'BODY_TOO_LARGE', 'Request body exceeds 8 KiB.');
  return body as Record<string, unknown>;
}

export function onlyKeys(body: Record<string, unknown>, keys: string[]) {
  if (Object.keys(body).some(key => !keys.includes(key))) badRequest('Unexpected request field.');
}

export function onlyQuery(url: URL, keys: string[]) {
  for (const key of url.searchParams.keys()) {
    if (!keys.includes(key) || url.searchParams.getAll(key).length !== 1) badRequest('Unexpected or repeated query parameter.');
  }
}
