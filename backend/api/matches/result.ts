import type { ServerResponse } from 'node:http';
import type { ApiRequest } from '../../src/http.js';
import { m11Handlers } from '../../src/m11-api.js';
export default function result(req: ApiRequest, res: ServerResponse) {
  if (req.method === 'POST') return m11Handlers.departure(req, res);
  return m11Handlers.result(req, res);
}
