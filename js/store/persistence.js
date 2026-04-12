// ═══════════════════════════════════════════════════
// GUILD-LEARN — Persistence Layer (localStorage)
// ═══════════════════════════════════════════════════

const STORAGE_KEY = 'guildlearn_state';

/**
 * Load the full state from localStorage.
 * Returns null if nothing is stored.
 */
export function loadState() {
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    return raw ? JSON.parse(raw) : null;
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
