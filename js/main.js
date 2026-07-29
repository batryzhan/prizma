// Prizma application bootstrap.
// The UI is intentionally framework-free: a small hash router composes public
// and dashboard layouts while the existing store remains the single source of truth.

import { CONFIG, getState, initState, setState, subscribe } from './store/state.js';
import { clearState } from './store/persistence.js';
import { createSOSRequest, deleteSOSRequest, helpWithRequest } from './core/engine.js';
import { icon } from './app/icons.js';
import { normaliseRoute, renderAppShell, renderLanding, renderNotFound } from './app/layout.js';
import { showToast } from './app/notifications.js';
import { renderRoutePage, renderSosResults } from './app/pages.js';
import { escapeHtml } from './app/renderers.js';

const PREFS_KEY = 'prizma_ui_preferences';
const app = document.getElementById('app');

const ui = {
  requestFilter: 'all',
  requestSearch: '',
  sidebarOpen: false,
  theme: 'light',
  reduceMotion: false,
  completedTasks: [],
};

function loadPreferences() {
  try {
    const saved = JSON.parse(localStorage.getItem(PREFS_KEY) || '{}');
    if (saved.theme === 'dark' || saved.theme === 'light') ui.theme = saved.theme;
    ui.reduceMotion = Boolean(saved.reduceMotion);
    ui.completedTasks = Array.isArray(saved.completedTasks) ? saved.completedTasks : [];
  } catch {
    // A broken local preference should never block the learning space.
  }
}

function savePreferences() {
  localStorage.setItem(PREFS_KEY, JSON.stringify({
    theme: ui.theme,
    reduceMotion: ui.reduceMotion,
    completedTasks: ui.completedTasks,
  }));
}

function applyPreferences() {
  document.documentElement.dataset.theme = ui.theme;
  document.documentElement.classList.toggle('reduce-motion', ui.reduceMotion);
}

function routeTitle(route) {
  const titles = {
    landing: 'Prizma — учиться в своём ритме',
    dashboard: 'Обзор — Prizma',
    sos: 'SOS-запросы — Prizma',
    subjects: 'Предметы — Prizma',
    guild: 'Гильдия — Prizma',
    leaderboard: 'Рейтинг — Prizma',
    progress: 'Прогресс — Prizma',
    profile: 'Профиль — Prizma',
    settings: 'Настройки — Prizma',
  };
  return titles[route] || 'Prizma';
}

function render() {
  const route = normaliseRoute();
  const state = getState();
  document.title = routeTitle(route);
  document.body.classList.toggle('body--app', route !== 'landing' && route !== 'not-found');
  document.body.classList.toggle('body--landing', route === 'landing');

  if (route === 'landing') {
    app.innerHTML = renderLanding(state, ui);
  } else if (route === 'not-found') {
    app.innerHTML = renderNotFound();
  } else {
    app.innerHTML = renderAppShell(route, renderRoutePage(route, state, ui), state, ui);
  }
}

function navigate(route) {
  const target = route === 'landing' ? '#/' : `#/${route}`;
  ui.sidebarOpen = false;
  if (window.location.hash === target) {
    render();
  } else {
    window.location.hash = target;
  }
}

function openModal(id, content) {
  closeModal();
  document.body.insertAdjacentHTML('beforeend', `<div class="modal-backdrop" id="${id}" role="presentation"><section class="modal" role="dialog" aria-modal="true" aria-labelledby="${id}-title">${content}</section></div>`);
  const focusTarget = document.querySelector(`#${id} input, #${id} textarea, #${id} select, #${id} button`);
  if (focusTarget) setTimeout(() => focusTarget.focus(), 0);
}

function closeModal() {
  document.querySelectorAll('.modal-backdrop').forEach(element => element.remove());
}

