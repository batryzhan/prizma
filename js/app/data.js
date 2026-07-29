export const NAVIGATION = [
  {
    label: 'Рабочее пространство',
    items: [
      { route: 'dashboard', label: 'Обзор', icon: 'dashboard' },
      { route: 'sos', label: 'Запросы', icon: 'requests', badge: 'SOS' },
      { route: 'subjects', label: 'Предметы', icon: 'book' },
    ],
  },
  {
    label: 'Сообщество',
    items: [
      { route: 'guild', label: 'Гильдия', icon: 'users' },
      { route: 'leaderboard', label: 'Рейтинг', icon: 'trophy' },
    ],
  },
  {
    label: 'Личный рост',
    items: [
      { route: 'progress', label: 'Прогресс', icon: 'sparkles' },
      { route: 'profile', label: 'Профиль', icon: 'user' },
    ],
  },
];

export const ROUTE_META = {
  dashboard: { title: 'Обзор', crumb: 'Рабочее пространство' },
  sos: { title: 'Запросы', crumb: 'Рабочее пространство' },
  subjects: { title: 'Предметы', crumb: 'Рабочее пространство' },
  guild: { title: 'Гильдия', crumb: 'Сообщество' },
  leaderboard: { title: 'Рейтинг', crumb: 'Сообщество' },
  progress: { title: 'Прогресс', crumb: 'Личный рост' },
  profile: { title: 'Профиль', crumb: 'Личный рост' },
  settings: { title: 'Настройки', crumb: 'Личный рост' },
};

export const DAILY_PLAN = [
  { id: 'plan_math', time: '09:30', title: 'Разобрать квадратные уравнения', subject: 'math', duration: '35 мин', done: true },
  { id: 'plan_physics', time: '13:00', title: 'Практика: законы отражения', subject: 'physics', duration: '25 мин', done: false },
  { id: 'plan_english', time: '18:30', title: 'Повторить Present Perfect', subject: 'english', duration: '20 мин', done: false },
];

export const RESOURCES = {
  math: [
    { type: 'Разбор', title: 'Системы уравнений без паники', time: '12 мин', gradient: 'violet' },
    { type: 'Тренажёр', title: 'Производные: 10 коротких задач', time: '20 мин', gradient: 'violet-soft' },
  ],
  physics: [
    { type: 'Интерактив', title: 'Свет, зеркала и отражение', time: '15 мин', gradient: 'blue' },
    { type: 'Шпаргалка', title: 'Теплота: формулы и единицы', time: '8 мин', gradient: 'blue-soft' },
  ],
  biology: [
    { type: 'Конспект', title: 'Митоз и мейоз: на одной схеме', time: '10 мин', gradient: 'green' },
    { type: 'Квиз', title: 'Клеточный цикл', time: '7 мин', gradient: 'green-soft' },
  ],
  chemistry: [
    { type: 'Практика', title: 'Как расставлять коэффициенты', time: '14 мин', gradient: 'orange' },
    { type: 'Карточки', title: 'ОВР: главное за 5 минут', time: '5 мин', gradient: 'orange-soft' },
  ],
  history: [
    { type: 'Таймлайн', title: 'Романовы: ключевые даты', time: '11 мин', gradient: 'pink' },
    { type: 'Квиз', title: 'Французская революция', time: '9 мин', gradient: 'pink-soft' },
  ],
  english: [
    { type: 'Разбор', title: 'Present Perfect или Past Simple?', time: '13 мин', gradient: 'cyan' },
    { type: 'Словарь', title: 'Сильные слова для эссе', time: '6 мин', gradient: 'cyan-soft' },
  ],
};

export const ACHIEVEMENTS = [
  { icon: 'bolt', tone: 'yellow', title: 'Первый импульс', text: 'Создай первый SOS-запрос', value: 1 },
  { icon: 'heart', tone: 'pink', title: 'Надёжная опора', text: 'Помоги 5 ученикам', value: 5 },
  { icon: 'flame', tone: 'orange', title: 'Неделя в ритме', text: 'Учись 7 дней подряд', value: 7 },
  { icon: 'trophy', tone: 'violet', title: 'Точка роста', text: 'Набери 100 utility points', value: 100 },
];

export const CALENDAR_DAYS = [
  { day: 1, muted: true }, { day: 2, muted: true }, { day: 3, muted: true }, { day: 4, muted: true },
  { day: 5, muted: true }, { day: 6, muted: true }, { day: 7, muted: true },
  { day: 8 }, { day: 9 }, { day: 10 }, { day: 11 }, { day: 12 }, { day: 13 }, { day: 14 },
  { day: 15 }, { day: 16, event: 'violet' }, { day: 17, event: 'cyan' }, { day: 18 }, { day: 19, event: 'pink' },
  { day: 20 }, { day: 21 }, { day: 22 }, { day: 23, event: 'orange' }, { day: 24, today: true }, { day: 25 },
  { day: 26, event: 'green' }, { day: 27 }, { day: 28 }, { day: 29 }, { day: 30 }, { day: 31 },
  { day: 1, muted: true }, { day: 2, muted: true }, { day: 3, muted: true }, { day: 4, muted: true },
];
