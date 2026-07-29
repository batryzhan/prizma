import { CONFIG } from '../store/state.js';
import { getLevelProgress, getRank, getRankProgress, timeAgo } from '../core/utils.js';
import { ACHIEVEMENTS, CALENDAR_DAYS, DAILY_PLAN, RESOURCES } from './data.js';
import { icon } from './icons.js';
import {
  avatarMarkup,
  emptyState,
  escapeHtml,
  initials,
  number,
  progressBar,
  sectionHeading,
  subjectMeta,
  subjectTag,
} from './renderers.js';
import { renderDatePill, renderPageTitle } from './layout.js';

const SUBJECT_TONES = ['violet', 'blue', 'green', 'orange', 'pink', 'cyan'];

function requestsForView(state, ui) {
  const query = String(ui.requestSearch || '').trim().toLowerCase();
  const filter = ui.requestFilter || 'all';
  return (state.sosList || [])
    .filter(item => filter === 'all' || item.subject === filter)
    .filter(item => !query || `${item.question} ${item.author}`.toLowerCase().includes(query))
    .sort((a, b) => Number(a.resolved) - Number(b.resolved) || b.createdAt - a.createdAt);
}

function shortText(value, length = 155) {
  const text = String(value || '');
  return text.length > length ? `${text.slice(0, length).trim()}…` : text;
}

function requestCard(request, state, compact = false) {
  const own = request.author === state.user.name;
  const user = { name: request.author, avatar: request.authorAvatar, avatarImage: request.authorAvatarImage };
  const subject = subjectMeta(request.subject, CONFIG.subjects);
  return `<article class="request-card ${request.resolved ? 'request-card--resolved' : ''}">
    <div class="request-card__top">
      ${subjectTag(request.subject, CONFIG.subjects)}
      <span class="request-card__time">${escapeHtml(timeAgo(request.createdAt))}</span>
    </div>
    <h3>${escapeHtml(shortText(request.question, compact ? 100 : 180))}</h3>
    ${compact ? '' : `<p>${escapeHtml(shortText(request.question, 245))}</p>`}
    <div class="request-card__bottom">
      <div class="request-author">${avatarMarkup(user, 'xs', `avatar--${subject.tone}`)}<span>${escapeHtml(request.author)}</span></div>
      <div class="request-card__actions">
        <span class="reward-pill">${icon('bolt', 14)} ${number(request.reward)}</span>
        ${request.resolved
          ? `<span class="status-pill status-pill--success">${icon('check', 13)} Решено</span>`
          : own
            ? `<button class="icon-button icon-button--small request-delete" data-action="delete-sos" data-sos-id="${escapeHtml(request.id)}" type="button" aria-label="Удалить запрос">${icon('trash', 16)}</button>`
            : `<button class="button button--soft button--compact" data-action="help-sos" data-sos-id="${escapeHtml(request.id)}" type="button">Помочь ${icon('arrowUpRight', 14)}</button>`}
      </div>
    </div>
  </article>`;
}

function statCard({ iconName, tone, label, value, trend, caption }) {
  return `<article class="stat-card">
    <span class="stat-card__icon stat-card__icon--${tone}">${icon(iconName, 20)}</span>
    <div class="stat-card__content"><span>${escapeHtml(label)}</span><strong>${escapeHtml(value)}</strong></div>
    ${trend ? `<span class="stat-card__trend ${trend.negative ? 'stat-card__trend--negative' : ''}">${trend.negative ? '↘' : '↗'} ${escapeHtml(trend.value)}</span>` : ''}
    ${caption ? `<small>${escapeHtml(caption)}</small>` : ''}
  </article>`;
}

function activityRow({ iconName, tone, title, text, time }) {
  return `<div class="activity-row">
    <span class="activity-row__icon activity-row__icon--${tone}">${icon(iconName, 17)}</span>
    <div><strong>${escapeHtml(title)}</strong><p>${escapeHtml(text)}</p></div>
    <time>${escapeHtml(time)}</time>
  </div>`;
}

