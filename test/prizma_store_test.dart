import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:prizma/core/persistence/prizma_repository.dart';
import 'package:prizma/core/state/prizma_store.dart';

void main() {
  group('PrizmaStore', () {
    test('initializes the complete legacy-equivalent seed data', () async {
      final store = PrizmaStore(
        repository: MemoryPrizmaRepository(),
        enableEnergyTimer: false,
      );
      addTearDown(store.dispose);

      await store.initialize();

      expect(store.isLoading, isFalse);
      expect(store.user.energy, 100);
      expect(store.sosList, hasLength(11));
      expect(store.sosList.where((item) => item.reward == 40), hasLength(1));
      expect(store.guild, hasLength(6));
      expect(store.chatMessages, hasLength(3));
    });

    test(
      'enforces SOS validation, spends energy, and refunds only own work',
      () async {
        final store = PrizmaStore(
          repository: MemoryPrizmaRepository(),
          enableEnergyTimer: false,
        );
        addTearDown(store.dispose);
        await store.initialize();

        expect(
          store.createSos(subject: 'math', question: 'коротко', reward: 10),
          isFalse,
        );
        expect(
          store.createSos(
            subject: 'math',
            question: 'Почему этот вопрос должен быть длиннее десяти символов?',
            reward: 40,
          ),
          isFalse,
        );
        expect(
          store.createSos(
            subject: 'math',
            question: 'Помогите понять метод подстановки в системе уравнений.',
            reward: 20,
          ),
          isTrue,
        );

        final mine = store.sosList.first;
        expect(store.user.energy, 80);
        expect(store.user.requestsCreated, 1);
        expect(store.helpWithSos(mine.id).code, 'own_request');
        expect(store.deleteSos(mine.id).isSuccess, isTrue);
        expect(store.user.energy, 100);
        expect(store.sosList.any((item) => item.id == mine.id), isFalse);
        expect(store.deleteSos('sos_1').code, 'not_owner');
      },
    );

    test(
      'help awards XP, levels up, resolves once, and caps energy at 100',
      () async {
        final store = PrizmaStore(
          repository: MemoryPrizmaRepository(),
          enableEnergyTimer: false,
        );
        addTearDown(store.dispose);
        await store.initialize();

        expect(store.helpWithSos('sos_7').isSuccess, isTrue); // +75 XP
        expect(store.user.energy, 100);
        expect(store.user.xp, 75);
        expect(store.user.level, 1);
        expect(store.user.utilityScore, 50);
        expect(store.user.helpGiven, 1);

        expect(store.helpWithSos('sos_10').isSuccess, isTrue); // +75 XP
        expect(store.user.xp, 50);
        expect(store.user.level, 2);
        expect(store.user.utilityScore, 100);
        expect(store.helpWithSos('sos_10').code, 'already_resolved');
      },
    );

    test('persists preferences and exports a typed backup envelope', () async {
      final repository = MemoryPrizmaRepository();
      final store = PrizmaStore(
        repository: repository,
        enableEnergyTimer: false,
      );
      addTearDown(store.dispose);
      await store.initialize();

      store.toggleTheme();
      store.toggleReduceMotion();
      store.toggleTask('plan_physics');
      final Map<String, dynamic> backup = Map<String, dynamic>.from(
        jsonDecode(store.exportJson()) as Map,
      );

      expect(store.isDark, isTrue);
      expect(store.reduceMotion, isTrue);
      expect(store.completedTaskIds, contains('plan_physics'));
      expect(backup['app'], 'Prizma');
      expect((backup['state'] as Map)['sosList'], hasLength(11));
      expect((backup['preferences'] as Map)['theme'], 'dark');

      final restored = PrizmaStore(
        repository: repository,
        enableEnergyTimer: false,
      );
      addTearDown(restored.dispose);
      await restored.initialize();
      expect(restored.isDark, isTrue);
      expect(restored.reduceMotion, isTrue);
      expect(restored.completedTaskIds, contains('plan_physics'));
    });

    test(
      'imports the web prototype once, trying prizma v2 before Guild-Learn',
      () async {
        final repository = MemoryPrizmaRepository();
        final reads = <String>[];
        final String legacyJson = jsonEncode(<String, dynamic>{
          'user': <String, dynamic>{'name': 'Ada', 'avatar': 'A', 'energy': 73},
          'sosList': <Object?>[],
          'guild': <Object?>[],
          'chatMessages': <Object?>[],
        });
        final store = PrizmaStore(
          repository: repository,
          enableEnergyTimer: false,
          legacyStorageReader: (key) async {
            reads.add(key);
            return key == 'guildlearn_state' ? legacyJson : null;
          },
        );
        addTearDown(store.dispose);

        await store.initialize();

        expect(reads, <String>['prizma:v2', 'guildlearn_state']);
        expect(store.user.name, 'Ada');
        expect(store.user.energy, 73);
        expect(repository.values[PrizmaStore.storageKey], isNotNull);
        expect(repository.values['prizma:flutter:v1:legacy-imported'], 'true');
      },
    );
  });
}
