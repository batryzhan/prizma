// ═══════════════════════════════════════════════════
// GUILD-LEARN — State (Single Source of Truth)
// ═══════════════════════════════════════════════════

import { loadState, saveState } from './persistence.js';

// ── Game Config (inlined to avoid fetch) ──
export const CONFIG = {
    subjects: [
        { id: 'math', name: 'Математика', icon: '∑', color: 'purple' },
        { id: 'physics', name: 'Физика', icon: '⚛', color: 'cyan' },
        { id: 'biology', name: 'Биология', icon: '🧬', color: 'green' },
        { id: 'chemistry', name: 'Химия', icon: '⚗', color: 'orange' },
        { id: 'history', name: 'История', icon: '📜', color: 'yellow' },
        { id: 'english', name: 'Английский', icon: '🌐', color: 'pink' },
    ],
    energyCosts: [10, 20, 30, 50],
    ranks: [
        { minScore: 0, name: 'Новичок' },
        { minScore: 50, name: 'Ученик' },
        { minScore: 150, name: 'Знаток' },
        { minScore: 350, name: 'Мастер' },
        { minScore: 700, name: 'Мудрец' },
        { minScore: 1500, name: 'Легенда' },
    ],
    xpPerLevel: 100,
    initialEnergy: 100,
};

// ── Default State ──
function createDefaultState() {
    return {
        user: {
            name: 'Player_01',
            avatar: 'P',
            avatarImage: null, // New field for uploaded image or URL
            level: 1,
            xp: 0,
            energy: CONFIG.initialEnergy,
            utilityScore: 0,
            lang: 'ru', // New: UI language
            helpGiven: 0,
            helpReceived: 0,
            requestsCreated: 0,
        },
        sosList: [],
        guild: [
            { id: 'g1', name: 'Mira_X', status: 'online', avatar: 'M', score: 230 },
            { id: 'g2', name: 'Dev_K', status: 'online', avatar: 'D', score: 180 },
            { id: 'g3', name: 'Luna_7', status: 'away', avatar: 'L', score: 310 },
            { id: 'g4', name: 'Kai_Z', status: 'online', avatar: 'K', score: 95 },
            { id: 'g5', name: 'Nova_R', status: 'offline', avatar: 'N', score: 420 },
            { id: 'g6', name: 'Zen_X', status: 'online', avatar: 'Z', score: 140 },
        ],
        chatMessages: [
            { from: 'Mira_X', text: 'Кто-нибудь шарит в квадратных уравнениях?', time: Date.now() - 300000 },
            { from: 'Dev_K', text: 'Да, скидывай задачу', time: Date.now() - 240000 },
            { from: 'Luna_7', text: 'Я только что закинула SOS по биологии 👀', time: Date.now() - 120000 },
        ],
    };
}

// ── Live State ──
let _state = null;
let _listeners = [];

/**
 * Initialize state: load from storage or create fresh.
 */
export function initState() {
    const saved = loadState();
    if (saved && saved.user) {
        _state = saved;
        // Ensure new fields exist after updates
        _state.user.helpGiven = _state.user.helpGiven || 0;
        _state.user.helpReceived = _state.user.helpReceived || 0;
        _state.user.requestsCreated = _state.user.requestsCreated || 0;
        if (!_state.guild) _state.guild = createDefaultState().guild;
        if (!_state.chatMessages) _state.chatMessages = createDefaultState().chatMessages;
    } else {
        _state = createDefaultState();
        // Seed some example SOS requests
        _state.sosList = generateMockSOS();
        _persist();
    }
    return _state;
}

/**
 * Get current state (read-only snapshot).
 */
export function getState() {
    return _state;
}

/**
 * Mutate state via updater function and persist.
 */
export function setState(updater) {
    updater(_state);
    _persist();
    _notify();
}

/**
 * Subscribe to state changes. Returns unsubscribe fn.
 */
export function subscribe(listener) {
    _listeners.push(listener);
    return () => {
        _listeners = _listeners.filter(l => l !== listener);
    };
}

function _persist() {
    saveState(_state);
}