function renderDashboard(state, ui) {
  const { user } = state;
  const rank = getRank(user.utilityScore || 0);
  const level = getLevelProgress(user.level || 1, user.xp || 0);
  const openRequests = (state.sosList || []).filter(item => !item.resolved);
  const mine = openRequests.filter(item => item.author === user.name);
  const recommended = openRequests.filter(item => item.author !== user.name).slice(0, 3);
  const now = new Date().getHours();
  const greeting = now < 12 ? 'Доброе утро' : now < 18 ? 'Добрый день' : 'Добрый вечер';
  const scoreTarget = rank.name === 'Легенда' ? user.utilityScore || 0 : Math.max((user.utilityScore || 0) + 50, 50);
  const scoreProgress = Math.min(100, Math.round(((user.utilityScore || 0) / scoreTarget) * 100));

  return `${renderPageTitle('Твой учебный ритм', `${greeting}, ${user.name || 'ученик'}!`, 'Сегодня достаточно одного ясного шага. Начнём с того, что уже в фокусе.', `<button class="button button--primary" type="button" data-action="create-sos">${icon('plus', 17)} Новый запрос</button>${renderDatePill()}`)}
    <section class="stats-grid stats-grid--four">
      ${statCard({ iconName: 'clock', tone: 'violet', label: 'Фокус за неделю', value: '2 ч 40 мин', trend: { value: '18%' }, caption: 'ещё 20 мин до цели' })}
      ${statCard({ iconName: 'heart', tone: 'pink', label: 'Помощь другим', value: `${number(user.helpGiven)} ответов`, trend: user.helpGiven ? { value: '+1' } : null, caption: 'твой вклад в сообщество' })}
      ${statCard({ iconName: 'flame', tone: 'orange', label: 'Серия фокуса', value: '7 дней', trend: { value: 'в ритме' }, caption: 'лучший результат: 12 дней' })}
      ${statCard({ iconName: 'bolt', tone: 'yellow', label: 'Энергия', value: `${number(user.energy)} / 100`, trend: { value: '+1' }, caption: 'восстанавливается со временем' })}
    </section>

    <section class="dashboard-grid dashboard-grid--main">
      <article class="section-card weekly-card">
        <div class="card-heading"><div><span class="eyebrow">Учебная динамика</span><h2>Твоя неделя</h2></div><button class="select-button" type="button" data-action="show-weekly-chart">7 дней ${icon('chevronDown', 15)}</button></div>
        <div class="weekly-card__summary"><strong>12 ч 40 мин</strong><span><b>↗ 18%</b> относительно прошлой недели</span></div>
        <div class="weekly-chart" aria-label="График фокуса за неделю">
          <div class="weekly-chart__guides"><i></i><i></i><i></i><i></i></div>
          <svg viewBox="0 0 680 230" preserveAspectRatio="none" role="img" aria-label="Рост учебного времени"><defs><linearGradient id="weekly-area" x1="0" x2="0" y1="0" y2="1"><stop stop-color="#7551ff" stop-opacity=".25"/><stop offset="1" stop-color="#7551ff" stop-opacity="0"/></linearGradient><linearGradient id="weekly-stroke" x1="0" x2="1"><stop stop-color="#7551ff"/><stop offset="1" stop-color="#3cc7d5"/></linearGradient></defs><path d="M0 170 C35 156 53 157 85 143 S120 176 156 128 S198 104 238 128 S275 153 308 111 S345 134 380 91 S422 86 457 105 S486 54 529 76 S568 105 603 51 S644 32 680 39 L680 230 L0 230Z" fill="url(#weekly-area)"/><path d="M0 170 C35 156 53 157 85 143 S120 176 156 128 S198 104 238 128 S275 153 308 111 S345 134 380 91 S422 86 457 105 S486 54 529 76 S568 105 603 51 S644 32 680 39" fill="none" stroke="url(#weekly-stroke)" stroke-width="4" stroke-linecap="round"/></svg>
          <div class="weekly-chart__labels"><span>Пн</span><span>Вт</span><span>Ср</span><span>Чт</span><span>Пт</span><span>Сб</span><span>Вс</span></div>
          <span class="chart-point" style="left: 88%; top: 12%;"><b>2ч 25м</b><i></i></span>
        </div>
      </article>

      <article class="section-card level-card">
        <div class="card-heading"><div><span class="eyebrow">Точка роста</span><h2>${escapeHtml(rank.name)}</h2></div><span class="level-badge">LVL ${level.level}</span></div>
        <div class="level-card__center"><div class="level-orbit"><div class="level-orbit__inner"><strong>${number(user.utilityScore)}</strong><span>points</span></div></div><p>Твой utility score растёт каждый раз, когда ты помогаешь понять.</p></div>
        <div class="level-card__progress"><div><span>До следующей грани</span><strong>${scoreTarget - (user.utilityScore || 0) > 0 ? `${scoreTarget - (user.utilityScore || 0)} pts` : 'Новый уровень!'}</strong></div>${progressBar(scoreProgress, 'violet')}</div>
      </article>
    </section>

    <section class="dashboard-grid dashboard-grid--bottom">
      <article class="section-card today-card">
        ${sectionHeading('План на сегодня', 'Собери день в ритм', 'Небольшие задачи тоже двигают вперёд.', `<button class="text-button" data-route="progress" type="button">Весь план ${icon('arrowUpRight', 15)}</button>`)}
        <div class="timeline-list">
          ${DAILY_PLAN.map(task => `<div class="timeline-task ${task.done ? 'timeline-task--done' : ''}">
            <span class="timeline-task__time">${task.time}</span><button class="task-check" data-action="toggle-task" data-task-id="${task.id}" type="button" aria-label="Отметить задачу выполненной">${task.done || ui.completedTasks?.includes(task.id) ? icon('check', 14) : ''}</button><div><strong>${escapeHtml(task.title)}</strong><span>${subjectTag(task.subject, CONFIG.subjects)} · ${escapeHtml(task.duration)}</span></div>
          </div>`).join('')}
        </div>
      </article>
      <article class="section-card request-preview-card">
        ${sectionHeading('Рядом нужна помощь', 'Запросы от сообщества', mine.length ? `У тебя ${mine.length} открытых запросов.` : 'Выбери вопрос, который можешь прояснить.', `<button class="text-button" data-route="sos" type="button">Все запросы ${icon('arrowUpRight', 15)}</button>`)}
        <div class="compact-request-list">${recommended.length ? recommended.map(item => requestCard(item, state, true)).join('') : emptyState({ iconName: 'heart', title: 'Лента уже стала спокойнее', text: 'Новые запросы появятся здесь.', action: '<button class="button button--soft button--compact" type="button" data-action="create-sos">Создать запрос</button>' })}</div>
      </article>
      <article class="section-card activity-card">
        ${sectionHeading('Пульс гильдии', 'Сегодня рядом', 'Небольшие события, которые уже произошли.', `<button class="text-button" data-route="guild" type="button">В гильдию ${icon('arrowUpRight', 15)}</button>`)}
        <div class="activity-list">
          ${activityRow({ iconName: 'heart', tone: 'pink', title: 'Mira_X закрыла SOS по математике', text: 'В сообществе стало на один понятный ответ больше.', time: '12 мин' })}
          ${activityRow({ iconName: 'flame', tone: 'orange', title: 'Dev_K держит серию 10 дней', text: 'Устойчивость складывается из маленьких сессий.', time: '1 ч' })}
          ${activityRow({ iconName: 'users', tone: 'cyan', title: '4 участника сейчас онлайн', text: 'Можно задать вопрос и получить быстрый отклик.', time: 'сейчас' })}
        </div>
      </article>
    </section>`;
}

