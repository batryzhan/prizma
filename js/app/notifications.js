import { icon } from './icons.js';
import { escapeHtml } from './renderers.js';

/**
 * Render a short, accessible in-app notification.
 * Kept outside the app bootstrap so domain actions never need to import main.js.
 */
export function showToast(message, type = 'info') {
  let container = document.getElementById('toast-container');
  if (!container) {
    container = document.createElement('div');
    container.id = 'toast-container';
    container.className = 'toast-container';
    container.setAttribute('aria-live', 'polite');
    document.body.appendChild(container);
  }

  const icons = { success: 'check', error: 'info', info: 'sparkles' };
  const toast = document.createElement('div');
  toast.className = `toast toast--${type}`;
  toast.innerHTML = `<span>${icon(icons[type] || 'info', 17)}</span><p>${escapeHtml(message)}</p><button type="button" aria-label="Закрыть">${icon('close', 15)}</button>`;
  toast.querySelector('button')?.addEventListener('click', () => toast.remove());
  container.appendChild(toast);

  window.setTimeout(() => {
    toast.classList.add('toast--leaving');
    window.setTimeout(() => toast.remove(), 180);
  }, 3800);
}
