import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prizma/app/prizma_app.dart';
import 'package:prizma/features/community/community_screens.dart';
import 'package:prizma/features/dashboard/dashboard_screen.dart';
import 'package:prizma/features/landing/landing_screen.dart';
import 'package:prizma/features/personal/personal_screens.dart';
import 'package:prizma/features/sos/sos_screen.dart';
import 'package:prizma/features/subjects/subjects_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('landing opens the Flutter dashboard', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    await tester.pumpWidget(const PrizmaApp());
    await tester.pumpAndSettle();

    expect(find.byType(LandingScreen), findsOneWidget);

    await tester.tap(find.text('Войти'));
    await tester.pumpAndSettle();

    expect(find.byType(DashboardScreen), findsOneWidget);
  });

  testWidgets('desktop landing and dashboard fit a wide viewport', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues(<String, Object>{});

    await tester.pumpWidget(const PrizmaApp());
    await tester.pumpAndSettle();
    expect(find.byType(LandingScreen), findsOneWidget);

    await tester.tap(find.text('Открыть Prizma'));
    await tester.pumpAndSettle();
    expect(find.byType(DashboardScreen), findsOneWidget);
  });

  testWidgets('mobile navigation renders every workspace screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues(<String, Object>{});

    await tester.pumpWidget(const PrizmaApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Войти'));
    await tester.pumpAndSettle();

    Future<void> openFromDrawer(String label) async {
      final navigation = find.byType(NavigationBar);
      final menu = find.descendant(
        of: navigation,
        matching: find.byIcon(Icons.menu_rounded),
      );
      await tester.tap(menu);
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(of: find.byType(Drawer), matching: find.text(label)),
      );
      await tester.pumpAndSettle();
    }

    await openFromDrawer('Запросы');
    expect(find.byType(SosScreen), findsOneWidget);

    await openFromDrawer('Предметы');
    expect(find.byType(SubjectsScreen), findsOneWidget);

    await openFromDrawer('Гильдия');
    expect(find.byType(GuildScreen), findsOneWidget);

    await openFromDrawer('Рейтинг');
    expect(find.byType(LeaderboardScreen), findsOneWidget);

    await openFromDrawer('Прогресс');
    expect(find.byType(ProgressScreen), findsOneWidget);

    await openFromDrawer('Профиль');
    expect(find.byType(ProfileScreen), findsOneWidget);

    final navigation = find.byType(NavigationBar);
    await tester.tap(
      find.descendant(
        of: navigation,
        matching: find.byIcon(Icons.menu_rounded),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(Drawer),
        matching: find.byIcon(Icons.settings_outlined),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(SettingsScreen), findsOneWidget);
  });
}