export function renderSosResults(state, ui) {
  const requests = requestsForView(state, ui);
  if (!requests.length) {
    return emptyState({
      iconName: 'search', title: 'Ничего не нашлось', text: 'Попробуй изменить предмет или формулировку поиска.',
      action: '<button type="button" class="button button--soft button--compact" data-action="clear-request-filters">Сбросить фильтры</button>',
    });
  }
  return `<div class="request-list">${requests.map(item => requestCard(item, state)).join('')}</div>`;
}

function renderSos(state, ui) {
  const all = state.sosList || [];
  const unresolved = all.filter(item => !item.resolved).length;
  const filter = ui.requestFilter || 'all';
  return `${renderPageTitle('Биржа помощи', 'Вопросы, которые ждут тебя', 'Спрашивать — нормально. Объяснять — лучший способ закрепить знания.', `<button class="button button--primary" type="button" data-action="create-sos">${icon('plus', 17)} Создать SOS</button>`)}
    <section class="sos-layout">
      <div class="sos-main">
        <div class="search-and-filter section-card">
          <label class="search-field"><span>${icon('search', 19)}</span><input type="search" id="request-search" placeholder="Поиск по вопросу или автору" value="${escapeHtml(ui.requestSearch || '')}" autocomplete="off"><kbd>⌘ K</kbd></label>
          <div class="filter-row" aria-label="Фильтр по предмету"><button class="filter-chip ${filter === 'all' ? 'filter-chip--active' : ''}" type="button" data-action="filter-sos" data-filter="all">Все <span>${all.length}</span></button>${CONFIG.subjects.map(subject => `<button class="filter-chip ${filter === subject.id ? 'filter-chip--active' : ''}" type="button" data-action="filter-sos" data-filter="${subject.id}">${subject.icon} ${escapeHtml(subject.name)}</button>`).join('')}</div>
        </div>
        <div class="feed-heading"><div><span class="eyebrow">Сейчас в ленте</span><h2>${unresolved} открытых запросов</h2></div><button class="select-button" type="button" data-action="sort-sos">Сначала новые ${icon('chevronDown', 15)}</button></div>
        <div id="sos-results">${renderSosResults(state, ui)}</div>
      </div>
      <aside class="sos-aside">
        <article class="section-card ask-card"><span class="ask-card__icon">${icon('sparkles', 21)}</span><span class="eyebrow">Не застревай надолго</span><h3>Твой вопрос может стать чьим-то пониманием.</h3><p>Добавь контекст, выбери награду и получи поддержку от гильдии.</p><button class="button button--primary button--block" type="button" data-action="create-sos">${icon('plus', 16)} Задать вопрос</button></article>
        <article class="section-card subject-stat-card"><div class="card-heading"><div><span class="eyebrow">Пульс предметов</span><h3>Где помощь нужнее</h3></div>${icon('activity', 18)}</div><div class="subject-stat-list">${CONFIG.subjects.map(subject => { const count = all.filter(item => item.subject === subject.id && !item.resolved).length; return `<div><span>${subjectTag(subject.id, CONFIG.subjects)}</span><b>${count}</b>${progressBar(Math.min(100, count * 18), subjectMeta(subject.id, CONFIG.subjects).tone)}</div>`; }).join('')}</div></article>
      </aside>
    </section>`;
}