function openSosModal() {
  const { user } = getState();
  openModal('sos-modal', `<div class="modal__head"><div><span class="eyebrow">Новый SOS-запрос</span><h2 id="sos-modal-title">Давай распутаем задачу</h2></div><button class="icon-button" data-action="close-modal" type="button" aria-label="Закрыть">${icon('close', 20)}</button></div>
    <p class="modal__intro">Чем яснее контекст, тем легче гильдии дать полезный ответ.</p>
    <form class="modal-form" id="sos-form">
      <label class="form-label"><span>Предмет</span><select id="sos-subject" name="subject">${CONFIG.subjects.map(subject => `<option value="${subject.id}">${subject.icon} ${escapeHtml(subject.name)}</option>`).join('')}</select></label>
      <label class="form-label"><span>В чём нужна помощь?</span><textarea id="sos-question" name="question" minlength="10" maxlength="500" required placeholder="Например: не понимаю, с чего начать решать систему уравнений…"></textarea><small class="form-count"><span id="sos-char-count">0</span> / 500</small></label>
      <fieldset class="reward-picker"><legend>Награда за помощь <em>У тебя ${Number(user.energy) || 0} энергии</em></legend><div>${CONFIG.energyCosts.map((cost, index) => `<button class="reward-option ${index === 0 ? 'reward-option--active' : ''}" type="button" data-action="choose-reward" data-reward="${cost}"><strong>${icon('bolt', 15)} ${cost}</strong><span>${['Быстрый вопрос', 'Нужно объяснение', 'Сложная задача', 'Большой разбор'][index]}</span></button>`).join('')}</div></fieldset>
      <input type="hidden" id="sos-reward" value="${CONFIG.energyCosts[0]}">
      <div class="modal-form__actions"><button class="button button--ghost" type="button" data-action="close-modal">Отмена</button><button class="button button--primary" type="submit">Отправить запрос ${icon('arrowUpRight', 16)}</button></div>
    </form>`);
}

function openProfileModal() {
  const { user } = getState();
  openModal('profile-modal', `<div class="modal__head"><div><span class="eyebrow">Твой профиль</span><h2 id="profile-modal-title">Как к тебе обращаться?</h2></div><button class="icon-button" data-action="close-modal" type="button" aria-label="Закрыть">${icon('close', 20)}</button></div>
    <form class="modal-form" id="profile-form"><label class="form-label"><span>Имя в Prizma</span><input id="profile-name" type="text" maxlength="20" required value="${escapeHtml(user.name || '')}" placeholder="Например, Алия"></label><label class="form-label"><span>Инициалы на аватаре</span><input id="profile-avatar" type="text" maxlength="2" required value="${escapeHtml(user.avatar || '')}" placeholder="А"></label><p class="form-note">Аватар сохраняется в браузере. Здесь можно оставить только понятные инициалы — так сообществу проще тебя узнать.</p><div class="modal-form__actions"><button class="button button--ghost" type="button" data-action="close-modal">Отмена</button><button class="button button--primary" type="submit">Сохранить ${icon('check', 16)}</button></div></form>`);
}

function openMemberModal() {
  openModal('member-modal', `<div class="modal__head"><div><span class="eyebrow">Новый участник</span><h2 id="member-modal-title">Пригласить в гильдию</h2></div><button class="icon-button" data-action="close-modal" type="button" aria-label="Закрыть">${icon('close', 20)}</button></div>
    <form class="modal-form" id="member-form"><label class="form-label"><span>Имя</span><input id="member-name" type="text" maxlength="20" required placeholder="Например, Sana_02"></label><div class="form-two-columns"><label class="form-label"><span>Вклад</span><input id="member-score" type="number" min="0" max="9999" value="100" required></label><label class="form-label"><span>Статус</span><select id="member-status"><option value="online">В сети</option><option value="away">Отошёл</option><option value="offline">Не в сети</option></select></label></div><div class="modal-form__actions"><button class="button button--ghost" type="button" data-action="close-modal">Отмена</button><button class="button button--primary" type="submit">Добавить ${icon('plus', 16)}</button></div></form>`);
}

function selectedReward(button) {
  const value = Number(button.dataset.reward);
  const hidden = document.getElementById('sos-reward');
  if (hidden && CONFIG.energyCosts.includes(value)) hidden.value = String(value);
  document.querySelectorAll('.reward-option').forEach(option => option.classList.toggle('reward-option--active', option === button));
}

