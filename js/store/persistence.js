// ═══════════════════════════════════════════════════
// GUILD-LEARN — Persistence Layer (localStorage)
// ═══════════════════════════════════════════════════

// v2 keeps Prizma data separate while still reading the old Guild-Learn key.
// That makes the redesign non-destructive for people who used the prototype.
const STORAGE_KEY = 'prizma:v2';
const LEGACY_STORAGE_KEY = 'guildlearn_state';

/**
 * Load the full state from localStorage.
 * Returns null if nothing is stored.
 */
export function loadState() {
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    if (raw) return JSON.parse(raw);

    const legacy = localStorage.getItem(LEGACY_STORAGE_KEY);
    return legacy ? JSON.parse(legacy) : null;
  } catch (e) {
    console.error('[Persistence] Failed to load state:', e);
    return null;
  }
}

/**
 * Save the full state object to localStorage.
 */
export function saveState(state) {
  try {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(state));
  } catch (e) {
    console.error('[Persistence] Failed to save state:', e);
  }
}

/**
 * Clear all stored data.
 */
export function clearState() {
  localStorage.removeItem(STORAGE_KEY);
  localStorage.removeItem(LEGACY_STORAGE_KEY);
}

/**
 * Update a specific key in the persisted state.
 */
export function updateState(key, value) {
  const state = loadState() || {};
  state[key] = value;
  saveState(state);
  return state;
}