function renderSubjects(state) {
  const all = state.sosList || [];
  return `${renderPageTitle('Каталог знаний', 'Выбери грань для следующего шага', 'Короткие материалы, тренажёры и живые вопросы по каждому предмету.', `<button class="button button--soft" type="button" data-route="sos">${icon('requests', 17)} К запросам</button>`)}
    <section class="subject-explorer">
      ${CONFIG.subjects.map((subject, index) => {
        const tone = SUBJECT_TONES[index];
        const open = all.filter(item => item.subject === subject.id && !item.resolved).length;
        const materials = RESOURCES[subject.id] || [];
        return `<article class="subject-explorer-card subject-explorer-card--${tone}">
          <div class="subject-explorer-card__top"><span class="subject-explorer-card__symbol">${escapeHtml(subject.icon)}</span><span class="subject-open-count">${open} SOS</span></div>
          <h2>${escapeHtml(subject.name)}</h2><p>${open ? `Сейчас ${open} вопрос${open === 1 ? '' : open < 5 ? 'а' : 'ов'} ждут внимания.` : 'Лента спокойна — можно закрепить знания заранее.'}</p>
          <div class="resource-list">${materials.map(material => `<button class="resource-row" type="button" data-action="open-resource" data-resource="${escapeHtml(material.title)}"><span class="resource-row__type">${escapeHtml(material.type)}</span><div><strong>${escapeHtml(material.title)}</strong><small>${icon('clock', 13)} ${escapeHtml(material.time)}</small></div><i>${icon('arrowUpRight', 15)}</i></button>`).join('')}</div>
          <button class="text-button" type="button" data-action="view-subject-requests" data-subject-id="${subject.id}">Смотреть запросы ${icon('arrowUpRight', 15)}</button>
        </article>`;
      }).join('')}
    </section>
    <section class="study-callout"><div class="study-callout__mark">${icon('sparkles', 26)}</div><div><span class="eyebrow">Учебный совет дня</span><h2>Понимание крепнет, когда объясняешь его другому.</h2><p>Выбери один запрос по знакомой теме — даже короткая подсказка может стать началом решения.</p></div><button class="button button--primary" data-route="sos" type="button">Найти вопрос ${icon('arrowUpRight', 16)}</button></section>`;
}

