// ═══════════════════════════════════════════════════
// GUILD-LEARN — Main App / Router
// ═══════════════════════════════════════════════════

import { initState, getState, setState, subscribe } from './store/state.js';
import { clearState } from './store/persistence.js';
import { renderSidebar, updateSidebar } from './components/Sidebar.js';
import { renderSOSFeed, renderFeedHeader } from './components/SOSFeed.js';
import { renderSOSForm, attachSOSFormListeners } from './components/SOSForm.js';
import { renderGuildChat, attachGuildChatListeners } from './components/GuildChat.js';
import { helpWithRequest, deleteSOSRequest } from './core/engine.js';
import { getI18n } from './core/i18n.js';

// ── State ──
let activeFilter = 'all';
let searchQuery = '';

// ── Init ──
document.addEventListener('DOMContentLoaded', () => {
  initState();
  renderApp();
  subscribe(() => {
    refreshFeed();
    updateSidebar();
    refreshGuild();
  });

  // Energy Regeneration: +1 Energy every 15 seconds, up to 100
  setInterval(() => {
    const s = getState();
    if (s.user.energy < 100) {
      setState(st => {
        st.user.energy += 1;
      });
    }
  }, 15000);
});

// ── Full App Render ──
function renderApp() {
  const app = document.getElementById('app');
  const state = getState();

  app.innerHTML = `
    ${renderSidebar()}
    <div class="feed" id="feed-panel">
      ${renderFeedHeader(activeFilter, searchQuery)}
      <div class="feed__body" id="feed-body">
        ${renderSOSFeed(activeFilter, searchQuery)}
      </div>
    </div>
    ${renderGuildChat()}
  `;

  attachAllListeners();
}

// ── Refresh just the feed body ──
function refreshFeed() {
  const feedBody = document.getElementById('feed-body');
  if (feedBody) {
    feedBody.innerHTML = renderSOSFeed(activeFilter, searchQuery);
    attachFeedCardListeners();
  }
}

// ── Refresh just the guild list ──
function refreshGuild() {
  const guildList = document.getElementById('guild-list');
  if (guildList) {
    const { user, guild } = getState();
    const t = getI18n(user.lang);
    const online = guild.filter(g => g.status === 'online');
    const away = guild.filter(g => g.status === 'away');
    const offline = guild.filter(g => g.status === 'offline');

    const memberListHTML = (members, statusLabel) => {
      if (members.length === 0) return '';
      return `
        <div class="guild__group">
          <div class="guild__group-label">${statusLabel} — ${members.length}</div>
          ${members.map(m => `
            <div class="guild__member" data-member-id="${m.id}">
              <div class="guild__member-avatar guild__member-avatar--${m.status}">${m.avatar}</div>
              <div class="guild__member-info">
                <span class="guild__member-name">${m.name}</span>
                <span class="guild__member-score">⚡${m.score}</span>
              </div>
            </div>
          `).join('')}
        </div>
      `;
    };

    guildList.innerHTML = `
      ${memberListHTML(online, t.guild.online)}
      ${memberListHTML(away, t.guild.away)}
      ${memberListHTML(offline, t.guild.offline)}
    `;
  }
}

// ── Attach all event listeners ──
function attachAllListeners() {
  attachFeedCardListeners();
  attachFilterListeners();
  attachSearchListeners();
  attachCreateSOSListener();
  attachGuildChatListeners();
  attachSidebarListeners();
  attachLangListener();
}

// ── Language Toggle ──
function attachLangListener() {
  const btn = document.getElementById('btn-lang-toggle');
  if (btn) {
    btn.addEventListener('click', openLangModal);
  }
}

