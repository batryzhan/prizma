import { icon } from './icons.js';

export function escapeHtml(value = '') {
  const text = String(value);
  return text
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;')
    .replaceAll("'", '&#039;');
}

export function safeImageUrl(value) {
  const url = String(value || '').trim();
  if (/^(https?:\/\/|data:image\/(?:png|jpe?g|gif|webp);base64,)/i.test(url)) {
    return escapeHtml(url);
  }
  return '';
}

export function initials(name = '') {
  const words = String(name).trim().split(/[\s_-]+/).filter(Boolean);
  return words.slice(0, 2).map(word => word[0]).join('').toUpperCase() || 'P';
}

export function avatarMarkup(person, size = 'md', extraClass = '') {
  const image = safeImageUrl(person?.avatarImage || person?.authorAvatarImage);
  const label = escapeHtml(person?.name || person?.author || 'Prizma user');
  const initial = escapeHtml(person?.avatar || person?.authorAvatar || initials(label));

  return `<span class="avatar avatar--${size} ${extraClass}" aria-label="${label}">
    ${image ? `<img src="${image}" alt="${label}">` : `<span>${initial}</span>`}
  </span>`;
}

export function number(value) {
  return new Intl.NumberFormat('ru-RU').format(Number(value) || 0);
}

export function todayLabel() {
  return new Intl.DateTimeFormat('ru-RU', {
    weekday: 'long', day: 'numeric', month: 'long',
  }).format(new Date());
}

export function subjectMeta(subjectId, subjects) {
  const subject = subjects.find(item => item.id === subjectId) || subjects[0];
  const tones = {
    math: 'violet', physics: 'blue', biology: 'green', chemistry: 'orange', history: 'pink', english: 'cyan',
  };
  return { ...subject, tone: tones[subject?.id] || 'violet' };
}

export function subjectTag(subjectId, subjects, compact = false) {
  const subject = subjectMeta(subjectId, subjects);
  const label = compact ? subject.icon : `${subject.icon} ${subject.name}`;
  return `<span class="subject-tag subject-tag--${subject.tone}">${escapeHtml(label)}</span>`;
}

export function sectionHeading(eyebrow, title, description = '', action = '') {
  return `<div class="section-heading">
    <div>
      ${eyebrow ? `<span class="eyebrow">${escapeHtml(eyebrow)}</span>` : ''}
      <h2>${escapeHtml(title)}</h2>
      ${description ? `<p>${escapeHtml(description)}</p>` : ''}
    </div>
    ${action}
  </div>`;
}

export function emptyState({ iconName = 'sparkles', title, text, action = '' }) {
  return `<div class="empty-state">
    <span class="empty-state__icon">${icon(iconName, 24)}</span>
    <h3>${escapeHtml(title)}</h3>
    <p>${escapeHtml(text)}</p>
    ${action}
  </div>`;
}

export function progressBar(value, tone = 'violet', label = '') {
  const fill = Math.max(0, Math.min(100, Number(value) || 0));
  return `<div class="progress" ${label ? `aria-label="${escapeHtml(label)}"` : ''}>
    <span class="progress__fill progress__fill--${tone}" style="width:${fill}%"></span>
  </div>`;
}