function renderGuild(state) {
  const members = [...(state.guild || [])].sort((a, b) => (a.status === 'online' ? -1 : 1) || b.score - a.score);
  const messages = state.chatMessages || [];
  const onlineCount = members.filter(member => member.status === 'online').length;
  return `${renderPageTitle('Пространство гильдии', 'Учиться вместе — легче', `${onlineCount} участника сейчас онлайн. Здесь можно спросить, отметить маленькую победу или помочь с задачей.`, `<button class="button button--soft" type="button" data-action="open-add-member">${icon('plus', 17)} Пригласить</button>`)}
    <section class="guild-overview">
      <article class="guild-hero-card"><div class="guild-hero-card__copy"><span class="eyebrow">Prizma guild · 07</span><h2>Каждый приносит сюда свою сильную сторону.</h2><p>Здесь нет гонки. Есть вопросы, поддержка и общий ритм, который держит, когда одному трудно.</p><div class="guild-hero-card__stats"><div><b>${onlineCount}</b><span>сейчас онлайн</span></div><div><b>${number(members.length)}</b><span>участников</span></div><div><b>82%</b><span>ответов за день</span></div></div></div><div class="guild-hero-card__art"><span class="guild-shape guild-shape--one"></span><span class="guild-shape guild-shape--two"></span><span class="guild-shape guild-shape--three"></span><div class="guild-hero-orb">${icon('prism', 36)}</div></div></article>
      <article class="section-card guild-quest-card"><span class="eyebrow">Общий импульс</span><h3>Закрыть 20 SOS-запросов</h3><p>Сегодня гильдия уже помогла с 14 задачами.</p>${progressBar(70, 'cyan')}<div><span>14 / 20 ответов</span><strong>+50 энергии</strong></div></article>
    </section>
    <section class="guild-grid">
      <article class="section-card guild-members-card"><div class="card-heading"><div><span class="eyebrow">Участники</span><h2>Те, кто рядом</h2></div><button class="text-button" type="button" data-action="open-add-member">Добавить ${icon('plus', 15)}</button></div><div class="member-list">${members.map(member => `<div class="member-row"><div class="member-row__avatar-wrap">${avatarMarkup(member, 'md', `avatar--${member.status === 'online' ? 'green' : member.status === 'away' ? 'yellow' : 'muted'}`)}<i class="member-status member-status--${escapeHtml(member.status)}"></i></div><div><strong>${escapeHtml(member.name)}</strong><span>${member.status === 'online' ? 'В сети · готов помочь' : member.status === 'away' ? 'Отошёл ненадолго' : 'Не в сети'}</span></div><b>${icon('bolt', 13)} ${number(member.score)}</b></div>`).join('')}</div></article>
      <article class="section-card guild-chat-card"><div class="card-heading"><div><span class="eyebrow">Общий чат</span><h2>Разговор в гильдии</h2></div><span class="live-pill"><i></i> live</span></div><div class="chat-list" id="chat-list">${messages.length ? messages.map(message => `<div class="chat-message"><div>${avatarMarkup({ name: message.from, avatar: initials(message.from) }, 'xs')}<strong>${escapeHtml(message.from)}</strong><time>${escapeHtml(timeAgo(message.time))}</time></div><p>${escapeHtml(message.text)}</p></div>`).join('') : emptyState({ iconName: 'message', title: 'Начни разговор', text: 'Первое сообщение обычно самое короткое.' })}</div><form class="chat-compose" id="guild-chat-form"><input id="guild-chat-input" type="text" maxlength="200" autocomplete="off" placeholder="Напиши гильдии…"><button class="button button--primary button--icon" type="submit" aria-label="Отправить сообщение">${icon('send', 17)}</button></form></article>
    </section>`;
}

