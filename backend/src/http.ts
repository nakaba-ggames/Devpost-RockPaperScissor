import type { IncomingMessage, ServerResponse } from 'node:http';
import { ApiError, badRequest } from './errors.js';
import { beginTiming, requestTimings, timingHeader } from './request-timing.js';

export type ApiRequest = IncomingMessage & { body?: unknown };
type Action = (req: ApiRequest, url: URL) => Promise<{ status?: number; body: unknown }>;

function crossOrigin(req: ApiRequest, res: ServerResponse): boolean {
  res.setHeader('Vary', 'Origin, Access-Control-Request-Method, Access-Control-Request-Headers');
  const origin = req.headers.origin;
  // Native clients have no Origin. Browser access uses an exact allowlist;
  // frontend deployment adds its actual HTTPS origin through server settings.
  const origins = new Set(['http://localhost:8125', 'http://127.0.0.1:8125']);
  for (const value of (process.env.CORS_ALLOWED_ORIGINS ?? '').split(',')) {
    const candidate = value.trim();
    try {
      const parsed = new URL(candidate);
      if (parsed.protocol === 'https:' && parsed.origin === candidate) origins.add(candidate);
    } catch { /* Ignore malformed settings; never broaden the origin policy. */ }
  }
  if (origin !== undefined && !origins.has(origin)) {
    throw new ApiError(403, 'ORIGIN_NOT_ALLOWED', 'This browser origin is not enabled.');
  }
  if (origin !== undefined) {
    res.setHeader('Access-Control-Allow-Origin', origin);
    res.setHeader('Access-Control-Expose-Headers', 'Server-Timing');
  }
  if (req.method !== 'OPTIONS') return false;
  const requestedMethod = req.headers['access-control-request-method'];
  const requestedHeaders = String(req.headers['access-control-request-headers'] ?? '')
    .split(',').map(value => value.trim().toLowerCase()).filter(Boolean);
  if (origin === undefined || !['GET', 'POST', 'PATCH'].includes(String(requestedMethod)) ||
      requestedHeaders.some(value => !['authorization', 'content-type', 'accept'].includes(value))) {
    throw new ApiError(403, 'PREFLIGHT_NOT_ALLOWED', 'Unsupported browser request.');
  }
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PATCH, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Authorization, Content-Type, Accept');
  res.statusCode = 204;
  res.end();
  return true;
}

export function route(method: string, action: Action) {
  return async (req: ApiRequest, res: ServerResponse) => {
    const timing = beginTiming();
    await requestTimings.run(timing, async () => {
      const send = (body: unknown) => {
        res.setHeader('Server-Timing', timingHeader(timing));
        res.end(JSON.stringify(body));
      };
      res.setHeader('Content-Type', 'application/json; charset=utf-8');
      res.setHeader('Cache-Control', 'no-store');
      res.setHeader('X-Content-Type-Options', 'nosniff');
      try {
        if (crossOrigin(req, res)) return;
        if (req.method !== method) {
          res.setHeader('Allow', method);
          throw new ApiError(405, 'METHOD_NOT_ALLOWED', `Use ${method}.`);
        }
        const result = await action(req, new URL(req.url ?? '/', 'http://localhost'));
        res.statusCode = result.status ?? 200;
        send(result.body);
      } catch (error) {
        if (error instanceof ApiError) {
          res.statusCode = error.status;
          send({ error: { code: error.code, message: error.message, retryable: error.retryable } });
          return;
        }
        // Never serialize driver errors, request bodies, Authorization, hashes or URIs.
        console.error('M10 API request failed (details withheld).');
        res.statusCode = 503;
        send({ error: { code: 'SERVICE_UNAVAILABLE', message: 'Saved data is temporarily unavailable.', retryable: true } });
      }
    });
  };
}

export async function jsonBody(req: ApiRequest, maximumBytes = 8192): Promise<Record<string, unknown>> {
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
      if (size > maximumBytes) throw new ApiError(413, 'BODY_TOO_LARGE', 'Request exceeds this route’s byte limit; history must be uploaded in chunks.');
      chunks.push(buffer);
    }
    body = Buffer.concat(chunks).toString('utf8');
  }
  if (typeof body === 'string') {
    if (Buffer.byteLength(body) > maximumBytes) throw new ApiError(413, 'BODY_TOO_LARGE', 'Request exceeds this route’s byte limit; history must be uploaded in chunks.');
    try { body = JSON.parse(body); } catch { badRequest('Body must be valid JSON.'); }
  }
  if (!body || typeof body !== 'object' || Array.isArray(body)) badRequest('Body must be an object.');
  if (Buffer.byteLength(JSON.stringify(body)) > maximumBytes) throw new ApiError(413, 'BODY_TOO_LARGE', 'Request exceeds this route’s byte limit; history must be uploaded in chunks.');
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