function handleAction(action, target) {
  switch (action) {
    case 'toggle-sidebar':
      ui.sidebarOpen = !ui.sidebarOpen;
      render();
      break;
    case 'toggle-theme':
      ui.theme = ui.theme === 'dark' ? 'light' : 'dark';
      savePreferences();
      applyPreferences();
      render();
      break;
    case 'toggle-motion':
      ui.reduceMotion = !ui.reduceMotion;
      savePreferences();
      applyPreferences();
      render();
      break;
    case 'focus-global-search':
      navigate('sos');
      setTimeout(() => document.getElementById('request-search')?.focus(), 50);
      break;
    case 'scroll-to': {
      const section = document.getElementById(target.dataset.section);
      section?.scrollIntoView({ behavior: ui.reduceMotion ? 'auto' : 'smooth', block: 'start' });
      break;
    }
    case 'show-notifications':
      showToast('Новых личных уведомлений пока нет. Лента SOS уже ждёт тебя.', 'info');
      break;
    case 'create-sos':
      openSosModal();
      break;
    case 'close-modal':
      closeModal();
      break;
    case 'choose-reward':
      selectedReward(target);
      break;
    case 'help-sos':
      helpWithRequest(target.dataset.sosId);
      break;
    case 'delete-sos':
      if (window.confirm('Удалить этот SOS-запрос? Энергия вернётся на баланс.')) deleteSOSRequest(target.dataset.sosId);
      break;
    case 'filter-sos':
      ui.requestFilter = target.dataset.filter || 'all';
      render();
      break;
    case 'clear-request-filters':
      ui.requestFilter = 'all';
      ui.requestSearch = '';
      render();
      break;
    case 'sort-sos':
      showToast('Лента уже отсортирована: сначала новые и открытые запросы.', 'info');
      break;
    case 'view-subject-requests':
      ui.requestFilter = target.dataset.subjectId || 'all';
      ui.requestSearch = '';
      navigate('sos');
      break;
    case 'open-resource':
      showToast(`Материал «${target.dataset.resource || 'ресурс'}» появится в следующем модуле.`, 'info');
      break;
    case 'open-add-member':
      openMemberModal();
      break;
    case 'toggle-task': {
      const id = target.dataset.taskId;
      if (!id) break;
      ui.completedTasks = ui.completedTasks.includes(id)
        ? ui.completedTasks.filter(taskId => taskId !== id)
        : [...ui.completedTasks, id];
      savePreferences();
      render();
      break;
    }
    case 'show-weekly-chart':
      showToast('График показывает локальную учебную активность за последние 7 дней.', 'info');
      break;
    case 'show-calendar-day':
      showToast(`День ${target.dataset.day}: добавь свой учебный блок в ближайшем обновлении.`, 'info');
      break;
    case 'edit-profile':
      openProfileModal();
      break;
    case 'export-data':
      exportData();
      break;
    case 'reset-data':
      resetData();
      break;
    default:
      break;
  }
}

function submitSos(form) {
  const subject = document.getElementById('sos-subject')?.value;
  const question = document.getElementById('sos-question')?.value.trim();
  const reward = Number(document.getElementById('sos-reward')?.value);
  if (!subject || !question || question.length < 10 || !CONFIG.energyCosts.includes(reward)) return;
  if (createSOSRequest({ subject, question, reward })) closeModal();
}

function submitProfile() {
  const name = document.getElementById('profile-name')?.value.trim();
  const avatar = document.getElementById('profile-avatar')?.value.trim();
  if (!name || !avatar) return;
  setState(state => {
    state.user.name = name.slice(0, 20);
    state.user.avatar = avatar.slice(0, 2).toUpperCase();
  });
  closeModal();
  showToast('Профиль обновлён.', 'success');
}