function renderLeaderboard(state) {
  const players = [{ ...state.user, score: state.user.utilityScore || 0, status: 'you', avatar: state.user.avatar || initials(state.user.name) }, ...(state.guild || [])]
    .sort((a, b) => (b.score || 0) - (a.score || 0));
  const top = players.slice(0, 3);
  return `${renderPageTitle('Рейтинг сообщества', 'Вклад, который делает знания ближе', 'Не соревнование ради места — способ заметить, сколько поддержки уже создано.', `<button class="button button--soft" data-route="guild" type="button">${icon('users', 17)} В гильдию</button>`)}
    <section class="leaderboard-hero"><div class="leaderboard-hero__top"><div><span class="eyebrow">Топ недели</span><h2>Те, кто помогли больше всего</h2></div><span class="date-pill">${icon('calendar', 16)} Эта неделя</span></div><div class="podium">${top.map((player, index) => `<article class="podium__place podium__place--${index + 1}"><span class="podium__rank">${index + 1}</span>${avatarMarkup(player, 'xl', `avatar--${index === 0 ? 'yellow' : index === 1 ? 'violet' : 'orange'}`)}<strong>${escapeHtml(player.name)}</strong><small>${icon('bolt', 13)} ${number(player.score)}</small><i></i></article>`).join('')}</div></section>
    <section class="section-card leaderboard-table-card"><div class="card-heading"><div><span class="eyebrow">Все участники</span><h2>Ритм помощи</h2></div><span class="table-caption">Обновляется локально</span></div><div class="leaderboard-table"><div class="leaderboard-table__head"><span>Место</span><span>Участник</span><span>Ранг</span><span>Вклад</span></div>${players.map((player, index) => { const rank = getRank(player.score || 0); const isSelf = player.status === 'you'; return `<div class="leaderboard-table__row ${isSelf ? 'leaderboard-table__row--self' : ''}"><span class="rank-cell">${index < 3 ? `<i class="rank-medal rank-medal--${index + 1}">${index + 1}</i>` : index + 1}</span><span class="player-cell">${avatarMarkup(player, 'sm', isSelf ? 'avatar--violet' : '')}<strong>${escapeHtml(player.name)}${isSelf ? '<em>ты</em>' : ''}</strong></span><span class="rank-name">${escapeHtml(rank.name)}</span><span class="score-cell">${icon('bolt', 15)} ${number(player.score)}</span></div>`; }).join('')}</div></section>`;
}

