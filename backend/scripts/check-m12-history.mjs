// One representative Godot-generated fixture; no database or gameplay writes.
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { createServer } from 'node:http';
import { route, jsonBody } from '../dist/src/http.js';
import { decodeEvent, hashText, validateHistoryChunks } from '../dist/src/history-upload.js';
import { validateHistory } from '../dist/src/settlement-rules.js';
const fixture = JSON.parse(readFileSync(process.argv[2] ?? '/tmp/m12-history-fixture.json', 'utf8'));
const { wire, expected } = fixture;
const header = JSON.parse(wire.headerJson);
const chunks = wire.chunks.map((encodedEvents, index) => ({ matchId: header.matchId, uploadId: wire.uploadId, index, encodedEvents, digest: hashText(encodedEvents) }));
const match = { matchId: header.matchId, bindings: header.actors.map(actor => ({ playerId: actor.actorId })) };
const decoded = chunks.flatMap(chunk => JSON.parse(chunk.encodedEvents).map(decodeEvent));
assert.deepEqual(decoded, expected);
const legacyActors = header.actors.map((actor, actorIndex) => ({ ...actor, events: decoded.filter(row => row.actorIndex === actorIndex).map(row => row.event) }));
const legacy = { ...header, actors: legacyActors };
const validated = validateHistory(legacy, header.matchId, header.actors.map(actor => actor.actorId));
assert.equal(validated.actors[0].events.length, 80);
assert.equal(Buffer.byteLength(JSON.stringify(legacy)) > 8192, true);
let index = 0;
const received = [];
const handler = route('POST', async req => {
  const body = await jsonBody(req, 64 * 1024);
  assert.equal(body.index, index++);
  received.push({ ...body, digest: hashText(body.encodedEvents) });
  return { body: { index: body.index } };
});
const server = createServer(handler);
await new Promise(resolve => server.listen(0, '127.0.0.1', resolve));
try {
  const origin = `http://127.0.0.1:${server.address().port}`;
  for (const chunk of chunks) {
    const response = await fetch(origin, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ matchId: header.matchId, uploadId: wire.uploadId, index: chunk.index, encodedEvents: chunk.encodedEvents }) });
    assert.equal(response.status, 200);
  }
  const result = await validateHistoryChunks(match, { ...wire }, (async function* () { yield* received; })());
  assert.equal(result.historyDigest, wire.historyDigest);
  assert.deepEqual(result.history.actors.map(actor => actor.finalCard), header.actors.map(actor => actor.finalCard));
  assert.equal(result.historyChunkCount, chunks.length);
  assert.equal(decoded.at(-1).event.kind, 'default');
  console.log(JSON.stringify({ status: 'passed', actors: [80, 61], eventsPreserved: decoded.length, richBytes: fixture.richBytes,
    previousWireBytes: Buffer.byteLength(JSON.stringify(legacy)), chunks: chunks.length,
    largestUploadBytes: Math.max(...chunks.map(chunk => Buffer.byteLength(JSON.stringify(chunk)))), historyDigest: result.historyDigest,
    databaseWrites: 0, liveGame: false }));
} finally { await new Promise(resolve => server.close(resolve)); }
