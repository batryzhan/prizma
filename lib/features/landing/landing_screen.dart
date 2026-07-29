import 'package:flutter/material.dart';

/// The public entry point for Prizma's marketing experience.
///
/// It deliberately contains no application state: the page is safe to show
/// before a learner has completed onboarding and is useful as a web landing
/// page as well as the first mobile route.
class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  static const _canvas = Color(0xFFF7F8FD);
  static const _ink = Color(0xFF1B2559);
  static const _muted = Color(0xFF6A7193);
  static const _violet = Color(0xFF7551FF);
  static const _deepViolet = Color(0xFF4F2FE3);
  static const _line = Color(0xFFE8EAF4);

  void _openDashboard(BuildContext context) {
    Navigator.of(context).pushReplacementNamed('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _canvas,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _PageWidth(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 14, 0, 0),
                  child: _SiteHeader(onStart: () => _openDashboard(context)),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: _PageWidth(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 42, 0, 0),
                  child: _Hero(onStart: () => _openDashboard(context)),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 72)),
            const SliverToBoxAdapter(child: _PageWidth(child: _TrustStrip())),
            const SliverToBoxAdapter(child: SizedBox(height: 108)),
            const SliverToBoxAdapter(
              child: _PageWidth(child: _FeaturesSection()),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 108)),
            SliverToBoxAdapter(
              child: _PageWidth(
                child: _RhythmSection(onStart: () => _openDashboard(context)),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 108)),
            SliverToBoxAdapter(
              child: _PageWidth(
                child: _CallToAction(onStart: () => _openDashboard(context)),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 30)),
            const SliverToBoxAdapter(child: _PageWidth(child: _Footer())),
            const SliverToBoxAdapter(child: SizedBox(height: 28)),
          ],
        ),
      ),
    );
  }
}

class _PageWidth extends StatelessWidget {
  const _PageWidth({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: child,
        ),
      ),
    );
  }
}

class _SiteHeader extends StatelessWidget {
  const _SiteHeader({required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // The full navigation needs roughly 800 logical pixels once the
        // brand and action button are accounted for. Collapse it before the
        // row becomes cramped on tablets and narrow browser windows.
        final compact = constraints.maxWidth < 820;
        return Row(
          children: [
            const _BrandLockup(),
            const Spacer(),
            if (!compact) ...[
              _HeaderLink(label: 'Возможности', onTap: () {}),
              const SizedBox(width: 8),
              _HeaderLink(label: 'Сообщество', onTap: () {}),
              const SizedBox(width: 20),
            ],
            OutlinedButton(
              onPressed: onStart,
              style: OutlinedButton.styleFrom(
                foregroundColor: LandingScreen._ink,
                side: const BorderSide(color: LandingScreen._line),
                padding: EdgeInsets.symmetric(
                  horizontal: compact ? 15 : 18,
                  vertical: 13,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(compact ? 'Войти' : 'Открыть Prizma'),
            ),
          ],
        );
      },
    );
  }
}

class _BrandLockup extends StatelessWidget {
  const _BrandLockup();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _PrismMark(size: 34),
        SizedBox(width: 10),
        Text(
          'prizma',
          style: TextStyle(
            color: LandingScreen._ink,
            fontSize: 23,
            fontWeight: FontWeight.w800,
            letterSpacing: -1.1,
          ),
        ),
      ],
    );
  }
}

