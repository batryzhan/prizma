// ═══════════════════════════════════════════════════
// GUILD-LEARN — Sidebar Component
// ═══════════════════════════════════════════════════

import { getState } from '../store/state.js';
import { getRank, getRankProgress, getLevelProgress } from '../core/utils.js';
import { getI18n } from '../core/i18n.js';

/**
 * Render the sidebar with player profile, utility score, XP bar, energy, stats.
 */
export function renderSidebar() {
  const { user } = getState();
  const t = getI18n(user.lang);
  const rank = getRank(user.utilityScore);
  const rankProg = getRankProgress(user.utilityScore);
  const levelProg = getLevelProgress(user.level, user.xp);

  return `
    <div class="sidebar" id="sidebar">
      <!-- Logo & Lang -->
      <div class="sidebar__logo">
        <div class="sidebar__logo-icon">⚔</div>
        <div class="sidebar__logo-text glitch-hover">
          <span class="sidebar__logo-title">GUILD</span>
          <span class="sidebar__logo-subtitle">LEARN</span>
        </div>
        <button class="sidebar__lang-btn" id="btn-lang-toggle" title="Language / Язык">🌐</button>
      </div>

      <!-- Player Card -->
      <div class="sidebar__player">
        <div class="sidebar__avatar" id="player-avatar">
          ${user.avatarImage 
            ? `<img src="${user.avatarImage}" alt="${user.name}" style="width: 100%; height: 100%; object-fit: cover;">`
            : `<span>${user.avatar}</span>`
          }
          <div class="sidebar__avatar-ring"></div>
        </div>
        <div class="sidebar__player-info">
          <div class="sidebar__player-name" id="player-name">${user.name}</div>
          <div class="sidebar__player-rank">${rank.name}</div>
        </div>
        <button class="sidebar__edit-btn" id="btn-edit-profile" title="${t.sidebar.edit_profile}">✎</button>
      </div>

      <!-- Level / XP -->
      <div class="sidebar__section">
        <div class="sidebar__section-label">${t.sidebar.level}</div>
        <div class="xp-bar">
          <div class="xp-bar__fill" style="width: ${levelProg.progress * 100}%" id="xp-fill"></div>
        </div>
        <div class="xp-info">
          <span class="xp-info__level" id="xp-level">LVL ${levelProg.level}</span>
          <span id="xp-text">${levelProg.xp} / ${levelProg.needed} XP</span>
        </div>
      </div>

      <!-- Utility Score -->
      <div class="utility-score" id="utility-score-block">
        <div class="utility-score__label">${t.sidebar.utility}</div>
        <div class="utility-score__number" id="utility-score">${user.utilityScore}</div>
        <div class="utility-score__rank">${rank.name}${rankProg.next ? ` → ${rankProg.next.name}` : ` ${t.sidebar.rank_max}`}</div>
      </div>

      <!-- Energy -->
      <div class="sidebar__section">
        <div class="energy-meter">
          <div class="energy-meter__header">
            <span class="energy-meter__label">⚡ ${t.sidebar.energy}</span>
            <span class="energy-meter__value" id="energy-value">${user.energy}</span>
          </div>
          <div class="energy-meter__bar">
            <div class="energy-meter__fill" style="width: ${Math.min(user.energy, 100)}%" id="energy-fill"></div>
          </div>
        </div>
      </div>

      <!-- Stats -->
      <div class="sidebar__section">
        <div class="sidebar__section-label">${t.sidebar.stats}</div>
        <div class="stats-grid">
          <div class="stat-item">
            <span class="stat-item__value" id="stat-help-given">${user.helpGiven}</span>
            <span class="stat-item__label">${t.sidebar.help}</span>
          </div>
          <div class="stat-item">
            <span class="stat-item__value" id="stat-requests">${user.requestsCreated}</span>
            <span class="stat-item__label">${t.sidebar.requests}</span>
          </div>
        </div>
      </div>

      <!-- Spacer -->
      <div style="flex:1"></div>

      <!-- Reset -->
      <button class="btn btn--ghost btn--block sidebar__reset" id="btn-reset">
        ↻ ${t.sidebar.reset}
      </button>
    </div>
  `;
}

/**
 * Quick-update sidebar values without full re-render.
 */
export function updateSidebar() {
  const { user } = getState();
  const rank = getRank(user.utilityScore);
  const rankProg = getRankProgress(user.utilityScore);
  const levelProg = getLevelProgress(user.level, user.xp);

  const el = (id) => document.getElementById(id);

  const xpFill = el('xp-fill');
  if (xpFill) xpFill.style.width = `${levelProg.progress * 100}%`;

  const xpLevel = el('xp-level');
  if (xpLevel) xpLevel.textContent = `LVL ${levelProg.level}`;

  const xpText = el('xp-text');
  if (xpText) xpText.textContent = `${levelProg.xp} / ${levelProg.needed} XP`;

  const scoreEl = el('utility-score');
  if (scoreEl) scoreEl.textContent = user.utilityScore;

  const energyVal = el('energy-value');
  if (energyVal) energyVal.textContent = user.energy;

  const energyFill = el('energy-fill');
  if (energyFill) energyFill.style.width = `${Math.min(user.energy, 100)}%`;

  const helpGiven = el('stat-help-given');
  if (helpGiven) helpGiven.textContent = user.helpGiven;

  const requests = el('stat-requests');
  if (requests) requests.textContent = user.requestsCreated;

  const avatarEl = el('player-avatar');
  if (avatarEl) {
    avatarEl.innerHTML = user.avatarImage 
      ? `<img src="${user.avatarImage}" alt="${user.name}" style="width: 100%; height: 100%; object-fit: cover;">`
      : `<span>${user.avatar}</span>`;
    // Reinject the ring since we used innerHTML
    const ring = document.createElement('div');
    ring.className = 'sidebar__avatar-ring';
    avatarEl.appendChild(ring);
  }
}