function renderProgress(state, ui) {
  const { user } = state;
  const rank = getRank(user.utilityScore || 0);
  const rankProgress = getRankProgress(user.utilityScore || 0);
  const level = getLevelProgress(user.level || 1, user.xp || 0);
  const doneTasks = DAILY_PLAN.filter(task => task.done || ui.completedTasks?.includes(task.id)).length;
  const achievementProgress = [user.requestsCreated || 0, user.helpGiven || 0, 7, user.utilityScore || 0];
  return `${renderPageTitle('Личный рост', 'Твоя траектория уже видна', 'Здесь нет идеальных дней. Есть честный путь, который складывается из маленьких действий.', `<button class="button button--soft" data-route="profile" type="button">${icon('user', 17)} Профиль</button>`)}
    <section class="progress-hero-card"><div class="progress-hero-card__identity">${avatarMarkup(user, 'xxl', 'avatar--violet')}<div><span class="eyebrow">Текущий ранг</span><h2>${escapeHtml(rank.name)}</h2><p>Уровень ${level.level} · ${number(user.utilityScore)} utility points</p></div></div><div class="progress-hero-card__metrics"><div><span>Опыт</span><strong>${level.xp} <small>/ ${level.needed} XP</small></strong>${progressBar(level.progress * 100, 'violet')}</div><div><span>Следующая грань</span><strong>${rankProgress.next ? escapeHtml(rankProgress.next.name) : 'Легенда'}</strong>${progressBar(rankProgress.progress * 100, 'cyan')}</div></div><span class="progress-hero-card__mark">${icon('prism', 72)}</span></section>
    <section class="stats-grid stats-grid--four progress-stats">${statCard({ iconName: 'heart', tone: 'pink', label: 'Помощь другим', value: `${number(user.helpGiven)}`, caption: 'закрытых вопросов' })}${statCard({ iconName: 'requests', tone: 'violet', label: 'Мои SOS', value: `${number(user.requestsCreated)}`, caption: 'созданных запросов' })}${statCard({ iconName: 'bolt', tone: 'yellow', label: 'Энергия', value: `${number(user.energy)}`, caption: 'на новые действия' })}${statCard({ iconName: 'flame', tone: 'orange', label: 'Серия', value: '7 дней', caption: 'в учебном ритме' })}</section>
    <section class="progress-layout"><article class="section-card daily-focus-card">${sectionHeading('Сегодня', 'Маленький план', `${doneTasks} из ${DAILY_PLAN.length} задач отмечено.`, `<span class="tasks-counter">${doneTasks}/${DAILY_PLAN.length}</span>`)}<div class="focus-task-list">${DAILY_PLAN.map(task => { const done = task.done || ui.completedTasks?.includes(task.id); return `<button class="focus-task ${done ? 'focus-task--done' : ''}" type="button" data-action="toggle-task" data-task-id="${task.id}"><span class="task-check">${done ? icon('check', 14) : ''}</span><span><strong>${escapeHtml(task.title)}</strong><small>${task.time} · ${task.duration}</small></span>${subjectTag(task.subject, CONFIG.subjects, true)}</button>`; }).join('')}</div><button class="button button--soft button--block" type="button" data-action="create-sos">${icon('plus', 16)} Добавить фокус</button></article>
      <article class="section-card achievement-card">${sectionHeading('Коллекция', 'Моменты роста', 'Не бейджи ради бейджей — следы твоего пути.') }<div class="achievement-grid">${ACHIEVEMENTS.map((achievement, index) => { const current = achievementProgress[index]; const unlocked = current >= achievement.value; return `<div class="achievement ${unlocked ? 'achievement--unlocked' : ''}"><span class="achievement__icon achievement__icon--${achievement.tone}">${icon(achievement.icon, 19)}</span><div><strong>${escapeHtml(achievement.title)}</strong><p>${escapeHtml(achievement.text)}</p><small>${unlocked ? 'Получено' : `${number(current)} / ${achievement.value}`}</small></div>${unlocked ? icon('check', 16) : icon('lock', 15)}</div>`; }).join('')}</div></article></section>
    <section class="section-card calendar-card"><div class="card-heading"><div><span class="eyebrow">Учебный след</span><h2>Июль 2026</h2></div><div class="calendar-legend"><span><i class="calendar-dot calendar-dot--violet"></i> Фокус</span><span><i class="calendar-dot calendar-dot--cyan"></i> Помощь</span></div></div><div class="calendar-grid"><div class="calendar-grid__weekdays"><span>Пн</span><span>Вт</span><span>Ср</span><span>Чт</span><span>Пт</span><span>Сб</span><span>Вс</span></div><div class="calendar-grid__days">${CALENDAR_DAYS.map(day => `<button type="button" class="calendar-day ${day.muted ? 'calendar-day--muted' : ''} ${day.today ? 'calendar-day--today' : ''}" data-action="show-calendar-day" data-day="${day.day}">${day.day}${day.event ? `<i class="calendar-dot calendar-dot--${day.event}"></i>` : ''}</button>`).join('')}</div></div></section>`;
}