class _HeaderLink extends StatelessWidget {
  const _HeaderLink({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: LandingScreen._muted,
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
      ),
      child: Text(label),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 880;
        final copy = _HeroCopy(onStart: onStart, dense: !wide);

        return Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            gradient: const LinearGradient(
              colors: [Color(0xFFF0EDFF), Color(0xFFF9F9FF), Color(0xFFEFFBFC)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: const Color(0xFFE7E4FF)),
          ),
          child: Stack(
            children: [
              const Positioned(
                top: -154,
                right: -80,
                child: _GlowOrb(size: 330, color: Color(0x527551FF)),
              ),
              const Positioned(
                bottom: -160,
                left: 25,
                child: _GlowOrb(size: 280, color: Color(0x403CC7D5)),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  wide ? 58 : 26,
                  wide ? 64 : 42,
                  wide ? 38 : 26,
                  wide ? 52 : 34,
                ),
                child: wide
                    ? Row(
                        children: [
                          Expanded(flex: 11, child: copy),
                          const SizedBox(width: 34),
                          const Expanded(
                            flex: 12,
                            child: _HeroVisualFrame(child: _DashboardWindow()),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          copy,
                          const SizedBox(height: 38),
                          const _HeroVisualFrame(child: _DashboardWindow()),
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}

class _HeroCopy extends StatelessWidget {
  const _HeroCopy({required this.onStart, required this.dense});

  final VoidCallback onStart;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final titleSize = dense ? 42.0 : 55.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _Eyebrow(
          icon: Icons.auto_awesome_rounded,
          label: 'Учебное пространство, которое держит ритм',
        ),
        const SizedBox(height: 22),
        Text(
          'Учись яснее.\nРасти вместе.',
          style: TextStyle(
            color: LandingScreen._ink,
            fontSize: titleSize,
            height: .99,
            letterSpacing: -2.4,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Prizma превращает учёбу в спокойный общий ритм: ставь маленькие цели, проси помощь и замечай свой рост.',
          style: TextStyle(
            color: LandingScreen._muted,
            fontSize: 16,
            height: 1.55,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 28),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            FilledButton.icon(
              onPressed: onStart,
              icon: const Icon(Icons.arrow_forward_rounded, size: 19),
              label: const Text('Начать учиться'),
              style: FilledButton.styleFrom(
                backgroundColor: LandingScreen._violet,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            OutlinedButton.icon(
              onPressed: onStart,
              icon: const Icon(Icons.play_circle_outline_rounded, size: 20),
              label: const Text('Посмотреть пространство'),
              style: OutlinedButton.styleFrom(
                foregroundColor: LandingScreen._ink,
                side: const BorderSide(color: Color(0xFFD9DDEE)),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 16,
                ),
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        const Wrap(
          spacing: 16,
          runSpacing: 10,
          children: [
            _SmallProof(
              icon: Icons.check_circle_rounded,
              label: 'Без лишнего давления',
            ),
            _SmallProof(icon: Icons.groups_rounded, label: 'Поддержка гильдии'),
          ],
        ),
      ],
    );
  }
}

class _SmallProof extends StatelessWidget {
  const _SmallProof({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 17, color: LandingScreen._violet),
        const SizedBox(width: 7),
        Text(
          label,
          style: const TextStyle(
            color: LandingScreen._muted,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _HeroVisualFrame extends StatelessWidget {
  const _HeroVisualFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        const Positioned(
          top: -17,
          right: -9,
          child: _FloatingTag(
            icon: Icons.bolt_rounded,
            label: '+20 энергии',
            tone: Color(0xFFFFB547),
          ),
        ),
        const Positioned(
          left: -13,
          bottom: -15,
          child: _FloatingTag(
            icon: Icons.favorite_rounded,
            label: 'SOS решён',
            tone: Color(0xFFFF7A9A),
          ),
        ),
      ],
    );
  }
}

class _FloatingTag extends StatelessWidget {
  const _FloatingTag({
    required this.icon,
    required this.label,
    required this.tone,
  });

  final IconData icon;
  final String label;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x180A1035),
            blurRadius: 20,
            offset: Offset(0, 9),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: tone, size: 16),
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(
                color: LandingScreen._ink,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardWindow extends StatelessWidget {
  const _DashboardWindow();

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 480;
    return AspectRatio(
      // A compact phone needs vertical room for the readable dashboard
      // preview; the desktop-like ratio compresses its chart and level card.
      aspectRatio: compact ? .85 : 1.2,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFDDE1F2)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1F363B76),
              blurRadius: 35,
              offset: Offset(0, 20),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(21),
          child: Column(
            children: [
              Container(
                height: 33,
                color: const Color(0xFFFBFBFE),
                padding: const EdgeInsets.symmetric(horizontal: 13),
                child: Row(
                  children: [
                    _Dot(color: const Color(0xFFFF8A95)),
                    const SizedBox(width: 5),
                    _Dot(color: const Color(0xFFFFC85C)),
                    const SizedBox(width: 5),
                    _Dot(color: const Color(0xFF61D4A4)),
                    const Spacer(),
                    const _MiniPrizm(),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 51,
                      color: const Color(0xFFFBFBFE),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      child: const Column(
                        children: [
                          _PreviewNav(
                            icon: Icons.grid_view_rounded,
                            selected: true,
                          ),
                          SizedBox(height: 13),
                          _PreviewNav(icon: Icons.bolt_outlined),
                          SizedBox(height: 13),
                          _PreviewNav(icon: Icons.menu_book_outlined),
                          SizedBox(height: 13),
                          _PreviewNav(icon: Icons.people_outline_rounded),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Твой учебный ритм',
                              style: TextStyle(
                                color: LandingScreen._ink,
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                                letterSpacing: -.4,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              width: 100,
                              height: 6,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE9EBF6),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            const SizedBox(height: 15),
                            const Expanded(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(flex: 13, child: _PreviewChart()),
                                  SizedBox(width: 10),
                                  Expanded(flex: 8, child: _PreviewLevel()),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Row(
                              children: [
                                Expanded(child: _PreviewTask()),
                                SizedBox(width: 10),
                                Expanded(child: _PreviewRequest()),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _MiniPrizm extends StatelessWidget {
  const _MiniPrizm();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 17,
      height: 17,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C5CFF), Color(0xFF41CAD8)],
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Icon(
        Icons.change_history_rounded,
        size: 12,
        color: Colors.white,
      ),
    );
  }
}

class _PreviewNav extends StatelessWidget {
  const _PreviewNav({required this.icon, this.selected = false});

  final IconData icon;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 26,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFECE8FF) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        icon,
        size: 14,
        color: selected ? LandingScreen._violet : const Color(0xFFA6ACCA),
      ),
    );
  }
}

class _PreviewChart extends StatelessWidget {
  const _PreviewChart();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFFBFBFE),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '12 ч 40 мин',
              style: TextStyle(
                fontSize: 10,
                color: LandingScreen._ink,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 3),
            const Text(
              'эта неделя',
              style: TextStyle(
                fontSize: 6.5,
                color: LandingScreen._muted,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            SizedBox(
              height: 42,
              child: CustomPaint(
                painter: _MiniChartPainter(),
                child: const SizedBox.expand(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final guide = Paint()
      ..color = const Color(0xFFE9EBF5)
      ..strokeWidth = 1;
    for (var point = 1; point < 4; point++) {
      final y = size.height * point / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), guide);
    }
    final area = Path()
      ..moveTo(0, size.height * .76)
      ..cubicTo(
        size.width * .16,
        size.height * .51,
        size.width * .22,
        size.height * .92,
        size.width * .39,
        size.height * .57,
      )
      ..cubicTo(
        size.width * .54,
        size.height * .23,
        size.width * .62,
        size.height * .73,
        size.width * .77,
        size.height * .28,
      )
      ..cubicTo(
        size.width * .87,
        size.height * .04,
        size.width * .93,
        size.height * .15,
        size.width,
        size.height * .09,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(area, Paint()..color = const Color(0x247551FF));
    final line = Path()
      ..moveTo(0, size.height * .76)
      ..cubicTo(
        size.width * .16,
        size.height * .51,
        size.width * .22,
        size.height * .92,
        size.width * .39,
        size.height * .57,
      )
      ..cubicTo(
        size.width * .54,
        size.height * .23,
        size.width * .62,
        size.height * .73,
        size.width * .77,
        size.height * .28,
      )
      ..cubicTo(
        size.width * .87,
        size.height * .04,
        size.width * .93,
        size.height * .15,
        size.width,
        size.height * .09,
      );
    canvas.drawPath(
      line,
      Paint()
        ..color = LandingScreen._violet
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 2.2,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PreviewLevel extends StatelessWidget {
  const _PreviewLevel();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F7FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(9),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'LVL 4',
              style: TextStyle(
                fontSize: 7,
                color: LandingScreen._violet,
                fontWeight: FontWeight.w800,
              ),
            ),
            const Spacer(),
            Center(
              child: SizedBox(
                width: 45,
                height: 45,
                child: CircularProgressIndicator(
                  value: .72,
                  strokeWidth: 5,
                  backgroundColor: const Color(0xFFE6E0FF),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    LandingScreen._violet,
                  ),
                ),
              ),
            ),
            const Spacer(),
            const Center(
              child: Text(
                'Знаток',
                style: TextStyle(
                  fontSize: 8,
                  color: LandingScreen._ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewTask extends StatelessWidget {
  const _PreviewTask();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        border: Border.all(color: const Color(0xFFEEF0F7)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Padding(
        padding: EdgeInsets.all(8),
        child: Row(
          children: [
            Icon(
              Icons.check_circle_rounded,
              size: 13,
              color: Color(0xFF4BCB8C),
            ),
            SizedBox(width: 5),
            Expanded(
              child: Text(
                'План на сегодня',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: LandingScreen._ink,
                  fontSize: 7,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewRequest extends StatelessWidget {
  const _PreviewRequest();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        border: Border.all(color: const Color(0xFFEEF0F7)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Padding(
        padding: EdgeInsets.all(8),
        child: Row(
          children: [
            Icon(Icons.favorite_rounded, size: 13, color: Color(0xFFFF7A9A)),
            SizedBox(width: 5),
            Expanded(
              child: Text(
                'Помощь рядом',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: LandingScreen._ink,
                  fontSize: 7,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrustStrip extends StatelessWidget {
  const _TrustStrip();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final vertical = constraints.maxWidth < 620;
        final stats = const [
          _TrustStat(value: '7 дней', label: 'спокойного учебного ритма'),
          _TrustStat(value: '82%', label: 'запросов находят отклик'),
          _TrustStat(value: '1 место', label: 'для целей, знаний и людей'),
        ];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: LandingScreen._line),
          ),
          child: vertical
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _withSeparators(
                    stats,
                    const Divider(height: 25, color: LandingScreen._line),
                  ),
                )
              : Row(
                  children: [
                    const Icon(
                      Icons.auto_graph_rounded,
                      color: LandingScreen._violet,
                      size: 31,
                    ),
                    const SizedBox(width: 18),
                    ..._withSeparators(
                      stats.map((item) => Expanded(child: item)).toList(),
                      const SizedBox(width: 22),
                    ),
                  ],
                ),
        );
      },
    );
  }
}

List<Widget> _withSeparators(Iterable<Widget> items, Widget separator) {
  final result = <Widget>[];
  var first = true;
  for (final item in items) {
    if (!first) result.add(separator);
    result.add(item);
    first = false;
  }
  return result;
}

class _TrustStat extends StatelessWidget {
  const _TrustStat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: LandingScreen._ink,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: -.5,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(
            color: LandingScreen._muted,
            fontSize: 12,
            height: 1.3,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _FeaturesSection extends StatelessWidget {
  const _FeaturesSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionIntro(
          kicker: 'Одна призма — много точек роста',
          title: 'Не просто список задач.\nТвоё место для понимания.',
          description:
              'Prizma помогает не потерять нить: замечать движение, делиться сложным и возвращаться к главному без чувства гонки.',
        ),
        const SizedBox(height: 38),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 850
                ? 3
                : constraints.maxWidth >= 530
                ? 2
                : 1;
            final cards = const [
              _FeatureCard(
                icon: Icons.bolt_rounded,
                accent: Color(0xFFFFB547),
                tint: Color(0xFFFFF7E6),
                eyebrow: 'Фокус',
                title: 'Маленькие шаги\nстановятся ритмом',
                body:
                    'Собирай день из понятных задач и отмечай то, что уже получилось.',
                visual: _TaskIllustration(),
              ),
              _FeatureCard(
                icon: Icons.favorite_rounded,
                accent: Color(0xFFFF7396),
                tint: Color(0xFFFFF1F5),
                eyebrow: 'Поддержка',
                title: 'Вопрос — это\nначало диалога',
                body:
                    'Отправь SOS, добавь контекст — и гильдия увидит, где может помочь.',
                visual: _SosIllustration(),
              ),
              _FeatureCard(
                icon: Icons.auto_awesome_rounded,
                accent: LandingScreen._violet,
                tint: Color(0xFFF1EFFF),
                eyebrow: 'Рост',
                title: 'Видно путь,\nа не только финиш',
                body:
                    'Уровни и utility score делают вклад в себя и других заметным.',
                visual: _GrowthIllustration(),
              ),
            ];
            return GridView.count(
              crossAxisCount: columns,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              // The illustration is a complete mini-interface, not a
              // decorative thumbnail. Fixed responsive heights keep its
              // controls readable instead of compressing them on wide grids.
              mainAxisExtent: columns == 1 ? 580 : 560,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: cards,
            );
          },
        ),
      ],
    );
  }
}

class _SectionIntro extends StatelessWidget {
  const _SectionIntro({
    required this.kicker,
    required this.title,
    required this.description,
  });

  final String kicker;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = constraints.maxWidth < 750;
        final titleBlock = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Eyebrow(icon: Icons.auto_awesome_rounded, label: kicker),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(
                color: LandingScreen._ink,
                fontSize: 34,
                height: 1.05,
                letterSpacing: -1.4,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        );
        final descriptionBlock = Text(
          description,
          style: const TextStyle(
            color: LandingScreen._muted,
            fontSize: 15,
            height: 1.55,
            fontWeight: FontWeight.w500,
          ),
        );
        if (stacked) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              titleBlock,
              const SizedBox(height: 18),
              descriptionBlock,
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(flex: 11, child: titleBlock),
            const SizedBox(width: 54),
            Expanded(flex: 8, child: descriptionBlock),
          ],
        );
      },
    );
  }
}

class _Eyebrow extends StatelessWidget {
  const _Eyebrow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: LandingScreen._violet),
        const SizedBox(width: 7),
        Flexible(
          child: Text(
            label.toUpperCase(),
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: LandingScreen._violet,
              fontSize: 11,
              letterSpacing: 1.05,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.accent,
    required this.tint,
    required this.eyebrow,
    required this.title,
    required this.body,
    required this.visual,
  });

  final IconData icon;
  final Color accent;
  final Color tint;
  final String eyebrow;
  final String title;
  final String body;
  final Widget visual;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(23),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: LandingScreen._line),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: tint,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: accent, size: 21),
          ),
          const SizedBox(height: 23),
          Text(
            eyebrow.toUpperCase(),
            style: TextStyle(
              color: accent,
              fontSize: 10,
              letterSpacing: 1.05,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            title,
            style: const TextStyle(
              color: LandingScreen._ink,
              fontSize: 21,
              height: 1.1,
              letterSpacing: -.7,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            body,
            style: const TextStyle(
              color: LandingScreen._muted,
              fontSize: 13,
              height: 1.45,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          const SizedBox(height: 18),
          Expanded(child: visual),
        ],
      ),
    );
  }
}

class _TaskIllustration extends StatelessWidget {
  const _TaskIllustration();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF2),
        borderRadius: BorderRadius.circular(17),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ПЛАН НА СЕГОДНЯ',
              style: TextStyle(
                color: Color(0xFFA9843E),
                fontSize: 8,
                letterSpacing: .8,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 11),
            const _IllustrationTask(done: true, label: 'Квадратные уравнения'),
            const SizedBox(height: 9),
            const _IllustrationTask(done: false, label: 'Законы отражения'),
            const SizedBox(height: 9),
            const _IllustrationTask(done: false, label: 'Present Perfect'),
          ],
        ),
      ),
    );
  }
}

class _IllustrationTask extends StatelessWidget {
  const _IllustrationTask({required this.done, required this.label});

  final bool done;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          done ? Icons.check_circle_rounded : Icons.circle_outlined,
          color: done ? const Color(0xFF4BCB8C) : const Color(0xFFCBD0E1),
          size: 16,
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: done ? const Color(0xFF858AA4) : LandingScreen._ink,
              fontSize: 10,
              decoration: done ? TextDecoration.lineThrough : null,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _SosIllustration extends StatelessWidget {
  const _SosIllustration();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF6F8),
        borderRadius: BorderRadius.circular(17),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                CircleAvatar(
                  radius: 11,
                  backgroundColor: Color(0xFFFFC4D3),
                  child: Text(
                    'M',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFB83765),
                    ),
                  ),
                ),
                SizedBox(width: 7),
                Text(
                  'Mira_X · только что',
                  style: TextStyle(
                    color: LandingScreen._muted,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 11),
            const Text(
              'Помогите с системой уравнений — как начать?',
              style: TextStyle(
                color: LandingScreen._ink,
                fontSize: 11,
                height: 1.3,
                fontWeight: FontWeight.w800,
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1EFFF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '∑ Математика',
                    style: TextStyle(
                      color: LandingScreen._violet,
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.bolt_rounded,
                  size: 15,
                  color: Color(0xFFFFB547),
                ),
                const SizedBox(width: 3),
                const Text(
                  '20',
                  style: TextStyle(
                    color: LandingScreen._ink,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GrowthIllustration extends StatelessWidget {
  const _GrowthIllustration();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF6F4FF),
        borderRadius: BorderRadius.circular(17),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'ТОЧКА РОСТА',
                style: TextStyle(
                  color: LandingScreen._violet,
                  fontSize: 8,
                  letterSpacing: .8,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: 72,
              height: 72,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const SizedBox(
                    width: 72,
                    height: 72,
                    child: CircularProgressIndicator(
                      value: .73,
                      strokeWidth: 7,
                      backgroundColor: Color(0xFFE4E0FF),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        LandingScreen._violet,
                      ),
                    ),
                  ),
                  const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '230',
                        style: TextStyle(
                          color: LandingScreen._ink,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'points',
                        style: TextStyle(
                          color: LandingScreen._muted,
                          fontSize: 7,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Знаток · LVL 4',
              style: TextStyle(
                color: LandingScreen._ink,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RhythmSection extends StatelessWidget {
  const _RhythmSection({required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = constraints.maxWidth < 820;
        final copy = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _Eyebrow(
              icon: Icons.people_alt_rounded,
              label: 'Гильдия, в которой можно быть собой',
            ),
            const SizedBox(height: 15),
            const Text(
              'Когда непонятно —\nты не один.',
              style: TextStyle(
                color: LandingScreen._ink,
                fontSize: 35,
                height: 1.05,
                letterSpacing: -1.5,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'В Prizma можно попросить объяснить тему, разделить маленькую победу или помочь другому закрепить своё знание.',
              style: TextStyle(
                color: LandingScreen._muted,
                fontSize: 15,
                height: 1.55,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 22),
            TextButton.icon(
              onPressed: onStart,
              icon: const Icon(Icons.arrow_forward_rounded, size: 18),
              label: const Text('Заглянуть в гильдию'),
              style: TextButton.styleFrom(
                foregroundColor: LandingScreen._violet,
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        );
        const visual = _GuildIllustration();
        return Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: LandingScreen._line),
            borderRadius: BorderRadius.circular(28),
          ),
          child: stacked
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [copy, const SizedBox(height: 32), visual],
                )
              : Row(
                  children: [
                    Expanded(flex: 10, child: copy),
                    const SizedBox(width: 56),
                    const Expanded(flex: 11, child: _GuildIllustration()),
                  ],
                ),
        );
      },
    );
  }
}

class _GuildIllustration extends StatelessWidget {
  const _GuildIllustration();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.28,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFF2F0FF), Color(0xFFEAF9FA)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Container(
                width: 160,
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x120C164A),
                      blurRadius: 16,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 10,
                          backgroundColor: Color(0xFFD8CEFF),
                          child: Text(
                            'M',
                            style: TextStyle(
                              fontSize: 9,
                              color: LandingScreen._violet,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Mira_X',
                          style: TextStyle(
                            color: LandingScreen._ink,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 7),
                    Text(
                      'Кто поможет с задачей?',
                      style: TextStyle(
                        color: LandingScreen._muted,
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: const Alignment(.65, -.1),
              child: Container(
                width: 148,
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: const Color(0xFF7551FF),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x207551FF),
                      blurRadius: 18,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 10,
                          backgroundColor: Color(0xFFFFFFFF),
                          child: Text(
                            'D',
                            style: TextStyle(
                              fontSize: 9,
                              color: LandingScreen._violet,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Dev_K',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 7),
                    Text(
                      'Да, давай разберём!',
                      style: TextStyle(
                        color: Color(0xFFE9E5FF),
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Container(
                width: 178,
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x120C164A),
                      blurRadius: 16,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.auto_awesome_rounded,
                      size: 16,
                      color: Color(0xFFFFB547),
                    ),
                    SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        'Ещё один понятный шаг',
                        style: TextStyle(
                          color: LandingScreen._ink,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Align(
              alignment: Alignment.bottomRight,
              child: _PrismMark(size: 65),
            ),
          ],
        ),
      ),
    );
  }
}

class _CallToAction extends StatelessWidget {
  const _CallToAction({required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 44),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            LandingScreen._deepViolet,
            LandingScreen._violet,
            Color(0xFF54C6D0),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Stack(
        children: [
          const Positioned(
            top: -80,
            right: -70,
            child: _GlowOrb(size: 230, color: Color(0x20FFFFFF)),
          ),
          const Positioned(
            bottom: -110,
            left: 15,
            child: _GlowOrb(size: 220, color: Color(0x16FFFFFF)),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              final stacked = constraints.maxWidth < 690;
              final text = const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Твоя учёба может\nбыть бережной.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 33,
                      height: 1.06,
                      letterSpacing: -1.25,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Начни с одного ясного шага — остальное сложится в ритм.',
                    style: TextStyle(
                      color: Color(0xFFECEAFF),
                      fontSize: 15,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
              final button = FilledButton.icon(
                onPressed: onStart,
                icon: const Icon(Icons.arrow_forward_rounded, size: 19),
                label: const Text('Открыть Prizma'),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: LandingScreen._deepViolet,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              );
              return stacked
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [text, const SizedBox(height: 24), button],
                    )
                  : Row(
                      children: [
                        const Expanded(child: SizedBox()),
                        Expanded(flex: 4, child: text),
                        const SizedBox(width: 30),
                        button,
                      ],
                    );
            },
          ),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const caption = Text(
            'Учись по-своему · вместе',
            style: TextStyle(
              color: LandingScreen._muted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          );
          return constraints.maxWidth < 390
              ? const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [_BrandLockup(), SizedBox(height: 13), caption],
                )
              : const Row(children: [_BrandLockup(), Spacer(), caption]);
        },
      ),
    );
  }
}

class _PrismMark extends StatelessWidget {
  const _PrismMark({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * .3),
        gradient: const LinearGradient(
          colors: [Color(0xFF7858FF), Color(0xFF4CCBD3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x357551FF),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Icon(
        Icons.change_history_rounded,
        color: Colors.white,
        size: size * .67,
      ),
    );
  }
}
