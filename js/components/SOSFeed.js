// ═══════════════════════════════════════════════════
// GUILD-LEARN — SOS Feed Component
// ═══════════════════════════════════════════════════

import { getState } from '../store/state.js';
import { getSubject, timeAgo } from '../core/utils.js';
import { getI18n } from '../core/i18n.js';

/**
 * Render the SOS feed list.
 * @param {string} [filter] - Subject filter id, or 'all'.
 * @param {string} [searchQuery] - Search text.
 */
export function renderSOSFeed(filter = 'all', searchQuery = '') {
  const { user, sosList } = getState();
  const t = getI18n(user.lang);

  let filtered = filter === 'all'
    ? sosList
    : sosList.filter(s => s.subject === filter);

  if (searchQuery) {
    const q = searchQuery.toLowerCase();
    filtered = filtered.filter(s => 
      s.question.toLowerCase().includes(q) || 
      s.author.toLowerCase().includes(q)
    );
  }

  let htmlContent = '';

  if (filtered.length === 0) {
    htmlContent = `
      <div class="sos-list--empty">
        <div class="empty-icon">📡</div>
        <div class="empty-text">${t.feed.empty}</div>
      </div>
    `;
  } else {
    const cards = filtered.map((sos, i) => renderSOSCard(sos, i)).join('');
    htmlContent = `<div class="sos-list">${cards}</div>`;
  }

  // Physics Subject Extra: Simulation Link
  if (filter === 'physics') {
    htmlContent += `
      <div class="physics-extra" style="margin-top: var(--space-2xl); padding: var(--space-xl); border: 1px dashed var(--neon-cyan); background: rgba(34, 211, 238, 0.03); text-align: center; animation: fadeIn 0.5s ease-out both;">
        <h3 style="font-family: var(--font-mono); font-size: var(--text-base); color: var(--neon-cyan); margin-bottom: var(--space-sm);">${t.feed.physics_module}</h3>
        <p style="font-size: var(--text-sm); color: var(--text-secondary); margin-bottom: var(--space-lg); max-width: 400px; margin-left: auto; margin-right: auto;">
          ${t.feed.physics_desc}
        </p>
        <a href="https://phet.colorado.edu/${user.lang}/simulations/filter?subjects=physics&type=html" target="_blank" class="btn btn--primary glitch-hover" style="text-decoration: none; display: inline-flex; align-items: center; gap: 8px;">
          <span>⚛ ${t.feed.physics_btn}</span>
        </a>
      </div>
    `;
  }

  return htmlContent;
}

/**
 * Render a single SOS card.
 */
function renderSOSCard(sos, index) {
  const subject = getSubject(sos.subject);
  const state = getState();
  const t = getI18n(state.user.lang);
  const isOwn = sos.author === state.user.name;

  return `
    <div class="sos-card ${sos.resolved ? 'sos-card--resolved' : ''}"
         data-sos-id="${sos.id}"
         style="animation-delay: ${index * 60}ms"
         id="sos-card-${sos.id}">
      <div class="sos-card__header">
        <span class="sos-card__subject sos-card__subject--${sos.subject}">
          <span>${subject.icon}</span>
          ${t.subjects[sos.subject] || subject.name}
        </span>
        <span class="sos-card__time">${timeAgo(sos.createdAt)}</span>
      </div>
      <div class="sos-card__body">
        <p class="sos-card__question">${escapeHtml(sos.question)}</p>
        <div class="sos-card__author">
          <div class="sos-card__author-avatar">
            ${sos.authorAvatarImage 
              ? `<img src="${sos.authorAvatarImage}" alt="${sos.author}" style="width: 100%; height: 100%; object-fit: cover;">`
              : `<span>${sos.authorAvatar}</span>`
            }
          </div>
          <span>${sos.author}</span>
        </div>
      </div>
      <div class="sos-card__footer">
        <span class="sos-card__reward">
          <span class="sos-card__reward-icon">⚡</span>
          ${sos.reward} ${t.feed.reward}
        </span>
        ${sos.resolved
          ? `<span class="sos-card__resolved-badge">${t.feed.resolved}</span>`
          : isOwn
            ? `<button class="btn btn--danger btn--sm" data-action="delete" data-sos-id="${sos.id}" id="btn-delete-${sos.id}"><span>${t.feed.delete_btn}</span></button>`
            : `<button class="btn-help" data-action="help" data-sos-id="${sos.id}" id="btn-help-${sos.id}"><span>${t.feed.help_btn}</span></button>`
        }
      </div>
    </div>
  `;
}

/**
 * Render feed header with filters and create button.
 */
export function renderFeedHeader(activeFilter = 'all', searchQuery = '') {
  const { user } = getState();
  const t = getI18n(user.lang);

  const filters = [
    { id: 'all', label: t.subjects.all },
    { id: 'math', label: '∑' },
    { id: 'physics', label: '⚛' },
    { id: 'biology', label: '🧬' },
    { id: 'chemistry', label: '⚗' },
    { id: 'history', label: '📜' },
    { id: 'english', label: '🌐' },
  ];

  const filterBtns = filters.map(f => `
    <button class="feed__filter-btn ${f.id === activeFilter ? 'feed__filter-btn--active' : ''}"
            data-filter="${f.id}" id="filter-${f.id}">
      ${f.label}
    </button>
  `).join('');

  return `
    <div class="feed__header" id="feed-header">
      <div class="feed__header-left">
        <h2 class="feed__title">${t.feed.title}</h2>
        <div style="display: flex; gap: var(--space-md); align-items: center; margin-top: var(--space-xs); flex-wrap: wrap;">
          <div class="feed__filters" id="feed-filters">
            ${filterBtns}
          </div>
          <input type="text" id="feed-search" class="form-input search-input" placeholder="${t.feed.search_placeholder}" value="${escapeHtml(searchQuery)}" style="width: 250px; padding: var(--space-xs) var(--space-sm); font-size: var(--text-sm); border-color: var(--neon-cyan-dim);">
        </div>
      </div>
      <button class="btn-create-sos glitch-hover" id="btn-create-sos">
        <span>${t.feed.create_btn}</span>
      </button>
    </div>
  `;
}

/**
 * Escape HTML to prevent XSS.
 */
function escapeHtml(str) {
  const div = document.createElement('div');
  div.textContent = str;
  return div.innerHTML;
}
