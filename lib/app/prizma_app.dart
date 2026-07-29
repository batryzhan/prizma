import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../core/state/prizma_store.dart';
import '../features/landing/landing_screen.dart';
import '../shared/widgets/prizma_widgets.dart';
import 'app_shell.dart';
import 'prizma_theme.dart';

class PrizmaScope extends InheritedNotifier<PrizmaStore> {
  const PrizmaScope({
    super.key,
    required PrizmaStore store,
    required super.child,
  }) : super(notifier: store);

  static PrizmaStore watch(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<PrizmaScope>();
    assert(scope != null, 'PrizmaScope is missing above this widget.');
    return scope!.notifier!;
  }

  static PrizmaStore read(BuildContext context) {
    final element = context
        .getElementForInheritedWidgetOfExactType<PrizmaScope>();
    final scope = element?.widget as PrizmaScope?;
    assert(scope != null, 'PrizmaScope is missing above this widget.');
    return scope!.notifier!;
  }
}

class PrizmaApp extends StatefulWidget {
  const PrizmaApp({super.key});

  @override
  State<PrizmaApp> createState() => _PrizmaAppState();
}

class _PrizmaAppState extends State<PrizmaApp> {
  late final PrizmaStore _store;

  @override
  void initState() {
    super.initState();
    _store = PrizmaStore();
    _store.initialize();
  }

  @override
  void dispose() {
    _store.dispose();
    super.dispose();
  }

  String get _initialRoute {
    if (!kIsWeb) return '/';
    final fragment = Uri.base.fragment;
    if (fragment.isEmpty || fragment == '/') return '/';
    return fragment.startsWith('/') ? fragment : '/$fragment';
  }

  Route<dynamic> _routeFactory(RouteSettings settings) {
    final route = settings.name ?? '/';
    Widget page;
    if (route == '/') {
      page = const LandingScreen();
    } else if (AppShell.supportedRoutes.contains(route)) {
      page = AppShell(route: route);
    } else {
      page = const _NotFoundScreen();
    }
    return MaterialPageRoute<void>(settings: settings, builder: (_) => page);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _store,
      builder: (context, _) {
        return PrizmaScope(
          store: _store,
          child: MaterialApp(
            title: 'Prizma',
            debugShowCheckedModeBanner: false,
            theme: prizmaLightTheme(),
            darkTheme: prizmaDarkTheme(),
            themeMode: _store.isDark ? ThemeMode.dark : ThemeMode.light,
            initialRoute: _initialRoute,
            onGenerateRoute: _routeFactory,
            builder: (context, child) {
              final media = MediaQuery.of(context);
              return MediaQuery(
                data: media.copyWith(disableAnimations: _store.reduceMotion),
                child: child ?? const SizedBox.shrink(),
              );
            },
          ),
        );
      },
    );
  }
}

class _NotFoundScreen extends StatelessWidget {
  const _NotFoundScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: PrizmaCard(
              padding: const EdgeInsets.all(36),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const PrizmaLogo(compact: true),
                  const SizedBox(height: 22),
                  const Eyebrow('404 · маршрут не найден'),
                  const SizedBox(height: 10),
                  Text(
                    'Этой грани Prizma пока нет.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 9),
                  Text(
                    'Вернёмся туда, где можно продолжить учиться.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: pageMuted(context)),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () =>
                        Navigator.of(context).pushReplacementNamed('/'),
                    icon: const Icon(Icons.arrow_outward_rounded),
                    label: const Text('На главную'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