function _notify() {
    _listeners.forEach(fn => fn(_state));
}

// ── Mock Data Generator ──
function generateMockSOS() {
    const now = Date.now();
    return [
        {
            id: 'sos_1',
            subject: 'math',
            question: 'Не могу решить систему уравнений: 2x + 3y = 12 и x - y = 1. Объясните метод подстановки пожалуйста!',
            reward: 20,
            author: 'Mira_X',
            authorAvatar: 'M',
            authorAvatarImage: null,
            createdAt: now - 600000,
            resolved: false,
        },
        {
            id: 'sos_2',
            subject: 'physics',
            question: 'Какое количество теплоты требуется, чтобы нагреть 2 кг воды на 10 градусов ? ',
            reward: 30,
            author: 'Dev_K',
            authorAvatar: 'D',
            authorAvatarImage: null,
            createdAt: now - 420000,
            resolved: false,
        },
        {
            id: 'sos_3',
            subject: 'biology',
            question: 'Чем отличается митоз от мейоза? Нужно краткое и понятное объяснение для завтрашнего теста.',
            reward: 30,
            author: 'Luna_7',
            authorAvatar: 'L',
            authorAvatarImage: null,
            createdAt: now - 180000,
            resolved: false,
        },
        {
            id: 'sos_4',
            subject: 'chemistry',
            question: 'Как уравнять реакцию: Fe + O₂ → Fe₂O₃? Никак не получается расставить коэффициенты.',
            reward: 20,
            author: 'Kai_Z',
            authorAvatar: 'K',
            authorAvatarImage: null,
            createdAt: now - 900000,
            resolved: false,
        },
        {
            id: 'sos_5',
            subject: 'history',
            question: 'Кто был первым правителем династии Романовых? И в каком году произошло его вошествие на престол?',
            reward: 20,
            author: 'Old_Soul',
            authorAvatar: 'O',
            authorAvatarImage: null,
            createdAt: now - 360000,
            resolved: false,
        },
        {
            id: 'sos_6',
            subject: 'english',
            question: 'Когда использовать Present Perfect, а когда Past Simple? Совсем запутался в этих временах.',
            reward: 30,
            author: 'Linguist_99',
            authorAvatar: 'L',
            authorAvatarImage: null,
            createdAt: now - 150000,
            resolved: false,
        },
        {
            id: 'sos_7',
            subject: 'math',
            question: 'Как вычислить производную функции f(x) = x³ + 2x^2 + 5x? Помогите с алгоритмом.',
            reward: 50,
            author: 'Math_Geek',
            authorAvatar: 'G',
            authorAvatarImage: null,
            createdAt: now - 720000,
            resolved: false,
        },
        {
            id: 'sos_8',
            subject: 'history',
            question: 'Назовите основные причины Великой французской революции (краткими тезисами).',
            reward: 40,
            author: 'Historian_X',
            authorAvatar: 'H',
            authorAvatarImage: null,
            createdAt: now - 540000,
            resolved: false,
        },
        {
            id: 'sos_9',
            subject: 'english',
            question: 'Напишите 5 синонимов к слову "Beautiful" для эссе. Желательно уровня C1/C2.',
            reward: 20,
            author: 'Writer_B',
            authorAvatar: 'W',
            authorAvatarImage: null,
            createdAt: now - 450000,
            resolved: false,
        },
        {
            id: 'sos_10',
            subject: 'chemistry',
            question: 'Что такое окислительно-восстановительные реакции? Буду очень благодарен за понятный пример.',
            reward: 50,
            author: 'Chem_Lover',
            authorAvatar: 'C',
            authorAvatarImage: null,
            createdAt: now - 90000,
            resolved: false,
        },
        {
            id: 'sos_11',
            subject: 'physics',
            question: 'Угол падения луча на зеркало равен 35 градусов. Чему равен угол отражения ?. Заранее спасибо!',
            reward: 50,
            author: 'Quantum_D',
            authorAvatar: 'Q',
            authorAvatarImage: null,
            createdAt: now - 240000,
            resolved: false,
        },
    ];
}
