import 'package:flutter/material.dart';

import '../../app/prizma_theme.dart';

class PrizmaLogo extends StatelessWidget {
  const PrizmaLogo({super.key, this.compact = false, this.onTap});

  final bool compact;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: compact ? 34 : 38,
          height: compact ? 34 : 38,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: const LinearGradient(
              colors: [Color(0xFF947CFF), PrizmaColors.violetDeep],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x337551FF),
                blurRadius: 16,
                offset: Offset(0, 7),
              ),
            ],
          ),
          child: const Icon(
            Icons.hexagon_outlined,
            color: Colors.white,
            size: 21,
          ),
        ),
        if (!compact) ...[
          const SizedBox(width: 9),
          const Text(
            'prizma',
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.w800,
              letterSpacing: -1.6,
            ),
          ),
        ],
      ],
    );
    if (onTap == null) return content;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(13),
      child: content,
    );
  }
}

class PrizmaCard extends StatelessWidget {
  const PrizmaCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.onTap,
    this.color,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color ?? pageSurface(context),
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            border: Border.all(color: pageLine(context)),
            borderRadius: BorderRadius.circular(18),
          ),
          child: child,
        ),
      ),
    );
  }
}

class SectionHeading extends StatelessWidget {
  const SectionHeading({
    super.key,
    required this.eyebrow,
    required this.title,
    this.description,
    this.trailing,
  });

  final String eyebrow;
  final String title;
  final String? description;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Eyebrow(eyebrow),
              const SizedBox(height: 6),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              if (description != null) ...[
                const SizedBox(height: 5),
                Text(
                  description!,
                  style: TextStyle(
                    fontSize: 12,
                    color: pageMuted(context),
                    height: 1.45,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 12), trailing!],
      ],
    );
  }
}

class Eyebrow extends StatelessWidget {
  const Eyebrow(this.text, {super.key, this.color});

  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) => Text(
    text.toUpperCase(),
    style: TextStyle(
      color: color ?? Theme.of(context).colorScheme.primary,
      fontSize: 10,
      fontWeight: FontWeight.w800,
      letterSpacing: 1.2,
    ),
  );
}

class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.label,
    required this.value,
    this.caption,
    this.trend,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String label;
  final String value;
  final String? caption;
  final String? trend;

  @override
  Widget build(BuildContext context) {
    return PrizmaCard(
      padding: const EdgeInsets.all(17),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const Spacer(),
              if (trend != null)
                Text(
                  trend!,
                  style: const TextStyle(
                    color: PrizmaColors.green,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 13),
          Text(
            label,
            style: TextStyle(
              color: pageMuted(context),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          if (caption != null) ...[
            const SizedBox(height: 8),
            Text(
              caption!,
              style: TextStyle(color: pageMuted(context), fontSize: 10),
            ),
          ],
        ],
      ),
    );
  }
}

class SubjectChip extends StatelessWidget {
  const SubjectChip(this.subject, {super.key, this.compact = false});

  final String subject;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final data = subjectInfo(subject);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 7 : 8,
        vertical: compact ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: data.background,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        compact ? data.icon : '${data.icon} ${data.label}',
        style: TextStyle(
          color: data.color,
          fontSize: compact ? 9 : 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    required this.initials,
    this.size = 40,
    this.background,
    this.imageUrl,
  });

  final String initials;
  final double size;
  final Color? background;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final showImage =
        imageUrl != null && RegExp(r'^https?://').hasMatch(imageUrl!);
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background ?? PrizmaColors.violet,
        shape: BoxShape.circle,
        gradient: showImage
            ? null
            : LinearGradient(
                colors: [
                  background ?? const Color(0xFFAA98FF),
                  PrizmaColors.violet,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
      ),
      clipBehavior: Clip.antiAlias,
      child: showImage
          ? Image.network(
              imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _initials(),
            )
          : _initials(),
    );
  }

  Widget _initials() => Text(
    initials.isEmpty ? 'P' : initials,
    style: TextStyle(
      color: Colors.white,
      fontSize: size * .33,
      fontWeight: FontWeight.w800,
    ),
  );
}

class ProgressLine extends StatelessWidget {
  const ProgressLine({
    super.key,
    required this.value,
    this.color = PrizmaColors.violet,
    this.height = 7,
  });

  final double value;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(99),
    child: LinearProgressIndicator(
      value: value.clamp(0, 1).toDouble(),
      minHeight: height,
      color: color,
      backgroundColor: pageSubtleSurface(context),
    ),
  );
}

class EmptyPrizmaState extends StatelessWidget {
  const EmptyPrizmaState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) => PrizmaCard(
    padding: const EdgeInsets.all(28),
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: PrizmaColors.violetSoft,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: PrizmaColors.violet),
          ),
          const SizedBox(height: 13),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 5),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: pageMuted(context), fontSize: 12),
          ),
          if (action != null) ...[const SizedBox(height: 16), action!],
        ],
      ),
    ),
  );
}

class SubjectInfo {
  const SubjectInfo(this.label, this.icon, this.color, this.background);

  final String label;
  final String icon;
  final Color color;
  final Color background;
}

SubjectInfo subjectInfo(String id) {
  return switch (id) {
    'math' => const SubjectInfo(
      'Математика',
      '∑',
      PrizmaColors.violetDeep,
      PrizmaColors.violetSoft,
    ),
    'physics' => const SubjectInfo(
      'Физика',
      '⚛',
      Color(0xFF3779E6),
      Color(0xFFEAF3FF),
    ),
    'biology' => const SubjectInfo(
      'Биология',
      '🧬',
      Color(0xFF078C68),
      PrizmaColors.greenSoft,
    ),
    'chemistry' => const SubjectInfo(
      'Химия',
      '⚗',
      Color(0xFFD97629),
      PrizmaColors.orangeSoft,
    ),
    'history' => const SubjectInfo(
      'История',
      '📜',
      Color(0xFFD556A0),
      PrizmaColors.pinkSoft,
    ),
    'english' => const SubjectInfo(
      'Английский',
      '🌐',
      Color(0xFF159DAD),
      PrizmaColors.cyanSoft,
    ),
    _ => const SubjectInfo(
      'Предмет',
      '✦',
      PrizmaColors.inkSoft,
      PrizmaColors.surfaceMuted,
    ),
  };
}

String initialsFor(String value) {
  final chunks = value
      .split(RegExp(r'[\s_-]+'))
      .where((part) => part.isNotEmpty)
      .toList();
  final initials = chunks.take(2).map((part) => part[0]).join().toUpperCase();
  return initials.isEmpty ? 'P' : initials;
}

String relativeTime(DateTime time) {
  final difference = DateTime.now().difference(time);
  if (difference.inSeconds < 60) return 'только что';
  if (difference.inMinutes < 60) return '${difference.inMinutes} мин назад';
  if (difference.inHours < 24) return '${difference.inHours} ч назад';
  return '${difference.inDays} д назад';
}