function openLangModal() {
  const { user } = getState();
  const html = `
    <div class="modal-overlay" id="lang-modal-overlay">
      <div class="modal-panel" style="max-width: 320px;">
        <div class="sos-form__title">
          <span>🌐</span> Language / Язык
        </div>
        <div style="display: flex; flex-direction: column; gap: var(--space-md); margin-top: var(--space-lg);">
          <button class="btn btn--secondary lang-option ${user.lang === 'ru' ? 'btn--primary' : ''}" data-lang="ru">
            🇷🇺 Русский (Russian)
          </button>
          <button class="btn btn--secondary lang-option ${user.lang === 'en' ? 'btn--primary' : ''}" data-lang="en">
            🇺🇸 English (Английский)
          </button>
        </div>
        <div class="sos-form__actions" style="margin-top: var(--space-xl);">
          <button type="button" class="btn btn--ghost" id="btn-cancel-lang">Close / Закрыть</button>
        </div>
      </div>
    </div>
  `;

  document.body.insertAdjacentHTML('beforeend', html);

  const overlay = document.getElementById('lang-modal-overlay');
  const cancelBtn = document.getElementById('btn-cancel-lang');

  const close = () => {
    overlay.style.opacity = '0';
    setTimeout(() => overlay.remove(), 150);
  };

  cancelBtn.addEventListener('click', close);
  overlay.addEventListener('click', (e) => {
    if (e.target === overlay) close();
    const btn = e.target.closest('.lang-option');
    if (btn) {
      const lang = btn.dataset.lang;
      setState(s => {
        s.user.lang = lang;
      });
      close();
      renderApp();
    }
  });
}

// ── Search Listener ──
function attachSearchListeners() {
  const searchInput = document.getElementById('feed-search');
  if (!searchInput) return;

  searchInput.addEventListener('input', (e) => {
    searchQuery = e.target.value;
    refreshFeed();
  });
}

// ── Feed card action listeners (help / delete) ──
function attachFeedCardListeners() {
  const feedBody = document.getElementById('feed-body');
  if (!feedBody) return;

  feedBody.addEventListener('click', (e) => {
    const btn = e.target.closest('[data-action]');
    if (!btn) return;

    const action = btn.dataset.action;
    const sosId = btn.dataset.sosId;

    if (action === 'help') {
      // Add a micro-animation
      const card = btn.closest('.sos-card');
      if (card) {
        card.style.transition = 'all 0.3s ease';
        card.style.boxShadow = '0 0 40px rgba(34,211,238,.4)';
      }
      setTimeout(() => {
        helpWithRequest(sosId);
      }, 200);
    }

    if (action === 'delete') {
      deleteSOSRequest(sosId);
    }
  });
}

// ── Filter listeners ──
function attachFilterListeners() {
  const filtersContainer = document.getElementById('feed-filters');
  if (!filtersContainer) return;

  filtersContainer.addEventListener('click', (e) => {
    const btn = e.target.closest('[data-filter]');
    if (!btn) return;

    activeFilter = btn.dataset.filter;

    // Update active state
    filtersContainer.querySelectorAll('.feed__filter-btn').forEach(b =>
      b.classList.remove('feed__filter-btn--active')
    );
    btn.classList.add('feed__filter-btn--active');

    refreshFeed();
  });
}

// ── Create SOS button ──
function attachCreateSOSListener() {
  const createBtn = document.getElementById('btn-create-sos');
  if (!createBtn) return;

  createBtn.addEventListener('click', () => {
    openSOSModal();
  });
}

// ── SOS Modal ──
function openSOSModal() {
  // Insert the modal
  const modalHTML = renderSOSForm();
  document.body.insertAdjacentHTML('beforeend', modalHTML);

  attachSOSFormListeners(() => {
    closeSOSModal();
    refreshFeed();
    updateSidebar();
  });

  // Focus the textarea
  setTimeout(() => {
    const textarea = document.getElementById('sos-question');
    if (textarea) textarea.focus();
  }, 100);
}

function closeSOSModal() {
  const overlay = document.getElementById('sos-modal-overlay');
  if (overlay) {
    overlay.style.opacity = '0';
    setTimeout(() => overlay.remove(), 150);
  }
}

// ── Sidebar listeners ──
function attachSidebarListeners() {
  const { user } = getState();
  const t = getI18n(user.lang);

  // Reset button
  const resetBtn = document.getElementById('btn-reset');
  if (resetBtn) {
    resetBtn.addEventListener('click', () => {
      if (confirm(t.modal.reset_confirm)) {
        clearState();
        initState();
        renderApp();
        showToast(t.modal.toast_reset, 'info');
      }
    });
  }

  // Edit profile
  const editBtn = document.getElementById('btn-edit-profile');
  if (editBtn) {
    editBtn.addEventListener('click', () => {
      openProfileModal();
    });
  }
}

