import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/prizma_app.dart';
import '../../app/prizma_theme.dart';
import '../../core/models/prizma_models.dart';
import '../../shared/widgets/prizma_widgets.dart';

class SosScreen extends StatefulWidget {
  const SosScreen({super.key});

  @override
  State<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends State<SosScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _subject = 'all';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<SosRequest> _visibleRequests(List<SosRequest> items) {
    final query = _searchController.text.trim().toLowerCase();
    final visible = items
        .where((item) => _subject == 'all' || item.subject == _subject)
        .where(
          (item) =>
              query.isEmpty ||
              '${item.question} ${item.author}'.toLowerCase().contains(query),
        )
        .toList();
    visible.sort((a, b) {
      final resolved = (a.resolved ? 1 : 0).compareTo(b.resolved ? 1 : 0);
      return resolved != 0 ? resolved : b.createdAt.compareTo(a.createdAt);
    });
    return visible;
  }

  @override
  Widget build(BuildContext context) {
    final store = PrizmaScope.watch(context);
    final all = store.sosList;
    final visible = _visibleRequests(all);
    final unresolved = all.where((item) => !item.resolved).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 30, 24, 52),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1440),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 1000;
              final main = _SosMain(
                searchController: _searchController,
                selectedSubject: _subject,
                visible: visible,
                unresolved: unresolved,
                onChangedSearch: () => setState(() {}),
                onSubject: (id) => setState(() => _subject = id),
                onCreate: () => _openCreateDialog(context),
                onHelp: (id) => _help(context, id),
                onDelete: (id) => _delete(context, id),
              );
              final aside = _SosAside(
                all: all,
                onCreate: () => _openCreateDialog(context),
              );
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Header(onCreate: () => _openCreateDialog(context)),
                  const SizedBox(height: 25),
                  if (wide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: main),
                        const SizedBox(width: 18),
                        SizedBox(width: 282, child: aside),
                      ],
                    )
                  else ...[
                    main,
                    const SizedBox(height: 16),
                    aside,
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _openCreateDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => const _CreateSosDialog(),
    );
    if (!context.mounted || result == null) return;
    _show(
      context,
      result
          ? 'SOS-запрос создан. Гильдия уже рядом.'
          : 'Не удалось создать запрос. Проверь энергию и описание.',
      result,
    );
  }

  void _help(BuildContext context, String id) {
    final result = PrizmaScope.read(context).helpWithSos(id);
    _show(context, result.message, result.isSuccess);
  }

  void _delete(BuildContext context, String id) {
    final result = PrizmaScope.read(context).deleteSos(id);
    _show(context, result.message, result.isSuccess);
  }

  void _show(BuildContext context, String message, bool success) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? PrizmaColors.navy : PrizmaColors.danger,
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      const Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Eyebrow('Биржа помощи'),
            SizedBox(height: 7),
            Text(
              'Вопросы, которые ждут тебя',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w800,
                letterSpacing: -1.4,
              ),
            ),
            SizedBox(height: 9),
            Text(
              'Спрашивать — нормально. Объяснять — лучший способ закрепить знания.',
              style: TextStyle(color: PrizmaColors.inkSoft, fontSize: 13),
            ),
          ],
        ),
      ),
      const SizedBox(width: 12),
      FilledButton.icon(
        onPressed: onCreate,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Создать SOS'),
      ),
    ],
  );
}

class _SosMain extends StatelessWidget {
  const _SosMain({
    required this.searchController,
    required this.selectedSubject,
    required this.visible,
    required this.unresolved,
    required this.onChangedSearch,
    required this.onSubject,
    required this.onCreate,
    required this.onHelp,
    required this.onDelete,
  });

