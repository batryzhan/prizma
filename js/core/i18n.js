/**
 * GUILD-LEARN — Internationalization (i18n) Mapping
 */

const translations = {
  ru: {
    sidebar: {
      level: 'УРОВЕНЬ',
      utility: 'UTILITY SCORE',
      energy: 'ЭНЕРГИЯ',
      stats: 'СТАТИСТИКА',
      help: 'Помощь',
      requests: 'Запросы',
      reset: 'Сбросить данные',
      rank_max: '(МАКС)',
      edit_profile: 'Изменить профиль'
    },
    feed: {
      title: 'SOS-Запросы',
      create_btn: '+ СОЗДАТЬ SOS',
      search_placeholder: 'Поиск (текст/автор)...',
      empty: 'Нет активных SOS-запросов',
      reward: 'энергии',
      help_btn: '⚔ ПОМОЧЬ',
      delete_btn: '✕ Удалить',
      physics_module: '🧪 ПРАКТИЧЕСКИЙ МОДУЛЬ',
      physics_desc: 'Для лучшего понимания темы рекомендуем провести виртуальный эксперимент в лаборатории PhET.',
      physics_btn: '⚛ ИСПЫТАТЬ СИМУЛЯЦИЮ',
      resolved: '✓ Решено'
    },
    guild: {
      title: 'Участники',
      tab_guild: 'Гильдия',
      tab_chat: 'Чат',
      online: 'ОНЛАЙН',
      away: 'ОТОШЛИ',
      offline: 'ОФФЛАЙН',
      chat_placeholder: 'Написать в гильдию...',
      add_member: 'Новый участник',
      member_name: 'Имя участника',
      member_score: 'Энергия (Счет)',
      member_status: 'Статус',
      btn_add: 'Добавить',
      btn_cancel: 'Отмена'
    },
    modal: {
      profile_title: 'Профиль',
      player_name: 'Имя игрока',
      avatar_symbol: 'Символ (если нет фото)',
      avatar_url: 'Ссылка на фото (URL)',
      avatar_file: 'Загрузить файл',
      btn_save: 'Сохранить',
      btn_cancel: 'Отмена',
      toast_save: 'Профиль обновлён',
      toast_reset: 'Данные сброшены',
      reset_confirm: 'Сбросить все данные? Это действие необратимо.'
    },
    sos: {
      title: 'Новый SOS-запрос',
      subject: 'Предмет',
      desc: 'Опиши проблему',
      placeholder: 'Чем подробнее, тем лучше...',
      reward: 'Награда',
      btn_cancel: 'Отмена',
      btn_submit: 'Отправить SOS',
      easy: 'Лёгкий',
      medium: 'Средний',
      hard: 'Сложный',
      epic: 'Эпик'
    },
    subjects: {
      all: 'Все',
      math: 'Математика',
      physics: 'Физика',
      biology: 'Биология',
      chemistry: 'Химия',
      history: 'История',
      english: 'Английский'
    }
  },
  en: {
    sidebar: {
      level: 'LEVEL',
      utility: 'UTILITY SCORE',
      energy: 'ENERGY',
      stats: 'STATISTICS',
      help: 'Helped',
      requests: 'Requests',
      reset: 'Reset Data',
      rank_max: '(MAX)',
      edit_profile: 'Edit Profile'
    },
    feed: {
      title: 'SOS-Requests',
      create_btn: '+ CREATE SOS',
      search_placeholder: 'Search (text/author)...',
      empty: 'No active SOS requests',
      reward: 'energy',
      help_btn: '⚔ HELP',
      delete_btn: '✕ Delete',
      physics_module: '🧪 PRACTICAL MODULE',
      physics_desc: 'To better understand the topic, we recommend conducting a virtual experiment in the PhET lab.',
      physics_btn: '⚛ TEST SIMULATION',
      resolved: '✓ Resolved'
    },
    guild: {
      title: 'Members',
      tab_guild: 'Guild',
      tab_chat: 'Chat',
      online: 'ONLINE',
      away: 'AWAY',
      offline: 'OFFLINE',
      chat_placeholder: 'Message the guild...',
      add_member: 'New Member',
      member_name: 'Member Name',
      member_score: 'Energy (Score)',
      member_status: 'Status',
      btn_add: 'Add',
      btn_cancel: 'Cancel'
    },
    modal: {
      profile_title: 'Profile',
      player_name: 'Player Name',
      avatar_symbol: 'Symbol (if no photo)',
      avatar_url: 'Photo URL',
      avatar_file: 'Upload file',
      btn_save: 'Save',
      btn_cancel: 'Cancel',
      toast_save: 'Profile updated',
      toast_reset: 'Data reset',
      reset_confirm: 'Reset all data? This action is irreversible.'
    },
    sos: {
      title: 'New SOS-Request',
      subject: 'Subject',
      desc: 'Describe the problem',
      placeholder: 'The more detail, the better...',
      reward: 'Reward',
      btn_cancel: 'Cancel',
      btn_submit: 'Send SOS',
      easy: 'Easy',
      medium: 'Medium',
      hard: 'Hard',
      epic: 'Epic'
    },
    subjects: {
      all: 'All',
      math: 'Math',
      physics: 'Physics',
      biology: 'Biology',
      chemistry: 'Chemistry',
      history: 'History',
      english: 'English'
    }
  }
};

/**
 * Get translation for a specific language.
 * @param {string} lang - 'ru' or 'en'
 */
export function getI18n(lang = 'ru') {
  return translations[lang] || translations['en'];
}
