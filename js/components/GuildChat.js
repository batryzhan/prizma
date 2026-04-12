// ═══════════════════════════════════════════════════
// GUILD-LEARN — Guild Chat Widget (Right Panel)
// ═══════════════════════════════════════════════════

import { getState, setState } from '../store/state.js';
import { timeAgo } from '../core/utils.js';
import { getI18n } from '../core/i18n.js';

/**
 * Render the guild widget (member list + chat).
 */
export function renderGuildChat() {
  const { user, guild, chatMessages } = getState();
  const t = getI18n(user.lang);

  const online = guild.filter(g => g.status === 'online');
  const away = guild.filter(g => g.status === 'away');
  const offline = guild.filter(g => g.status === 'offline');

  const memberList = (members, statusLabel) => {
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

  const messages = chatMessages.map(msg => `
    <div class="chat__message">
      <span class="chat__message-author">${msg.from}</span>
      <span class="chat__message-text">${escapeHtml(msg.text)}</span>
      <span class="chat__message-time">${timeAgo(msg.time)}</span>
    </div>
  `).join('');

  return `
    <div class="widget" id="guild-widget">
      <!-- Header -->
      <div class="widget__header">
        <div class="widget__tabs">
          <button class="widget__tab widget__tab--active" data-tab="guild" id="tab-guild">
            ${t.guild.tab_guild}
          </button>
          <button class="widget__tab" data-tab="chat" id="tab-chat">
            ${t.guild.tab_chat}
          </button>
        </div>
      </div>

      <!-- Guild Tab -->
      <div class="widget__body widget__tab-content widget__tab-content--active" id="panel-guild">
        <div style="display: flex; align-items: center; justify-content: space-between; margin-bottom: var(--space-md);">
          <div class="guild__group-label" style="margin-bottom: 0;">${t.guild.title}</div>
          <button class="btn-add-member" id="btn-add-guild-member" title="${t.guild.add_member}" style="
            width: 24px;
            height: 24px;
            display: flex;
            align-items: center;
            justify-content: center;
            background: rgba(34, 211, 238, 0.1);
            border: 1px solid var(--neon-cyan);
            color: var(--neon-cyan);
            border-radius: var(--radius);
            font-size: 16px;
            font-weight: 700;
            cursor: pointer;
            transition: all var(--duration-fast) var(--ease-out);
          ">+</button>
        </div>
        <div class="guild__list" id="guild-list">
          ${memberList(online, t.guild.online)}
          ${memberList(away, t.guild.away)}
          ${memberList(offline, t.guild.offline)}
        </div>
      </div>

      <!-- Chat Tab -->
      <div class="widget__body widget__tab-content" id="panel-chat">
        <div class="chat__messages" id="chat-messages">
          ${messages}
        </div>
        <div class="chat__input-area">
          <input type="text" class="form-input chat__input" id="chat-input"
                 placeholder="${t.guild.chat_placeholder}" maxlength="200" />
          <button class="chat__send-btn" id="btn-send-chat">→</button>
        </div>
      </div>
    </div>
  `;
}

/**
 * Attach guild chat event listeners.
 */
export function attachGuildChatListeners() {
  const tabs = document.querySelectorAll('.widget__tab');
  const panels = document.querySelectorAll('.widget__tab-content');

  tabs.forEach(tab => {
    tab.addEventListener('click', () => {
      tabs.forEach(t => t.classList.remove('widget__tab--active'));
      panels.forEach(p => p.classList.remove('widget__tab-content--active'));
      tab.classList.add('widget__tab--active');
      const panel = document.getElementById(`panel-${tab.dataset.tab}`);
      if (panel) panel.classList.add('widget__tab-content--active');
    });
  });

  // Chat send
  const input = document.getElementById('chat-input');
  const sendBtn = document.getElementById('btn-send-chat');

  function sendMessage() {
    const text = input.value.trim();
    if (!text) return;

    const state = getState();

    setState(s => {
      s.chatMessages.push({
        from: s.user.name,
        text,
        time: Date.now(),
      });
      // Keep last 50
      if (s.chatMessages.length > 50) {
        s.chatMessages = s.chatMessages.slice(-50);
      }
    });

    input.value = '';
    updateChatMessages();
  }

  if (sendBtn) sendBtn.addEventListener('click', sendMessage);
  if (input) {
    input.addEventListener('keydown', (e) => {
      if (e.key === 'Enter') sendMessage();
    });
  }

  // Add Guild Member
  const addMemberBtn = document.getElementById('btn-add-guild-member');
  if (addMemberBtn) {
    addMemberBtn.addEventListener('click', () => {
      openAddMemberModal();
    });
  }
}

/**
 * Open Modal to add a new guild member.
 */
function openAddMemberModal() {
  const { user } = getState();
  const t = getI18n(user.lang);

  const html = `
    <div class="modal-overlay" id="guild-modal-overlay">
      <div class="modal-panel">
        <div class="sos-form__title">
          <span>+</span> ${t.guild.add_member}
        </div>
        <form id="guild-add-form">
          <div class="form-group">
            <label class="form-label" for="member-name">${t.guild.member_name}</label>
            <input type="text" class="form-input" id="member-name" maxlength="20" required placeholder="Напр. Cyber_Cat" />
          </div>
          <div class="form-group">
            <label class="form-label" for="member-score">${t.guild.member_score}</label>
            <input type="number" class="form-input" id="member-score" min="0" max="9999" value="100" required />
          </div>
          <div class="form-group">
            <label class="form-label" for="member-status">${t.guild.member_status}</label>
            <select id="member-status" class="form-input">
              <option value="online">${t.guild.online}</option>
              <option value="away">${t.guild.away}</option>
              <option value="offline">${t.guild.offline}</option>
            </select>
          </div>
          <div class="sos-form__actions">
            <button type="button" class="btn btn--secondary" id="btn-cancel-guild">${t.guild.btn_cancel}</button>
            <button type="submit" class="btn btn--primary">${t.guild.btn_add}</button>
          </div>
        </form>
      </div>
    </div>
  `;

  document.body.insertAdjacentHTML('beforeend', html);

  const overlay = document.getElementById('guild-modal-overlay');
  const cancelBtn = document.getElementById('btn-cancel-guild');
  const form = document.getElementById('guild-add-form');

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
    const name = document.getElementById('member-name').value.trim();
    const score = parseInt(document.getElementById('member-score').value) || 0;
    const status = document.getElementById('member-status').value;

    if (!name) return;

    setState(s => {
      s.guild.push({
        id: 'g_' + Date.now(),
        name,
        status,
        avatar: name.charAt(0).toUpperCase(),
        score,
      });
    });

    close();
  });
}

/**
 * Refresh chat messages display.
 */
function updateChatMessages() {
  const container = document.getElementById('chat-messages');
  if (!container) return;

  const { chatMessages } = getState();
  container.innerHTML = chatMessages.map(msg => `
    <div class="chat__message">
      <span class="chat__message-author">${msg.from}</span>
      <span class="chat__message-text">${escapeHtml(msg.text)}</span>
      <span class="chat__message-time">${timeAgo(msg.time)}</span>
    </div>
  `).join('');

  container.scrollTop = container.scrollHeight;
}

function escapeHtml(str) {
  const div = document.createElement('div');
  div.textContent = str;
  return div.innerHTML;
}
