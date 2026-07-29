import 'package:flutter/material.dart';

import '../../app/prizma_app.dart';
import '../../app/prizma_theme.dart';
import '../../core/models/prizma_models.dart';
import '../../shared/widgets/prizma_widgets.dart';

/// The shared guild space: presence, lightweight coordination and chat.
class GuildScreen extends StatefulWidget {
  const GuildScreen({super.key});

  @override
  State<GuildScreen> createState() => _GuildScreenState();
}

class _GuildScreenState extends State<GuildScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _messageFocusNode = FocusNode();

  @override
  void dispose() {
    _messageController.dispose();
    _messageFocusNode.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    PrizmaScope.read(context).sendChatMessage(text);
    _messageController.clear();
    _messageFocusNode.requestFocus();
  }

  Future<void> _showAddMemberDialog() async {
    final controller = TextEditingController();
    String status = 'online';
    String? error;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: const Text('Пригласить в гильдию'),
          content: SizedBox(
            width: 380,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Добавь участника, чтобы его можно было видеть в общем пространстве.',
                  style: TextStyle(
                    color: pageMuted(dialogContext),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: controller,
                  autofocus: true,
                  maxLength: 20,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: 'Имя участника',
                    hintText: 'Например, Алия',
                    errorText: error,
                  ),
                  onChanged: (_) {
                    if (error != null) setDialogState(() => error = null);
                  },
                  onSubmitted: (_) {
                    final name = controller.text.trim();
                    if (name.isEmpty) {
                      setDialogState(() => error = 'Укажи имя участника');
                      return;
                    }
                    PrizmaScope.read(
                      context,
                    ).addGuildMember(name: name, status: status);
                    Navigator.of(dialogContext).pop();
                    _showMessage('$name теперь в гильдии');
                  },
                ),
                const SizedBox(height: 4),
                DropdownButtonFormField<String>(
                  initialValue: status,
                  decoration: const InputDecoration(labelText: 'Статус'),
                  items: const [
                    DropdownMenuItem(value: 'online', child: Text('В сети')),
                    DropdownMenuItem(value: 'away', child: Text('Отошёл')),
                    DropdownMenuItem(
                      value: 'offline',
                      child: Text('Не в сети'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) setDialogState(() => status = value);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Отмена'),
            ),
            FilledButton.icon(
              onPressed: () {
                final name = controller.text.trim();
                if (name.isEmpty) {
                  setDialogState(() => error = 'Укажи имя участника');
                  return;
                }
                PrizmaScope.read(
                  context,
                ).addGuildMember(name: name, status: status);
                Navigator.of(dialogContext).pop();
                _showMessage('$name теперь в гильдии');
              },
              icon: const Icon(Icons.person_add_alt_1_rounded),
              label: const Text('Добавить'),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final store = PrizmaScope.watch(context);
    final members = [...store.guild]
      ..sort((left, right) {
        final byStatus = _statusOrder(
          left.status,
        ).compareTo(_statusOrder(right.status));
        return byStatus == 0 ? right.score.compareTo(left.score) : byStatus;
      });
    final onlineCount = members
        .where((member) => member.status == 'online')
        .length;
    final messages = store.chatMessages.length > 30
        ? store.chatMessages.sublist(store.chatMessages.length - 30)
        : store.chatMessages;

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 1020;
        final horizontalPadding = constraints.maxWidth >= 900 ? 32.0 : 20.0;
        final membersCard = _MembersCard(
          members: members,
          onInvite: _showAddMemberDialog,
        );
        final chatCard = _GuildChatCard(
          messages: messages,
          controller: _messageController,
          focusNode: _messageFocusNode,
          onSend: _sendMessage,
        );

        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            24,
            horizontalPadding,
            40,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1320),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PageIntro(
                  eyebrow: 'СООБЩЕСТВО',
                  title: 'Пространство гильдии',
                  description:
                      '$onlineCount участника сейчас онлайн. Здесь можно спросить, отметить маленькую победу или помочь с задачей.',
                  action: FilledButton.tonalIcon(
                    onPressed: _showAddMemberDialog,
                    icon: const Icon(Icons.person_add_alt_1_rounded),
                    label: const Text('Пригласить'),
                  ),
                ),
                const SizedBox(height: 26),
                _GuildHero(members: members.length, online: onlineCount),
                const SizedBox(height: 20),
                if (wide)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 9, child: membersCard),
                      const SizedBox(width: 20),
                      Expanded(flex: 11, child: chatCard),
                    ],
                  )
                else ...[
                  membersCard,
                  const SizedBox(height: 20),
                  chatCard,
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

/// A ranking view that makes contribution visible without turning it into a
/// hostile competition.
class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = PrizmaScope.watch(context);
    final players = <_LeaderboardEntry>[
      _LeaderboardEntry(
        name: store.user.name,
        avatar: store.user.avatar,
        score: store.user.utilityScore,
        isCurrentUser: true,
      ),
      ...store.guild.map(
        (member) => _LeaderboardEntry(
          name: member.name,
          avatar: member.avatar,
          score: member.score,
        ),
      ),
    ]..sort((left, right) => right.score.compareTo(left.score));
    final podium = players.take(3).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontalPadding = constraints.maxWidth >= 900 ? 32.0 : 20.0;
        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            24,
            horizontalPadding,
            40,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1140),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PageIntro(
                  eyebrow: 'СООБЩЕСТВО',
                  title: 'Рейтинг сообщества',
                  description:
                      'Не соревнование ради места — способ заметить, сколько поддержки уже создано.',
                  action: FilledButton.tonalIcon(
                    onPressed: () => Navigator.of(context).pushNamed('/guild'),
                    icon: const Icon(Icons.groups_rounded),
                    label: const Text('В гильдию'),
                  ),
                ),
                const SizedBox(height: 26),
                _LeaderboardHero(podium: podium),
                const SizedBox(height: 20),
                _LeaderboardTable(players: players),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PageIntro extends StatelessWidget {
  const _PageIntro({
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.action,
  });

  final String eyebrow;
  final String title;
  final String description;
  final Widget action;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.end,
      spacing: 22,
      runSpacing: 16,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Eyebrow(eyebrow),
              const SizedBox(height: 7),
              Text(
                title,
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: textTheme.bodyLarge?.copyWith(
                  color: pageMuted(context),
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
        action,
      ],
    );
  }
}

