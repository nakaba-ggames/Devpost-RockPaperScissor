import { releaseConfiguration } from './config.js';

// Stable seed keys preserve each bot's permanent profile and earned history.
export function botRoster(intro: boolean) {
  const names = intro ? releaseConfiguration.intro_bot_names : releaseConfiguration.regular_bot_names;
  return (names ?? []).map((displayName, index) => ({
    displayName, seedKey: `${releaseConfiguration.fallback_seed_key}:${intro ? 'intro' : 'regular'}:${index}`
  }));
}
