import { AsyncLocalStorage } from 'node:async_hooks';
import { performance } from 'node:perf_hooks';

// Numeric durations only. Never retain requests, command documents or identities.
interface Timings { start: number; spans: Map<string, number>; commands: number }
export const requestTimings = new AsyncLocalStorage<Timings>();
export function beginTiming(): Timings {
  return { start: performance.now(), spans: new Map(), commands: 0 };
}
export async function timed<T>(name: string, work: () => Promise<T>): Promise<T> {
  const context = requestTimings.getStore();
  const start = performance.now();
  try { return await work(); }
  finally {
    if (context) context.spans.set(name, (context.spans.get(name) ?? 0) + performance.now() - start);
  }
}
export function timingHeader(context: Timings): string {
  return [`handler;dur=${(performance.now() - context.start).toFixed(1)}`,
    ...Array.from(context.spans, ([name, duration]) => `${name};dur=${duration.toFixed(1)}`),
    `commands;desc="${context.commands}"`].join(', ');
}
