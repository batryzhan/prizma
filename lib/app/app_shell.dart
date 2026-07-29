import 'package:flutter/material.dart';

import '../core/state/prizma_store.dart';
import '../features/community/community_screens.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/personal/personal_screens.dart';
import '../features/sos/sos_screen.dart';
import '../features/subjects/subjects_screen.dart';
import '../shared/widgets/prizma_widgets.dart';
import 'prizma_app.dart';
import 'prizma_theme.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.route});

  final String route;

  static const supportedRoutes = <String>{
    '/dashboard',
    '/sos',
    '/subjects',
    '/guild',
    '/leaderboard',
    '/progress',
    '/profile',
    '/settings',
  };

  static const destinations = <_Destination>[
    _Destination(
      '/dashboard',
      'Обзор',
      Icons.grid_view_rounded,
      'Рабочее пространство',
    ),
    _Destination(
      '/sos',
      'Запросы',
      Icons.forum_outlined,
      'Рабочее пространство',
    ),
    _Destination(
      '/subjects',
      'Предметы',
      Icons.menu_book_outlined,
      'Рабочее пространство',
    ),
    _Destination('/guild', 'Гильдия', Icons.groups_rounded, 'Сообщество'),
    _Destination(
      '/leaderboard',
      'Рейтинг',
      Icons.emoji_events_outlined,
      'Сообщество',
    ),
    _Destination(
      '/progress',
      'Прогресс',
      Icons.auto_awesome_outlined,
      'Личный рост',
    ),
    _Destination(
      '/profile',
      'Профиль',
      Icons.person_outline_rounded,
      'Личный рост',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width >= 980;
    final store = PrizmaScope.watch(context);
    final content = _pageForRoute(route);
    if (!isDesktop) {
      return Scaffold(
        appBar: _TopBar(route: route),
        drawer: _PrizmaDrawer(route: route),
        body: SafeArea(top: false, child: content),
        bottomNavigationBar: _MobileNav(route: route),
      );
    }

    return Scaffold(
      body: Row(
        children: [
          _DesktopSidebar(route: route, store: store),
          Expanded(
            child: Column(
              children: [
                _TopBar(route: route),
                Expanded(child: SafeArea(top: false, child: content)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _pageForRoute(String name) {
    return switch (name) {
      '/dashboard' => const DashboardScreen(),
      '/sos' => const SosScreen(),
      '/subjects' => const SubjectsScreen(),
      '/guild' => const GuildScreen(),
      '/leaderboard' => const LeaderboardScreen(),
      '/progress' => const ProgressScreen(),
      '/profile' => const ProfileScreen(),
      '/settings' => const SettingsScreen(),
      _ => const DashboardScreen(),
    };
  }
}

class _DesktopSidebar extends StatelessWidget {
  const _DesktopSidebar({required this.route, required this.store});

  final String route;
  final PrizmaStore store;

  @override
  Widget build(BuildContext context) {
    final groups = <String, List<_Destination>>{};
    for (final item in AppShell.destinations) {
      groups.putIfAbsent(item.group, () => []).add(item);
    }
    return Container(
      width: 270,
      decoration: BoxDecoration(
        color: pageSurface(context),
        border: Border(right: BorderSide(color: pageLine(context))),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(15, 22, 15, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 9),
                child: PrizmaLogo(onTap: () => _go(context, '/dashboard')),
              ),
              const SizedBox(height: 33),
              Expanded(
                child: ListView(
                  children: [
                    for (final group in groups.entries) ...[
                      _SidebarGroup(
                        label: group.key,
                        items: group.value,
                        route: route,
                      ),
                      const SizedBox(height: 20),
                    ],
                  ],
                ),
              ),
              _FocusCard(onTap: () => _go(context, '/progress')),
              const SizedBox(height: 14),
              _ProfileButton(
                store: store,
                onTap: () => _go(context, '/profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SidebarGroup extends StatelessWidget {
  const _SidebarGroup({
    required this.label,
    required this.items,
    required this.route,
  });

  final String label;
  final List<_Destination> items;
  final String route;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 12, bottom: 6),
        child: Text(
          label.toUpperCase(),
          style: TextStyle(
            color: pageMuted(context),
            fontSize: 9,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
      ),
      for (final item in items)
        Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: _NavItem(item: item, selected: item.route == route),
        ),
    ],
  );
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.item,
    required this.selected,
    this.closeDrawer = false,
  });

  final _Destination item;
  final bool selected;
  final bool closeDrawer;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? Theme.of(context).colorScheme.primary
        : pageMuted(context);
    return Material(
      color: selected ? PrizmaColors.violetSoft : Colors.transparent,
      borderRadius: BorderRadius.circular(11),
      child: InkWell(
        onTap: () {
          if (closeDrawer) Navigator.of(context).pop();
          _go(context, item.route);
        },
        borderRadius: BorderRadius.circular(11),
        child: Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Icon(item.icon, size: 19, color: color),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.label,
                  style: TextStyle(
                    color: selected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).textTheme.bodyMedium?.color,
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
              ),
              if (item.route == '/sos')
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? Colors.white.withValues(alpha: .58)
                        : PrizmaColors.violetSoft,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    'SOS',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FocusCard extends StatelessWidget {
  const _FocusCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    borderRadius: BorderRadius.circular(17),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(17),
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(17),
          gradient: const LinearGradient(
            colors: [Color(0xFF7B58F6), Color(0xFF5835D5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x337551FF),
              blurRadius: 22,
              offset: Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.gps_fixed_rounded,
                  color: Color(0xFFE4DEFF),
                  size: 16,
                ),
                SizedBox(width: 7),
                Text(
                  'ДНЕВНОЙ ФОКУС',
                  style: TextStyle(
                    color: Color(0xFFDCD5FF),
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: .8,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 11),
            const Text(
              '2 из 3 задач',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: const LinearProgressIndicator(
                value: .67,
                minHeight: 5,
                color: Colors.white,
                backgroundColor: Color(0x668B71E8),
              ),
            ),
            const SizedBox(height: 12),
            const Row(
              children: [
                Text(
                  'Открыть план',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(width: 5),
                Icon(
                  Icons.arrow_outward_rounded,
                  color: Colors.white,
                  size: 14,
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

class _ProfileButton extends StatelessWidget {
  const _ProfileButton({required this.store, required this.onTap});

  final PrizmaStore store;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 8),
      child: Row(
        children: [
          UserAvatar(
            initials: store.user.avatar,
            imageUrl: store.user.avatarImage,
            size: 40,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  store.user.name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  'Уровень ${store.user.level} · ${store.user.utilityScore} pts',
                  style: TextStyle(color: pageMuted(context), fontSize: 9),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _go(context, '/settings'),
            icon: const Icon(Icons.settings_outlined, size: 18),
            tooltip: 'Настройки',
          ),
        ],
      ),
    ),
  );
}

class _TopBar extends StatelessWidget implements PreferredSizeWidget {
  const _TopBar({required this.route});

  final String route;

  @override
  Size get preferredSize => const Size.fromHeight(76);

  @override
  Widget build(BuildContext context) {
    final store = PrizmaScope.watch(context);
    final destination = AppShell.destinations
        .where((item) => item.route == route)
        .firstOrNull;
    final title = destination?.label ?? 'Настройки';
    final group = destination?.group ?? 'Личный рост';
    final compactHeader = MediaQuery.sizeOf(context).width < 520;
    return AppBar(
      toolbarHeight: 76,
      titleSpacing: compactHeader ? 12 : 22,
      title: compactHeader
          ? Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
            )
          : Row(
              children: [
                Text(
                  group,
                  style: TextStyle(
                    color: pageMuted(context),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: pageMuted(context),
                    size: 16,
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
      actions: [
        if (MediaQuery.sizeOf(context).width >= 650)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: SizedBox(
              width: 205,
              child: OutlinedButton.icon(
                onPressed: () => _go(context, '/sos'),
                icon: const Icon(Icons.search_rounded, size: 18),
                label: const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Найти в Prizma', style: TextStyle(fontSize: 11)),
                ),
              ),
            ),
          ),
        IconButton(
          onPressed: () => _showInfo(context),
          icon: const Icon(Icons.notifications_none_rounded),
          tooltip: 'Уведомления',
        ),
        IconButton(
          onPressed: store.toggleTheme,
          icon: Icon(
            store.isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
          ),
          tooltip: 'Сменить тему',
        ),
        const SizedBox(width: 9),
      ],
    );
  }
}

class _PrizmaDrawer extends StatelessWidget {
  const _PrizmaDrawer({required this.route});

  final String route;

  @override
  Widget build(BuildContext context) => Drawer(
    child: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: PrizmaLogo(onTap: () => _go(context, '/dashboard')),
            ),
            const SizedBox(height: 28),
            Expanded(
              child: ListView(
                children: [
                  for (final item in AppShell.destinations)
                    _NavItem(
                      item: item,
                      selected: item.route == route,
                      closeDrawer: true,
                    ),
                ],
              ),
            ),
            _ProfileButton(
              store: PrizmaScope.watch(context),
              onTap: () => _go(context, '/profile'),
            ),
          ],
        ),
      ),
    ),
  );
}

class _MobileNav extends StatelessWidget {
  const _MobileNav({required this.route});

  final String route;

  @override
  Widget build(BuildContext context) {
    const routes = ['/dashboard', '/sos', '/subjects'];
    final selected = routes.indexOf(route);
    return NavigationBar(
      selectedIndex: selected < 0 ? 3 : selected,
      onDestinationSelected: (index) {
        if (index == 3) {
          Scaffold.of(context).openDrawer();
          return;
        }
        _go(context, routes[index]);
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.grid_view_rounded),
          label: 'Обзор',
        ),
        NavigationDestination(
          icon: Icon(Icons.forum_outlined),
          label: 'Запросы',
        ),
        NavigationDestination(
          icon: Icon(Icons.menu_book_outlined),
          label: 'Предметы',
        ),
        NavigationDestination(icon: Icon(Icons.menu_rounded), label: 'Ещё'),
      ],
    );
  }
}

class _Destination {
  const _Destination(this.route, this.label, this.icon, this.group);

  final String route;
  final String label;
  final IconData icon;
  final String group;
}

void _go(BuildContext context, String route) {
  if (ModalRoute.of(context)?.settings.name == route) return;
  Navigator.of(context).pushReplacementNamed(route);
}

void _showInfo(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text(
        'Новых личных уведомлений пока нет. Лента SOS уже ждёт тебя.',
      ),
    ),
  );
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    return iterator.moveNext() ? iterator.current : null;
  }
}
