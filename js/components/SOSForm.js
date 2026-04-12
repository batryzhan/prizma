// ═══════════════════════════════════════════════════
// GUILD-LEARN — SOS Form Component (Modal)
// ═══════════════════════════════════════════════════

import { CONFIG, getState } from '../store/state.js';
import { createSOSRequest } from '../core/engine.js';
import { getI18n } from '../core/i18n.js';

/**
 * Render the SOS creation form modal.
 */
export function renderSOSForm(onClose) {
  const { user } = getState();
  const t = getI18n(user.lang);

  const subjectOptions = CONFIG.subjects.map(s =>
    `<option value="${s.id}">${s.icon} ${t.subjects[s.id] || s.name}</option>`
  ).join('');

  const difficultyNames = [t.sos.easy, t.sos.medium, t.sos.hard, t.sos.epic];

  const energyOptions = CONFIG.energyCosts.map((cost, i) => `
    <div class="energy-option ${i === 0 ? 'active' : ''}"
         data-cost="${cost}" id="energy-opt-${cost}">
      <span class="energy-option__value">⚡${cost}</span>
      <span class="energy-option__label">${difficultyNames[i] || 'Level'}</span>
    </div>
  `).join('');

  return `
    <div class="modal-overlay" id="sos-modal-overlay">
      <div class="modal-panel" id="sos-modal">
        <div class="sos-form__title">
          <span>📡</span> ${t.sos.title}
        </div>

        <form id="sos-form">
          <div class="form-group">
            <label class="form-label" for="sos-subject">${t.sos.subject}</label>
            <select class="form-select" id="sos-subject" required>
              ${subjectOptions}
            </select>
          </div>

          <div class="form-group">
            <label class="form-label" for="sos-question">${t.sos.desc}</label>
            <textarea class="form-textarea" id="sos-question"
                      placeholder="${t.sos.placeholder}"
                      required minlength="10" maxlength="500"></textarea>
            <div class="form-char-count" id="char-count">0 / 500</div>
          </div>

          <div class="form-group">
            <label class="form-label">${t.sos.reward} (⚡ ${user.energy})</label>
            <div class="energy-selector" id="energy-selector">
              ${energyOptions}
            </div>
          </div>

          <div class="sos-form__actions">
            <button type="button" class="btn btn--secondary" id="btn-cancel-sos">${t.sos.btn_cancel}</button>
            <button type="submit" class="btn btn--primary" id="btn-submit-sos">
               ${t.sos.btn_submit}
            </button>
          </div>
        </form>
      </div>
    </div>
  `;
}

/**
 * Attach event listeners to the SOS form.
 */
export function attachSOSFormListeners(onClose) {
  const form = document.getElementById('sos-form');
  const overlay = document.getElementById('sos-modal-overlay');
  const cancelBtn = document.getElementById('btn-cancel-sos');
  const textarea = document.getElementById('sos-question');
  const charCount = document.getElementById('char-count');
  const selector = document.getElementById('energy-selector');

  let selectedCost = CONFIG.energyCosts[0];

  // Character counter
  textarea.addEventListener('input', () => {
    charCount.textContent = `${textarea.value.length} / 500`;
  });

  // Energy selector
  selector.addEventListener('click', (e) => {
    const option = e.target.closest('.energy-option');
    if (!option) return;

    selector.querySelectorAll('.energy-option').forEach(el => el.classList.remove('active'));
    option.classList.add('active');
    selectedCost = parseInt(option.dataset.cost, 10);
  });

  // Close
  cancelBtn.addEventListener('click', onClose);
  overlay.addEventListener('click', (e) => {
    if (e.target === overlay) onClose();
  });

  // Submit
  form.addEventListener('submit', (e) => {
    e.preventDefault();

    const subject = document.getElementById('sos-subject').value;
    const question = textarea.value.trim();

    if (question.length < 10) return;

    const success = createSOSRequest({
      subject,
      question,
      reward: selectedCost,
    });

    if (success) onClose();
  });
}
