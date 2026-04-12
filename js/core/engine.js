// ═══════════════════════════════════════════════════
// GUILD-LEARN — Engine (Help Logic & Energy Calc)
// ═══════════════════════════════════════════════════

import { getState, setState } from '../store/state.js';
import { uid, clamp } from './utils.js';
import { showToast } from '../main.js';

/**
 * Create a new SOS request.
 * Deducts energy from the user.
 */
export function createSOSRequest({ subject, question, reward }) {
  const state = getState();

  if (state.user.energy < reward) {
    showToast('Недостаточно энергии!', 'error');
    return false;
  }

  const newSOS = {
    id: uid(),
    subject,
    question,
    reward,
    author: state.user.name,
    authorAvatar: state.user.avatar,
    authorAvatarImage: state.user.avatarImage, 
    createdAt: Date.now(),
    resolved: false,
  };

  setState(s => {
    s.user.energy = clamp(s.user.energy - reward, 0, 9999);
    s.user.requestsCreated += 1;
    s.sosList.unshift(newSOS);
  });

  showToast(`SOS-запрос создан! -${reward}⚡`, 'success');
  return true;
}

/**
 * Help with an SOS request.
 * Awards energy + XP + utility score to the helper (current user).
 * Marks the request as resolved.
 */
export function helpWithRequest(sosId) {
  const state = getState();
  const sos = state.sosList.find(s => s.id === sosId);

  if (!sos) {
    showToast('Запрос не найден', 'error');
    return false;
  }

  if (sos.resolved) {
    showToast('Запрос уже решён', 'error');
    return false;
  }

  if (sos.author === state.user.name) {
    showToast('Нельзя помочь самому себе!', 'error');
    return false;
  }

  const xpGain = Math.floor(sos.reward * 1.5);
  const scoreGain = sos.reward;

  setState(s => {
    // Award to helper
    s.user.energy = clamp(s.user.energy + sos.reward, 0, 9999);
    s.user.xp += xpGain;
    s.user.utilityScore += scoreGain;
    s.user.helpGiven += 1;

    // Level up check
    while (s.user.xp >= 100) {
      s.user.xp -= 100;
      s.user.level += 1;
    }

    // Mark resolved
    const target = s.sosList.find(r => r.id === sosId);
    if (target) target.resolved = true;
  });

  showToast(`Помощь оказана! +${sos.reward}⚡ +${xpGain}XP`, 'success');
  return true;
}

/**
 * Delete an SOS request (only by author).
 */
export function deleteSOSRequest(sosId) {
  const state = getState();
  const sos = state.sosList.find(s => s.id === sosId);

  if (!sos || sos.author !== state.user.name) {
    return false;
  }

  setState(s => {
    // Refund energy
    s.user.energy = clamp(s.user.energy + sos.reward, 0, 9999);
    s.sosList = s.sosList.filter(r => r.id !== sosId);
  });

  showToast('Запрос удалён, энергия возвращена', 'info');
  return true;
}