// ── Profile Edit Modal ──
function openProfileModal() {
  const { user } = getState();
  const t = getI18n(user.lang);

  const html = `
    <div class="modal-overlay" id="profile-modal-overlay">
      <div class="modal-panel">
        <div class="sos-form__title">
          <span>✎</span> ${t.modal.profile_title}
        </div>
        <form id="profile-form">
          <div class="form-group">
            <label class="form-label" for="profile-name">${t.modal.player_name}</label>
            <input type="text" class="form-input" id="profile-name"
                   value="${user.name}" maxlength="20" required />
          </div>
          <div class="form-group">
            <label class="form-label" for="profile-avatar">${t.modal.avatar_symbol}</label>
            <input type="text" class="form-input" id="profile-avatar"
                   value="${user.avatar}" maxlength="2" required />
          </div>
          <div class="form-group">
            <label class="form-label" for="profile-avatar-url">${t.modal.avatar_url}</label>
            <input type="text" class="form-input" id="profile-avatar-url"
                   value="${user.avatarImage || ''}" placeholder="https://..." />
          </div>
          <div class="form-group">
            <label class="form-label">${t.modal.avatar_file}</label>
            <input type="file" id="profile-avatar-file" accept="image/*" class="form-input" style="padding: 10px;" />
          </div>
          <div class="sos-form__actions">
            <button type="button" class="btn btn--secondary" id="btn-cancel-profile">${t.modal.btn_cancel}</button>
            <button type="submit" class="btn btn--primary" id="btn-save-profile">${t.modal.btn_save}</button>
          </div>
        </form>
      </div>
    </div>
  `;

  document.body.insertAdjacentHTML('beforeend', html);

  const overlay = document.getElementById('profile-modal-overlay');
  const cancelBtn = document.getElementById('btn-cancel-profile');
  const form = document.getElementById('profile-form');
  const fileInput = document.getElementById('profile-avatar-file');

  const close = () => {
    overlay.style.opacity = '0';
    setTimeout(() => overlay.remove(), 150);
  };

  cancelBtn.addEventListener('click', close);
  overlay.addEventListener('click', (e) => {
    if (e.target === overlay) close();
  });

  form.addEventListener('submit', (e) => {
    e.preventDefault();
    const name = document.getElementById('profile-name').value.trim();
    const avatarChar = document.getElementById('profile-avatar').value.trim();
    const avatarUrl = document.getElementById('profile-avatar-url').value.trim();
    const file = fileInput.files[0];

    if (!name || !avatarChar) return;

    const finalize = (imgData) => {
      setState(s => {
        s.user.name = name;
        s.user.avatar = avatarChar.charAt(0).toUpperCase();
        s.user.avatarImage = imgData || null;
      });
      close();
      renderApp();
      showToast(t.modal.toast_save, 'success');
    };

    if (file) {
      const reader = new FileReader();
      reader.onload = (ev) => finalize(ev.target.result);
      reader.readAsDataURL(file);
    } else {
      finalize(avatarUrl);
    }
  });
}

// ── Toast System ──
export function showToast(message, type = 'info') {
  let container = document.getElementById('toast-container');
  if (!container) {
    container = document.createElement('div');
    container.id = 'toast-container';
    container.className = 'toast-container';
    document.body.appendChild(container);
  }

  const icons = {
    success: '✓',
    error: '✕',
    info: 'ℹ',
  };

  const toast = document.createElement('div');
  toast.className = `toast toast--${type}`;
  toast.innerHTML = `<span>${icons[type] || 'ℹ'}</span> ${message}`;
  container.appendChild(toast);

  setTimeout(() => {
    toast.style.opacity = '0';
    toast.style.transform = 'translateX(20px)';
    toast.style.transition = 'all 0.3s ease';
    setTimeout(() => toast.remove(), 300);
  }, 3000);
}