function submitMember() {
  const name = document.getElementById('member-name')?.value.trim();
  const score = Math.max(0, Math.min(9999, Number(document.getElementById('member-score')?.value) || 0));
  const status = document.getElementById('member-status')?.value;
  if (!name || !['online', 'away', 'offline'].includes(status)) return;
  setState(state => {
    state.guild.push({
      id: `guild_${Date.now().toString(36)}`,
      name: name.slice(0, 20),
      avatar: name.slice(0, 1).toUpperCase(),
      score,
      status,
    });
  });
  closeModal();
  showToast(`${name} теперь в гильдии.`, 'success');
}

function submitChat() {
  const input = document.getElementById('guild-chat-input');
  const text = input?.value.trim();
  if (!text) return;
  setState(state => {
    state.chatMessages = [...(state.chatMessages || []), {
      from: state.user.name,
      text: text.slice(0, 200),
      time: Date.now(),
    }].slice(-50);
  });
}

function exportData() {
  const payload = {
    exportedAt: new Date().toISOString(),
    app: 'Prizma',
    state: getState(),
    preferences: { theme: ui.theme, reduceMotion: ui.reduceMotion, completedTasks: ui.completedTasks },
  };
  const blob = new Blob([JSON.stringify(payload, null, 2)], { type: 'application/json' });
  const href = URL.createObjectURL(blob);
  const link = document.createElement('a');
  link.href = href;
  link.download = `prizma-backup-${new Date().toISOString().slice(0, 10)}.json`;
  document.body.appendChild(link);
  link.click();
  link.remove();
  URL.revokeObjectURL(href);
  showToast('Локальная копия данных скачана.', 'success');
}

function resetData() {
  if (!window.confirm('Сбросить локальные данные Prizma? Это действие нельзя отменить без ранее скачанной копии.')) return;
  clearState();
  initState();
  ui.completedTasks = [];
  savePreferences();
  render();
  showToast('Prizma начала с чистого листа.', 'info');
}

function handleClick(event) {
  const routeButton = event.target.closest('[data-route]');
  if (routeButton) {
    event.preventDefault();
    navigate(routeButton.dataset.route);
    return;
  }

  const actionTarget = event.target.closest('[data-action]');
  if (actionTarget) {
    event.preventDefault();
    handleAction(actionTarget.dataset.action, actionTarget);
    return;
  }

  const backdrop = event.target.closest('.modal-backdrop');
  if (backdrop && event.target === backdrop) closeModal();
}

function handleInput(event) {
  if (event.target.id === 'request-search') {
    ui.requestSearch = event.target.value;
    const results = document.getElementById('sos-results');
    if (results) results.innerHTML = renderSosResults(getState(), ui);
  }
  if (event.target.id === 'sos-question') {
    const counter = document.getElementById('sos-char-count');
    if (counter) counter.textContent = event.target.value.length;
  }
}

function handleSubmit(event) {
  const form = event.target;
  if (!(form instanceof HTMLFormElement)) return;
  if (!['sos-form', 'profile-form', 'member-form', 'guild-chat-form'].includes(form.id)) return;
  event.preventDefault();
  if (form.id === 'sos-form') submitSos(form);
  if (form.id === 'profile-form') submitProfile();
  if (form.id === 'member-form') submitMember();
  if (form.id === 'guild-chat-form') submitChat();
}

function handleKeydown(event) {
  if (event.key === 'Escape') closeModal();
  if ((event.metaKey || event.ctrlKey) && event.key.toLowerCase() === 'k') {
    event.preventDefault();
    navigate('sos');
    setTimeout(() => document.getElementById('request-search')?.focus(), 50);
  }
}

function bootstrap() {
  loadPreferences();
  applyPreferences();
  initState();
  render();
  subscribe(render);
  window.addEventListener('hashchange', render);
  document.addEventListener('click', handleClick);
  document.addEventListener('input', handleInput);
  document.addEventListener('submit', handleSubmit);
  document.addEventListener('keydown', handleKeydown);

  // Regenerate a unit of energy every 15 seconds, capped at 100.
  window.setInterval(() => {
    const state = getState();
    if (state?.user?.energy < 100) {
      setState(next => { next.user.energy += 1; });
    }
  }, 15000);
}

document.addEventListener('DOMContentLoaded', bootstrap);

export { showToast };
