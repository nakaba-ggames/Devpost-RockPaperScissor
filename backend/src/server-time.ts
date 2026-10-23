// Production callers use this default. Only an in-process verification harness may
// inject another function; no request, header, public route or environment clock.
export type ServerClock = () => Date;
export const serverClock: ServerClock = () => new Date();

const dayMsec = 86_400_000;
// 05:00 at fixed GMT+7 is 22:00 UTC on the preceding date.
const cutoffOffsetMsec = 2 * 3_600_000;
export function questPeriods(now: Date) {
  const shifted = new Date(now.getTime() + cutoffOffsetMsec);
  const day = Date.UTC(shifted.getUTCFullYear(), shifted.getUTCMonth(), shifted.getUTCDate()) - cutoffOffsetMsec;
  const daysSinceMonday = (shifted.getUTCDay() + 6) % 7;
  const week = day - daysSinceMonday * dayMsec;
  return {
    dayStart: new Date(day), dayEnd: new Date(day + dayMsec),
    weekStart: new Date(week), weekEnd: new Date(week + 7 * dayMsec)
  };
}
