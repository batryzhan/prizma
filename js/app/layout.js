import { getRank, getRankProgress } from '../core/utils.js';
import { NAVIGATION, ROUTE_META } from './data.js';
import { icon } from './icons.js';
import { avatarMarkup, escapeHtml, progressBar, todayLabel } from './renderers.js';

export const APP_ROUTES = Object.keys(ROUTE_META);

export function normaliseRoute(hash = window.location.hash) {
  const raw = hash.replace(/^#\/?/, '').split('?')[0].replace(/\/$/, '');
  if (!raw) return 'landing';
  return APP_ROUTES.includes(raw) ? raw : 'not-found';
}

function navItem(item, activeRoute) {
  const active = item.route === activeRoute;
  return `<button class="nav-item ${active ? 'nav-item--active' : ''}" data-route="${item.route}" type="button" ${active ? 'aria-current="page"' : ''}>
    <span class="nav-item__icon">${icon(item.icon, 19)}</span>
    <span>${escapeHtml(item.label)}</span>
    ${item.badge ? `<span class="nav-item__badge">${escapeHtml(item.badge)}</span>` : ''}
  </button>`;
}

function renderSidebar(route, state, ui) {
  const { user } = state;
  const rank = getRank(user.utilityScore || 0);
  const rankProgress = getRankProgress(user.utilityScore || 0);
  const avatar = avatarMarkup(user, 'lg');

  return `<aside class="app-sidebar ${ui.sidebarOpen ? 'app-sidebar--open' : ''}" id="app-sidebar">
    <div class="sidebar-top">
      <button class="brand brand--app" data-route="dashboard" type="button" aria-label="Prizma — на главную">
        <span class="brand__mark">${icon('prism', 21)}</span>
        <span class="brand__word">prizma</span>
      </button>
      <button class="icon-button sidebar-close" type="button" data-action="toggle-sidebar" aria-label="Закрыть меню">${icon('close', 20)}</button>
    </div>

    <nav class="app-navigation" aria-label="Основная навигация">
      ${NAVIGATION.map(group => `<div class="nav-group">
        <span class="nav-group__label">${escapeHtml(group.label)}</span>
        <div class="nav-group__items">${group.items.map(item => navItem(item, route)).join('')}</div>
      </div>`).join('')}
    </nav>

    <div class="sidebar-focus">
      <div class="sidebar-focus__top">
        <span class="sidebar-focus__icon">${icon('target', 17)}</span>
        <span>Дневной фокус</span>
      </div>
      <strong>2 из 3 задач</strong>
      ${progressBar(67, 'violet', 'Дневной фокус: 67%')}
      <button type="button" class="text-button text-button--light" data-route="progress">Открыть план ${icon('arrowUpRight', 14)}</button>
    </div>

    <div class="sidebar-user">
      ${avatar}
      <button type="button" class="sidebar-user__details" data-route="profile">
        <strong>${escapeHtml(user.name || 'Ученик Prizma')}</strong>
        <span>${escapeHtml(rank.name)} · ${user.utilityScore || 0} pts</span>
      </button>
      <button class="icon-button icon-button--small" type="button" data-route="settings" aria-label="Настройки">${icon('settings', 17)}</button>
    </div>
  </aside>`;
}

function renderTopbar(route, state, ui) {
  const meta = ROUTE_META[route] || { crumb: 'Prizma', title: 'Страница' };
  const unread = (state.sosList || []).filter(item => !item.resolved).length;
  return `<header class="topbar">
    <div class="topbar__left">
      <button class="icon-button menu-button" type="button" data-action="toggle-sidebar" aria-label="Открыть навигацию">${icon('menu', 22)}</button>
      <div class="breadcrumbs"><span>${escapeHtml(meta.crumb)}</span>${icon('chevronRight', 14)}<strong>${escapeHtml(meta.title)}</strong></div>
    </div>
    <div class="topbar__right">
      <button type="button" class="topbar-search" data-action="focus-global-search">
        ${icon('search', 18)}<span>Найти в Prizma</span><kbd>⌘ K</kbd>
      </button>
      <button class="icon-button notification-button" type="button" data-action="show-notifications" aria-label="Уведомления">
        ${icon('bell', 20)}${unread ? '<i></i>' : ''}
      </button>
      <button class="theme-toggle" type="button" data-action="toggle-theme" aria-label="Сменить тему">
        ${ui.theme === 'dark' ? icon('sun', 17) : icon('moon', 17)}
      </button>
    </div>
  </header>`;
}

export function renderAppShell(route, page, state, ui) {
  return `<div class="app-shell">
    ${renderSidebar(route, state, ui)}
    <button class="sidebar-scrim ${ui.sidebarOpen ? 'sidebar-scrim--visible' : ''}" data-action="toggle-sidebar" aria-label="Закрыть навигацию"></button>
    <div class="app-main">
      ${renderTopbar(route, state, ui)}
      <main class="app-content page-enter" id="route-content" tabindex="-1">${page}</main>
    </div>
    <nav class="mobile-nav" aria-label="Быстрая навигация">
      ${NAVIGATION[0].items.slice(0, 3).map(item => `<button class="mobile-nav__item ${item.route === route ? 'mobile-nav__item--active' : ''}" data-route="${item.route}" type="button">
        ${icon(item.icon, 19)}<span>${escapeHtml(item.label)}</span>
      </button>`).join('')}
      <button class="mobile-nav__item" type="button" data-action="toggle-sidebar">${icon('menu', 19)}<span>Ещё</span></button>
    </nav>
  </div>`;
}

export function renderLanding(state, ui) {
  const { user } = state;
  const userName = escapeHtml(user.name || 'ученик');
  const ctaRoute = user.requestsCreated || user.helpGiven || user.utilityScore ? 'dashboard' : 'dashboard';
  return `<div class="landing">
    <header class="landing-nav container">
      <button class="brand" data-route="landing" type="button" aria-label="Prizma — главная">
        <span class="brand__mark">${icon('prism', 22)}</span><span class="brand__word">prizma</span>
      </button>
      <nav class="landing-nav__links" aria-label="Навигация лендинга">
        <button type="button" data-action="scroll-to" data-section="features">Возможности</button><button type="button" data-action="scroll-to" data-section="flow">Как это работает</button><button type="button" data-action="scroll-to" data-section="community">Сообщество</button>
      </nav>
      <div class="landing-nav__actions">
        <button class="theme-toggle" type="button" data-action="toggle-theme" aria-label="Сменить тему">${ui.theme === 'dark' ? icon('sun', 17) : icon('moon', 17)}</button>
        <button class="button button--ghost button--compact" data-route="dashboard" type="button">Войти</button>
        <button class="button button--primary button--compact landing-nav__cta" data-route="${ctaRoute}" type="button">Открыть Prizma ${icon('arrowUpRight', 16)}</button>
      </div>
    </header>

    <main>
      <section class="hero container">
        <div class="hero__copy">
          <div class="hero__eyebrow"><span class="presence-dot"></span> Учебное пространство для тех, кто движется дальше</div>
          <h1>Знания становятся <span>ближе</span>, когда учишься не один.</h1>
          <p>Prizma объединяет вопросы, фокус и поддержку сообщества в одном спокойном пространстве. Попроси помощь, поделись опытом и увидь свой реальный рост.</p>
          <div class="hero__actions">
            <button class="button button--primary button--large" type="button" data-route="${ctaRoute}">Начать учиться ${icon('arrowUpRight', 18)}</button>
            <button class="button button--ghost button--large" type="button" data-action="scroll-to" data-section="flow">Как это устроено ${icon('chevronDown', 17)}</button>
          </div>
          <div class="hero__people">
            <div class="avatar-stack"><span class="avatar avatar--sm avatar--violet">M</span><span class="avatar avatar--sm avatar--blue">D</span><span class="avatar avatar--sm avatar--orange">L</span><span class="avatar avatar--sm avatar--green">K</span></div>
            <div><strong>2 400+ учеников</strong><span>уже помогают друг другу</span></div>
          </div>
        </div>
        <div class="hero__visual" aria-label="Превью dashboard Prizma">
          <div class="hero-glow hero-glow--one"></div><div class="hero-glow hero-glow--two"></div>
          <div class="hero-orb"><span></span><i></i></div>
          <div class="hero-window">
            <div class="hero-window__bar"><span></span><span></span><span></span><b>Мой прогресс</b><em>•••</em></div>
            <div class="hero-window__body">
              <div class="hero-metric"><div><span>Фокус за неделю</span><strong>12 ч 40 мин</strong><small><b>↗ 18%</b> к прошлой неделе</small></div><div class="hero-ring"><span>78<small>%</small></span></div></div>
              <div class="hero-chart"><div class="hero-chart__labels"><span>Пн</span><span>Вт</span><span>Ср</span><span>Чт</span><span>Пт</span><span>Сб</span><span>Вс</span></div><svg viewBox="0 0 360 120" preserveAspectRatio="none" aria-hidden="true"><defs><linearGradient id="hero-line" x1="0" y1="0" x2="1" y2="0"><stop stop-color="#7551ff"/><stop offset="1" stop-color="#34d7d4"/></linearGradient></defs><path d="M0 99 C28 85 33 96 57 73 S89 64 109 75 S140 42 161 59 S190 69 211 36 S247 55 265 43 S304 55 322 22 S345 34 360 10" fill="none" stroke="url(#hero-line)" stroke-width="4" stroke-linecap="round"/></svg></div>
              <div class="hero-task"><span class="hero-task__check">${icon('check', 13)}</span><div><strong>Завершить задачу по физике</strong><small>Сегодня · 18:30</small></div><span class="subject-dot subject-dot--blue"></span></div>
            </div>
          </div>
          <div class="floating-card floating-card--ask"><span class="floating-card__icon">${icon('message', 17)}</span><div><small>Новый запрос</small><strong>Помощь уже рядом</strong></div><i class="presence-dot"></i></div>
          <div class="floating-card floating-card--score"><span class="floating-card__icon floating-card__icon--yellow">${icon('bolt', 17)}</span><div><small>Utility score</small><strong>+ 30 points</strong></div></div>
        </div>
      </section>

      <section class="trust-strip container"><span>Учиться осознаннее — каждый день</span><div><b>6</b> предметов</div><div><b>24/7</b> помощь сообщества</div><div><b>1</b> понятный ритм</div></section>

      <section class="feature-section container" id="features">
        <div class="feature-section__intro"><span class="eyebrow">Всё важное — на своём месте</span><h2>Меньше хаоса. Больше уверенности в следующем шаге.</h2><p>Prizma не пытается заменить учёбу. Она помогает выстроить вокруг неё дружелюбную систему поддержки.</p></div>
        <div class="feature-grid">
          <article class="feature-card feature-card--wide"><div class="feature-card__icon feature-card__icon--violet">${icon('requests', 22)}</div><div><span class="eyebrow">SOS-запросы</span><h3>Вопрос — это начало диалога.</h3><p>Опиши, что не получается, выбери предмет и быстро найди того, кто уже разобрался.</p></div><div class="feature-card__preview preview-requests"><span class="preview-line preview-line--short"></span><span class="preview-line"></span><span class="preview-line preview-line--mid"></span><span class="preview-helper">+12</span></div></article>
          <article class="feature-card"><div class="feature-card__icon feature-card__icon--cyan">${icon('target', 22)}</div><span class="eyebrow">Личный ритм</span><h3>Фокус не теряется между задачами.</h3><p>План на день, короткие сессии и прогресс без чувства перегруза.</p><div class="mini-progress"><span></span><i></i><i></i><i></i></div></article>
          <article class="feature-card"><div class="feature-card__icon feature-card__icon--orange">${icon('users', 22)}</div><span class="eyebrow">Гильдия</span><h3>Люди рядом, когда это важно.</h3><p>Поддержка одноклассников, общий чат и здоровая мотивация расти вместе.</p><div class="mini-avatars"><span>M</span><span>D</span><span>L</span><span>+8</span></div></article>
        </div>
      </section>

      <section class="flow-section" id="flow"><div class="container"><div class="flow-heading"><span class="eyebrow">Простой учебный цикл</span><h2>От «я не понимаю» до «теперь я могу объяснить».</h2></div><div class="flow-steps"><article><span>01</span><i>${icon('message', 23)}</i><h3>Спроси</h3><p>Создай SOS-запрос и дай контекст задаче.</p></article><article><span>02</span><i>${icon('heart', 23)}</i><h3>Получи поддержку</h3><p>Найди понятное объяснение от своего сообщества.</p></article><article><span>03</span><i>${icon('sparkles', 23)}</i><h3>Закрепи рост</h3><p>Возвращайся к целям и помогай следующим.</p></article></div></div></section>

      <section class="landing-cta container" id="community"><div><span class="eyebrow">Твоя следующая учебная точка</span><h2>Привет, ${userName}. Готов увидеть, как складывается твой ритм?</h2><p>Начни с одного небольшого шага — он уже считается.</p></div><button class="button button--primary button--large" type="button" data-route="dashboard">Перейти в dashboard ${icon('arrowUpRight', 18)}</button></section>
    </main>
    <footer class="landing-footer container"><button class="brand" data-route="landing" type="button"><span class="brand__mark">${icon('prism', 20)}</span><span class="brand__word">prizma</span></button><span>Учебное пространство, в котором можно быть собой.</span><span>© ${new Date().getFullYear()} Prizma</span></footer>
  </div>`;
}

export function renderNotFound() {
  return `<main class="not-found"><div class="not-found__card"><span class="brand__mark">${icon('prism', 23)}</span><span class="eyebrow">404 · маршрут не найден</span><h1>Этой грани Prizma пока нет.</h1><p>Вернёмся туда, где можно продолжить учиться.</p><button class="button button--primary" data-route="landing" type="button">На главную ${icon('arrowUpRight', 16)}</button></div></main>`;
}

export function renderPageTitle(eyebrow, title, description, actions = '') {
  return `<section class="page-title"><div><span class="eyebrow">${escapeHtml(eyebrow)}</span><h1>${escapeHtml(title)}</h1><p>${escapeHtml(description)}</p></div>${actions ? `<div class="page-title__actions">${actions}</div>` : ''}</section>`;
}

export function renderDatePill() {
  return `<span class="date-pill">${icon('calendar', 16)} ${escapeHtml(todayLabel())}</span>`;
}
