// ═══════════════════════════════════════════════════
// GUILD-LEARN — Utility Functions
// ═══════════════════════════════════════════════════

import { CONFIG } from '../store/state.js';

/**
 * Format a timestamp into a relative time string (e.g. "5 мин назад").
 */
export function timeAgo(timestamp) {
  const seconds = Math.floor((Date.now() - timestamp) / 1000);

  if (seconds < 60) return 'только что';
  if (seconds < 3600) {
    const m = Math.floor(seconds / 60);
    return `${m} мин назад`;
  }
  if (seconds < 86400) {
    const h = Math.floor(seconds / 3600);
    return `${h} ч назад`;
  }
  const d = Math.floor(seconds / 86400);
  return `${d} д назад`;
}

/**
 * Get the rank object for a given utility score.
 */
export function getRank(score) {
  const ranks = CONFIG.ranks;
  let rank = ranks[0];
  for (const r of ranks) {
    if (score >= r.minScore) rank = r;
  }
  return rank;
}

/**
 * Get the next rank and progress toward it.
 */
export function getRankProgress(score) {
  const ranks = CONFIG.ranks;
  let currentIdx = 0;
  for (let i = 0; i < ranks.length; i++) {
    if (score >= ranks[i].minScore) currentIdx = i;
  }
  const current = ranks[currentIdx];
  const next = ranks[currentIdx + 1] || null;

  if (!next) {
    return { current, next: null, progress: 1 };
  }

  const range = next.minScore - current.minScore;
  const filled = score - current.minScore;
  return { current, next, progress: Math.min(filled / range, 1) };
}

/**
 * Get the level and xp progress from total xp.
 */
export function getLevelProgress(level, xp) {
  const needed = CONFIG.xpPerLevel;
  return {
    level,
    xp,
    needed,
    progress: xp / needed,
  };
}

/**
 * Get subject config by id.
 */
export function getSubject(id) {
  return CONFIG.subjects.find(s => s.id === id) || CONFIG.subjects[0];
}

/**
 * Generate a unique ID.
 */
export function uid() {
  return 'sos_' + Date.now().toString(36) + '_' + Math.random().toString(36).slice(2, 7);
}

/**
 * Clamp a number between min and max.
 */
export function clamp(value, min, max) {
  return Math.max(min, Math.min(max, value));
}