class _GuildHero extends StatelessWidget {
  const _GuildHero({required this.members, required this.online});

  final int members;
  final int online;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7157E9), Color(0xFF3E9EBD)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x2E7259E8),
            blurRadius: 26,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 670;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PRIZMA GUILD · 07',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Colors.white.withValues(alpha: .78),
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Каждый приносит сюда свою сильную сторону.',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            height: 1.08,
                          ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Здесь нет гонки. Есть вопросы, поддержка и общий ритм, который держит, когда одному трудно.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: .86),
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 22),
                    Wrap(
                      spacing: 20,
                      runSpacing: 12,
                      children: [
                        _GuildMetric(value: '$online', label: 'сейчас онлайн'),
                        _GuildMetric(value: '$members', label: 'участников'),
                        const _GuildMetric(
                          value: '82%',
                          label: 'ответов за день',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (!compact) ...[
                const SizedBox(width: 24),
                const _PrismIllustration(),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _GuildMetric extends StatelessWidget {
  const _GuildMetric({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        value,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 21,
          fontWeight: FontWeight.w800,
        ),
      ),
      const SizedBox(height: 2),
      Text(
        label,
        style: TextStyle(
          color: Colors.white.withValues(alpha: .73),
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}

class _PrismIllustration extends StatelessWidget {
  const _PrismIllustration();

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 144,
    height: 144,
    child: Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          top: 8,
          right: 10,
          child: _bubble(size: 48, color: const Color(0x55FFFFFF)),
        ),
        Positioned(
          bottom: 9,
          left: 5,
          child: _bubble(size: 30, color: const Color(0x33FFFFFF)),
        ),
        Transform.rotate(
          angle: .78,
          child: Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .19),
              border: Border.all(
                color: Colors.white.withValues(alpha: .45),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        ),
        const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 42),
      ],
    ),
  );

  Widget _bubble({required double size, required Color color}) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}

class _MembersCard extends StatelessWidget {
  const _MembersCard({required this.members, required this.onInvite});

  final List<GuildMember> members;
  final VoidCallback onInvite;

  @override
  Widget build(BuildContext context) {
    return PrizmaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeading(
            eyebrow: 'Участники',
            title: 'Те, кто рядом',
            trailing: TextButton.icon(
              onPressed: onInvite,
              icon: const Icon(Icons.add_rounded, size: 17),
              label: const Text('Добавить'),
            ),
          ),
          const SizedBox(height: 18),
          if (members.isEmpty)
            const _EmptyCommunityCard(
              icon: Icons.groups_outlined,
              title: 'Гильдия пока ждёт',
              message: 'Пригласи первого участника, чтобы начать вместе.',
            )
          else
            for (var index = 0; index < members.length; index++) ...[
              _MemberRow(member: members[index]),
              if (index != members.length - 1) const Divider(height: 18),
            ],
        ],
      ),
    );
  }
}