  final TextEditingController searchController;
  final String selectedSubject;
  final List<SosRequest> visible;
  final int unresolved;
  final VoidCallback onChangedSearch;
  final ValueChanged<String> onSubject;
  final VoidCallback onCreate;
  final ValueChanged<String> onHelp;
  final ValueChanged<String> onDelete;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      PrizmaCard(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              onChanged: (_) => onChangedSearch(),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search_rounded),
                hintText: 'Поиск по вопросу или автору',
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _FilterChip(
                      label: 'Все',
                      selected: selectedSubject == 'all',
                      onTap: () => onSubject('all'),
                    ),
                    for (final subject in PrizmaConfig.subjects)
                      _FilterChip(
                        label: '${subject.icon} ${subject.name}',
                        selected: selectedSubject == subject.id,
                        onTap: () => onSubject(subject.id),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 26),
      Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: SectionHeading(
              eyebrow: 'Сейчас в ленте',
              title: '$unresolved открытых запросов',
            ),
          ),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
            label: const Text('Сначала новые'),
          ),
        ],
      ),
      const SizedBox(height: 13),
      if (visible.isEmpty)
        EmptyPrizmaState(
          icon: Icons.search_rounded,
          title: 'Ничего не нашлось',
          message: 'Попробуй изменить предмет или формулировку поиска.',
          action: FilledButton(
            onPressed: onCreate,
            child: const Text('Создать SOS'),
          ),
        )
      else
        ...visible.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 11),
            child: _SosCard(
              request: item,
              onHelp: () => onHelp(item.id),
              onDelete: () => onDelete(item.id),
            ),
          ),
        ),
    ],
  );
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(right: 7),
    child: FilterChip(
      label: Text(
        label,
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
      ),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: Theme.of(context).colorScheme.primary,
      showCheckmark: false,
      side: BorderSide(
        color: selected
            ? Theme.of(context).colorScheme.primary
            : pageLine(context),
      ),
      labelStyle: TextStyle(
        color: selected ? Colors.white : pageMuted(context),
      ),
      backgroundColor: pageSurface(context),
    ),
  );
}

class _SosCard extends StatelessWidget {
  const _SosCard({
    required this.request,
    required this.onHelp,
    required this.onDelete,
  });

  final SosRequest request;
  final VoidCallback onHelp;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final store = PrizmaScope.watch(context);
    final own = request.author == store.user.name;
    return Opacity(
      opacity: request.resolved ? .66 : 1,
      child: PrizmaCard(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SubjectChip(request.subject),
                const Spacer(),
                Text(
                  relativeTime(request.createdAt),
                  style: TextStyle(color: pageMuted(context), fontSize: 10),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              request.question,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                height: 1.38,
              ),
            ),
            const SizedBox(height: 14),
            LayoutBuilder(
              builder: (context, constraints) {
                final actions = _Actions(
                  request: request,
                  own: own,
                  onHelp: onHelp,
                  onDelete: onDelete,
                );
                if (constraints.maxWidth < 500) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Author(request: request),
                      const SizedBox(height: 11),
                      actions,
                    ],
                  );
                }
                return Row(
                  children: [
                    Expanded(child: _Author(request: request)),
                    actions,
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Author extends StatelessWidget {
  const _Author({required this.request});

  final SosRequest request;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      UserAvatar(
        initials: request.authorAvatar,
        imageUrl: request.authorAvatarImage,
        size: 27,
      ),
      const SizedBox(width: 7),
      Text(
        request.author,
        style: TextStyle(
          color: pageMuted(context),
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    ],
  );
}

class _Actions extends StatelessWidget {
  const _Actions({
    required this.request,
    required this.own,
    required this.onHelp,
    required this.onDelete,
  });

  final SosRequest request;
  final bool own;
  final VoidCallback onHelp;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    if (request.resolved) {
      return const Chip(
        avatar: Icon(Icons.check_rounded, color: PrizmaColors.green, size: 15),
        label: Text(
          'Решено',
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800),
        ),
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            const Icon(Icons.bolt_rounded, color: Color(0xFFC48D11), size: 16),
            const SizedBox(width: 2),
            Text(
              '${request.reward}',
              style: const TextStyle(
                color: Color(0xFFC48D11),
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(width: 11),
        if (own)
          IconButton(
            onPressed: onDelete,
            tooltip: 'Удалить запрос',
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: PrizmaColors.danger,
              size: 19,
            ),
          )
        else
          FilledButton.tonalIcon(
            onPressed: onHelp,
            icon: const Icon(Icons.arrow_outward_rounded, size: 15),
            label: const Text('Помочь'),
          ),
      ],
    );
  }
}

class _SosAside extends StatelessWidget {
  const _SosAside({required this.all, required this.onCreate});

  final List<SosRequest> all;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            colors: [Color(0xFF7551FF), Color(0xFF5130C5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x337551FF),
              blurRadius: 26,
              offset: Offset(0, 14),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .14),
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 18),
            const Eyebrow('Не застревай надолго', color: Color(0xFFD8D0FF)),
            const SizedBox(height: 10),
            const Text(
              'Твой вопрос может стать чьим-то пониманием.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                height: 1.15,
              ),
            ),
            const SizedBox(height: 9),
            const Text(
              'Добавь контекст, выбери награду и получи поддержку от гильдии.',
              style: TextStyle(
                color: Color(0xD9FFFFFF),
                fontSize: 11,
                height: 1.55,
              ),
            ),
            const SizedBox(height: 19),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: PrizmaColors.violetDeep,
                ),
                onPressed: onCreate,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Задать вопрос'),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      PrizmaCard(
        padding: const EdgeInsets.all(19),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeading(
              eyebrow: 'Пульс предметов',
              title: 'Где помощь нужнее',
            ),
            const SizedBox(height: 17),
            for (final subject in PrizmaConfig.subjects) ...[
              _SubjectPulse(
                subject: subject,
                count: all
                    .where(
                      (item) => item.subject == subject.id && !item.resolved,
                    )
                    .length,
              ),
              const SizedBox(height: 11),
            ],
          ],
        ),
      ),
    ],
  );
}