function renderProfile(state) {
  const { user } = state;
  const rank = getRank(user.utilityScore || 0);
  const ownRequests = (state.sosList || []).filter(item => item.author === user.name);
  return `${renderPageTitle('Твой профиль', 'Так тебя видит сообщество', 'Управляй тем, как представиться гильдии — остальное покажет твой вклад.', `<button class="button button--primary" type="button" data-action="edit-profile">${icon('edit', 17)} Редактировать</button>`)}
    <section class="profile-hero"><div class="profile-hero__background"><span></span><i></i><b></b></div><div class="profile-hero__content">${avatarMarkup(user, 'xxl', 'avatar--profile')}<div class="profile-hero__details"><span class="eyebrow">Участник Prizma</span><h1>${escapeHtml(user.name || 'Ученик Prizma')}</h1><p>${escapeHtml(rank.name)} · уровень ${user.level || 1} · с нами с этой недели</p><div><span>${icon('shield', 15)} Уважительный участник</span><span>${icon('sparkles', 15)} В своём ритме</span></div></div><button class="button button--soft" type="button" data-route="settings">${icon('settings', 16)} Настройки</button></div></section>
    <section class="profile-layout"><article class="section-card profile-about-card">${sectionHeading('О себе', 'Твоя учебная карточка', 'Каждая цифра — не оценка, а отражение того, что ты уже сделал.') }<div class="profile-score"><span>${icon('bolt', 18)}</span><div><small>Utility score</small><strong>${number(user.utilityScore)}</strong></div><i>${escapeHtml(rank.name)}</i></div><div class="profile-metric-grid"><div><span>Помощь</span><strong>${number(user.helpGiven)}</strong></div><div><span>Запросы</span><strong>${number(user.requestsCreated)}</strong></div><div><span>Энергия</span><strong>${number(user.energy)}</strong></div></div></article><article class="section-card profile-requests-card">${sectionHeading('Мои запросы', 'Что сейчас в пути', ownRequests.length ? 'Созданные тобой вопросы остаются здесь.' : 'Ты ещё не создавал SOS-запросы.', `<button class="text-button" data-route="sos" type="button">Открыть ленту ${icon('arrowUpRight', 15)}</button>`)}<div class="profile-request-list">${ownRequests.length ? ownRequests.slice(0, 3).map(request => requestCard(request, state, true)).join('') : emptyState({ iconName: 'requests', title: 'Первый вопрос — самый важный', text: 'Опиши, в чём нужна ясность, и гильдия поможет.', action: '<button class="button button--soft button--compact" type="button" data-action="create-sos">Создать SOS</button>' })}</div></article></section>`;
}

function renderSettings(state, ui) {
  const { user } = state;
  return `${renderPageTitle('Настройки', 'Сделай пространство своим', 'Все настройки хранятся только в этом браузере. Их можно спокойно менять и сбрасывать.', '')}
    <section class="settings-layout"><article class="section-card settings-card"><div class="settings-card__head"><div><span class="eyebrow">Внешний вид</span><h2>Комфортный режим</h2></div>${icon('moon', 21)}</div><div class="settings-row"><div><strong>Тёмная тема</strong><p>Снижает яркость интерфейса в вечернее время.</p></div><button class="switch ${ui.theme === 'dark' ? 'switch--on' : ''}" type="button" data-action="toggle-theme" role="switch" aria-checked="${ui.theme === 'dark'}"><i></i></button></div><div class="settings-row"><div><strong>Меньше анимаций</strong><p>Убирает декоративные движения и плавные переходы.</p></div><button class="switch ${ui.reduceMotion ? 'switch--on' : ''}" type="button" data-action="toggle-motion" role="switch" aria-checked="${ui.reduceMotion}"><i></i></button></div></article>
      <article class="section-card settings-card"><div class="settings-card__head"><div><span class="eyebrow">Данные</span><h2>Локальное хранилище</h2></div>${icon('shield', 21)}</div><div class="settings-data-note"><span>${icon('lock', 17)}</span><p>Демо-данные Prizma живут только в текущем браузере. Их можно сохранить в файл или начать заново.</p></div><div class="settings-actions"><button class="button button--soft" type="button" data-action="export-data">${icon('download', 16)} Скачать копию</button><button class="button button--danger" type="button" data-action="reset-data">${icon('refresh', 16)} Сбросить данные</button></div></article>
      <article class="section-card settings-card"><div class="settings-card__head"><div><span class="eyebrow">Профиль</span><h2>Текущий участник</h2></div>${icon('user', 21)}</div><div class="settings-profile">${avatarMarkup(user, 'lg')}<div><strong>${escapeHtml(user.name || 'Ученик Prizma')}</strong><span>Интерфейс на русском</span></div><button class="text-button" type="button" data-action="edit-profile">Изменить ${icon('arrowUpRight', 15)}</button></div></article></section>`;
}

export function renderRoutePage(route, state, ui) {
  switch (route) {
    case 'dashboard': return renderDashboard(state, ui);
    case 'sos': return renderSos(state, ui);
    case 'subjects': return renderSubjects(state, ui);
    case 'guild': return renderGuild(state);
    case 'leaderboard': return renderLeaderboard(state);
    case 'progress': return renderProgress(state, ui);
    case 'profile': return renderProfile(state);
    case 'settings': return renderSettings(state, ui);
    default: return '';
  }
}