class _MemberRow extends StatelessWidget {
  const _MemberRow({required this.member});

  final GuildMember member;

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(member.status);
    return Row(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            UserAvatar(
              initials: member.avatar,
              background: _avatarColor(member.name),
              size: 43,
            ),
            Positioned(
              right: -1,
              bottom: -1,
              child: Container(
                width: 13,
                height: 13,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: pageSurface(context), width: 2),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                member.name,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _statusText(member.status),
                style: TextStyle(color: pageMuted(context), fontSize: 10),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Icon(Icons.bolt_rounded, color: PrizmaColors.orange, size: 15),
        const SizedBox(width: 2),
        Text(
          '${member.score}',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}

class _GuildChatCard extends StatelessWidget {
  const _GuildChatCard({
    required this.messages,
    required this.controller,
    required this.focusNode,
    required this.onSend,
  });

  final List<ChatMessage> messages;
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return PrizmaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: SectionHeading(
                  eyebrow: 'Общий чат',
                  title: 'Разговор в гильдии',
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: PrizmaColors.greenSoft,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _LiveDot(),
                    SizedBox(width: 5),
                    Text(
                      'LIVE',
                      style: TextStyle(
                        color: PrizmaColors.green,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: .7,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 17),
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 235, maxHeight: 370),
            child: messages.isEmpty
                ? const _EmptyCommunityCard(
                    icon: Icons.chat_bubble_outline_rounded,
                    title: 'Начни разговор',
                    message: 'Первое сообщение обычно самое короткое.',
                  )
                : ListView.separated(
                    reverse: true,
                    itemCount: messages.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) => _ChatMessage(
                      message: messages[messages.length - 1 - index],
                    ),
                  ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  maxLength: 200,
                  minLines: 1,
                  maxLines: 3,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => onSend(),
                  decoration: const InputDecoration(
                    counterText: '',
                    hintText: 'Напиши гильдии…',
                    prefixIcon: Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 19,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: onSend,
                tooltip: 'Отправить сообщение',
                icon: const Icon(Icons.send_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LiveDot extends StatelessWidget {
  const _LiveDot();

  @override
  Widget build(BuildContext context) => Container(
    width: 6,
    height: 6,
    decoration: const BoxDecoration(
      color: PrizmaColors.green,
      shape: BoxShape.circle,
    ),
  );
}

class _ChatMessage extends StatelessWidget {
  const _ChatMessage({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      UserAvatar(
        initials: initialsFor(message.from),
        size: 30,
        background: _avatarColor(message.from),
      ),
      const SizedBox(width: 9),
      Expanded(
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 9, 12, 10),
          decoration: BoxDecoration(
            color: pageSubtleSurface(context),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(13),
              bottomLeft: Radius.circular(13),
              bottomRight: Radius.circular(13),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      message.from,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Text(
                    relativeTime(message.time),
                    style: TextStyle(color: pageMuted(context), fontSize: 9),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                message.text,
                style: const TextStyle(fontSize: 12, height: 1.35),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

class _EmptyCommunityCard extends StatelessWidget {
  const _EmptyCommunityCard({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 35, horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 30, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: pageMuted(context), fontSize: 11),
          ),
        ],
      ),
    ),
  );
}

class _LeaderboardHero extends StatelessWidget {
  const _LeaderboardHero({required this.podium});

  final List<_LeaderboardEntry> podium;

  @override
  Widget build(BuildContext context) {
    final ordered = <_LeaderboardEntry?>[
      podium.length > 1 ? podium[1] : null,
      podium.isNotEmpty ? podium[0] : null,
      podium.length > 2 ? podium[2] : null,
    ];
    return PrizmaCard(
      padding: const EdgeInsets.fromLTRB(24, 22, 24, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Eyebrow('Топ недели'),
                  SizedBox(height: 5),
                  Text(
                    'Те, кто помогли больше всего',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: PrizmaColors.violetSoft,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 13,
                      color: PrizmaColors.violetDeep,
                    ),
                    SizedBox(width: 5),
                    Text(
                      'Эта неделя',
                      style: TextStyle(
                        color: PrizmaColors.violetDeep,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 500;
              return Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var index = 0; index < ordered.length; index++)
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: index == 1 || compact ? 0 : 24,
                        ),
                        child: _PodiumPlace(
                          entry: ordered[index],
                          place: index == 0
                              ? 2
                              : index == 1
                              ? 1
                              : 3,
                          compact: compact,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PodiumPlace extends StatelessWidget {
  const _PodiumPlace({
    required this.entry,
    required this.place,
    required this.compact,
  });

  final _LeaderboardEntry? entry;
  final int place;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final color = switch (place) {
      1 => const Color(0xFFD6991A),
      2 => const Color(0xFF757D91),
      _ => const Color(0xFFCD7A44),
    };
    if (entry == null) {
      return const SizedBox(height: 125);
    }
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            UserAvatar(
              initials: entry!.avatar,
              background: color,
              size: compact ? 48 : 60,
            ),
            Positioned(
              top: -8,
              left: -7,
              child: Container(
                width: 23,
                height: 23,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: Text(
                  '$place',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 9),
        Text(
          entry!.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: compact ? 10 : 12,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 3),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bolt_rounded,
              color: PrizmaColors.orange,
              size: compact ? 13 : 15,
            ),
            const SizedBox(width: 2),
            Text(
              '${entry!.score}',
              style: TextStyle(
                fontSize: compact ? 10 : 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          height: place == 1
              ? 68
              : place == 2
              ? 47
              : 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: .14),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            border: Border(
              top: BorderSide(color: color.withValues(alpha: .35)),
            ),
          ),
        ),
      ],
    );
  }
}

class _LeaderboardTable extends StatelessWidget {
  const _LeaderboardTable({required this.players});

  final List<_LeaderboardEntry> players;

  @override
  Widget build(BuildContext context) {
    return PrizmaCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(22, 20, 22, 14),
            child: Row(
              children: [
                Expanded(
                  child: SectionHeading(
                    eyebrow: 'Все участники',
                    title: 'Ритм помощи',
                  ),
                ),
                Text(
                  'локально',
                  style: TextStyle(color: PrizmaColors.inkSoft, fontSize: 10),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          for (var index = 0; index < players.length; index++) ...[
            _LeaderboardRow(entry: players[index], place: index + 1),
            if (index != players.length - 1)
              const Divider(height: 1, indent: 20, endIndent: 20),
          ],
        ],
      ),
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  const _LeaderboardRow({required this.entry, required this.place});

  final _LeaderboardEntry entry;
  final int place;

  @override
  Widget build(BuildContext context) {
    final rank = PrizmaConfig.rankForScore(entry.score);
    final medalColor = switch (place) {
      1 => const Color(0xFFD6991A),
      2 => const Color(0xFF757D91),
      3 => const Color(0xFFCD7A44),
      _ => pageMuted(context),
    };
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: place <= 3
                ? Icon(
                    Icons.workspace_premium_rounded,
                    color: medalColor,
                    size: 22,
                  )
                : Text(
                    '$place',
                    style: TextStyle(
                      color: pageMuted(context),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
          ),
          const SizedBox(width: 5),
          UserAvatar(
            initials: entry.avatar,
            background: _avatarColor(entry.name),
            size: 36,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        entry.name,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    if (entry.isCurrentUser) ...[
                      const SizedBox(width: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: PrizmaColors.violetSoft,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: const Text(
                          'ты',
                          style: TextStyle(
                            color: PrizmaColors.violetDeep,
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  rank.name,
                  style: TextStyle(color: pageMuted(context), fontSize: 10),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.bolt_rounded, color: PrizmaColors.orange, size: 17),
          Text(
            '${entry.score}',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _LeaderboardEntry {
  const _LeaderboardEntry({
    required this.name,
    required this.avatar,
    required this.score,
    this.isCurrentUser = false,
  });

  final String name;
  final String avatar;
  final int score;
  final bool isCurrentUser;
}

int _statusOrder(String status) => switch (status) {
  'online' => 0,
  'away' => 1,
  _ => 2,
};

String _statusText(String status) => switch (status) {
  'online' => 'В сети · готов помочь',
  'away' => 'Отошёл ненадолго',
  _ => 'Не в сети',
};

Color _statusColor(String status) => switch (status) {
  'online' => PrizmaColors.green,
  'away' => PrizmaColors.orange,
  _ => PrizmaColors.inkSoft,
};

Color _avatarColor(String name) {
  const colors = <Color>[
    PrizmaColors.violet,
    Color(0xFF2478C8),
    Color(0xFF1C9A76),
    Color(0xFFD67738),
    Color(0xFFBE5490),
  ];
  final hash = name.codeUnits.fold<int>(0, (result, char) => result + char);
  return colors[hash % colors.length];
}