class _SubjectPulse extends StatelessWidget {
  const _SubjectPulse({required this.subject, required this.count});

  final SubjectDefinition subject;
  final int count;

  @override
  Widget build(BuildContext context) {
    final color = subjectInfo(subject.id).color;
    return Column(
      children: [
        Row(
          children: [
            SubjectChip(subject.id),
            const Spacer(),
            Text(
              '$count',
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800),
            ),
          ],
        ),
        const SizedBox(height: 5),
        ProgressLine(
          value: math.min(1.0, count * .18),
          color: color,
          height: 4,
        ),
      ],
    );
  }
}

class _CreateSosDialog extends StatefulWidget {
  const _CreateSosDialog();

  @override
  State<_CreateSosDialog> createState() => _CreateSosDialogState();
}

class _CreateSosDialogState extends State<_CreateSosDialog> {
  final _formKey = GlobalKey<FormState>();
  final _question = TextEditingController();
  String _subject = 'math';
  int _reward = 10;

  @override
  void dispose() {
    _question.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = PrizmaScope.watch(context);
    return AlertDialog(
      title: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Eyebrow('Новый SOS-запрос'),
          SizedBox(height: 7),
          Text('Давай распутаем задачу'),
        ],
      ),
      content: SizedBox(
        width: 510,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Чем яснее контекст, тем легче гильдии дать полезный ответ.',
                  style: TextStyle(color: pageMuted(context), fontSize: 12),
                ),
                const SizedBox(height: 17),
                DropdownButtonFormField<String>(
                  initialValue: _subject,
                  decoration: const InputDecoration(labelText: 'Предмет'),
                  items: PrizmaConfig.subjects
                      .map(
                        (subject) => DropdownMenuItem(
                          value: subject.id,
                          child: Text('${subject.icon} ${subject.name}'),
                        ),
                      )
                      .toList(),
                  onChanged: (value) =>
                      setState(() => _subject = value ?? _subject),
                ),
                const SizedBox(height: 13),
                TextFormField(
                  controller: _question,
                  minLines: 4,
                  maxLines: 7,
                  maxLength: 500,
                  decoration: const InputDecoration(
                    labelText: 'В чём нужна помощь?',
                    hintText:
                        'Например: не понимаю, с чего начать решать систему уравнений…',
                  ),
                  validator: (value) => (value?.trim().length ?? 0) < 10
                      ? 'Опиши вопрос хотя бы в 10 символах.'
                      : null,
                ),
                const SizedBox(height: 5),
                Text(
                  'Награда за помощь · у тебя ${store.user.energy} энергии',
                  style: TextStyle(
                    color: pageMuted(context),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children: PrizmaConfig.sosRewards
                      .map(
                        (reward) => ChoiceChip(
                          label: Text('⚡ $reward'),
                          selected: _reward == reward,
                          onSelected: (_) => setState(() => _reward = reward),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
        FilledButton.icon(
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            final success = PrizmaScope.read(context).createSos(
              subject: _subject,
              question: _question.text.trim(),
              reward: _reward,
            );
            Navigator.of(context).pop(success);
          },
          icon: const Icon(Icons.arrow_outward_rounded),
          label: const Text('Отправить запрос'),
        ),
      ],
    );
  }
}
