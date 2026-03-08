import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../services/api_service.dart';
import 'admin_shared.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});
  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with WidgetsBindingObserver {
  final _api = ApiService();
  Map<String, dynamic>? _data;
  bool _loading = true;

  // ── LOGIC: unchanged ────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final d = await _api.getAdminDashboard();
      print('📊 Admin Dashboard Data: $d');
      setState(() {
        _data = d;
        _loading = false;
      });
    } catch (e) {
      print('❌ Admin Dashboard Error: $e');
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to load dashboard: $e'),
              backgroundColor: kRed),
        );
      }
    }
  }

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: kWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Logout', style: TextStyle(color: kDarkText, fontSize: 17, fontWeight: FontWeight.w700)),
        content: const Text('Are you sure you want to logout?', style: TextStyle(color: kGray)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: kGray),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/login');
            },
            style: TextButton.styleFrom(foregroundColor: kRed),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  // ── BUILD ────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return AdminPage(
      title: 'Admin Dashboard',
      subtitle: 'System overview',
      icon: Icons.dashboard_rounded,
      headerActions: [
        GhostBtn(icon: Icons.refresh_rounded, tooltip: 'Refresh', onTap: _load),
        const SizedBox(width: 8),
        GhostBtn(icon: Icons.logout_rounded, tooltip: 'Logout', onTap: () => _logout(context)),
      ],
      body: _loading
          ? const AdminLoading()
          : RefreshIndicator(
              color: kTeal,
              onRefresh: _load,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Section label ──────────────────────────
                    _sectionLabel('Overview', Icons.speed_rounded),
                    const SizedBox(height: 10),

                    // ── Row 1: 4 cards ─────────────────────────
                    Row(children: [
                      Expanded(
                          child: _CompactCard(
                        label: 'Total Mothers',
                        value: '${_data?['total_mothers'] ?? 0}',
                        icon: Icons.pregnant_woman_rounded,
                        color: kTeal,
                      )),
                      const SizedBox(width: 10),
                      Expanded(
                          child: _CompactCard(
                        label: 'High Risk',
                        value: '${_data?['high_risk'] ?? 0}',
                        icon: Icons.warning_amber_rounded,
                        color: kRed,
                      )),
                      const SizedBox(width: 10),
                      Expanded(
                          child: _CompactCard(
                        label: 'Medium Risk',
                        value: '${_data?['medium_risk'] ?? 0}',
                        icon: Icons.warning_rounded,
                        color: kOrange,
                      )),
                      const SizedBox(width: 10),
                      Expanded(
                          child: _CompactCard(
                        label: 'Low Risk',
                        value: '${_data?['low_risk'] ?? 0}',
                        icon: Icons.check_circle_rounded,
                        color: kGreen,
                      )),
                    ]),
                    const SizedBox(height: 10),

                    // ── Row 2: 4 cards ─────────────────────────
                    Row(children: [
                      Expanded(
                          child: _CompactCard(
                        label: 'Total Referrals',
                        value: '${_data?['total_referrals'] ?? 0}',
                        icon: Icons.local_hospital_outlined,
                        color: kTeal,
                      )),
                      const SizedBox(width: 10),
                      Expanded(
                          child: _CompactCard(
                        label: 'Pending',
                        value: '${_data?['pending_referrals'] ?? 0}',
                        icon: Icons.pending_actions_rounded,
                        color: kOrange,
                      )),
                      const SizedBox(width: 10),
                      Expanded(
                          child: _CompactCard(
                        label: 'Active CHWs',
                        value: '${_data?['active_chws'] ?? 0}',
                        icon: Icons.health_and_safety_rounded,
                        color: kGreen,
                      )),
                      const SizedBox(width: 10),
                      Expanded(
                          child: _CompactCard(
                        label: 'Hospitals',
                        value: '${_data?['active_hospitals'] ?? 0}',
                        icon: Icons.local_hospital_rounded,
                        color: kTealDark,
                      )),
                    ]),
                    const SizedBox(height: 24),

                    // ── Section label ──────────────────────────
                    _sectionLabel('Analytics', Icons.bar_chart_rounded),
                    const SizedBox(height: 10),

                    // ── Charts side by side (or stacked) ──────
                    LayoutBuilder(builder: (ctx, c) {
                      if (c.maxWidth > 580) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _riskPieChart()),
                            const SizedBox(width: 14),
                            Expanded(flex: 2, child: _geoBarChart()),
                          ],
                        );
                      }
                      return Column(children: [
                        _riskPieChart(),
                        const SizedBox(height: 14),
                        _geoBarChart(),
                      ]);
                    }),
                  ],
                ),
              ),
            ),
    );
  }

  // ── Section label helper ──────────────────────────────────────────
  Widget _sectionLabel(String label, IconData icon) => Row(children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
              color: kTealLight, borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 14, color: kTeal),
        ),
        const SizedBox(width: 8),
        Text(label,
            style: const TextStyle(
                color: kDarkText,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.1)),
        const SizedBox(width: 10),
        Expanded(child: Container(height: 1, color: kBorder)),
      ]);

  // ── RISK PIE CHART ────────────────────────────────────────────────
  // LOGIC: unchanged — same _data keys, same calculation
  Widget _riskPieChart() {
    final high = (_data?['high_risk'] ?? 0) as int;
    final medium = (_data?['medium_risk'] ?? 0) as int;
    final low = (_data?['low_risk'] ?? 0) as int;
    final total = high + medium + low;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: kBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 3))
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Row(children: [
          Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                  color: kTealLight, borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.donut_large_rounded,
                  color: kTeal, size: 17)),
          const SizedBox(width: 10),
          const Text('Risk Distribution',
              style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: kDarkText)),
        ]),
        const SizedBox(height: 16),

        // Donut chart — SAME CustomPaint painter, just better sized
        SizedBox(
          height: 160,
          child: CustomPaint(
            painter: _PieChartPainter(high: high, medium: medium, low: low),
            child: Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text('$total',
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: kDarkText,
                        letterSpacing: -0.5)),
                const Text('Total',
                    style: TextStyle(fontSize: 10, color: kGray)),
              ]),
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Legend items — SAME _legendItem logic
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: kBgPage, borderRadius: BorderRadius.circular(12)),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            _legendItem('High', high, total, kRed),
            _vDivider(),
            _legendItem('Mid', medium, total, kOrange),
            _vDivider(),
            _legendItem('Low', low, total, kGreen),
          ]),
        ),
      ]),
    );
  }

  Widget _vDivider() => Container(width: 1, height: 36, color: kBorder);

  // LOGIC: unchanged
  Widget _legendItem(String label, int count, int total, Color color) {
    final pct = total > 0 ? (count / total * 100).toStringAsFixed(0) : '0';
    return Column(children: [
      Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 5),
        Text(label,
            style: const TextStyle(
                fontSize: 11, color: kGray, fontWeight: FontWeight.w600)),
      ]),
      const SizedBox(height: 4),
      Text('$count',
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.w800, color: color)),
      Text('$pct%', style: const TextStyle(fontSize: 10, color: kGray)),
    ]);
  }

  // ── GEO BAR CHART ─────────────────────────────────────────────────
  // LOGIC: unchanged — same _data['locations'], same keys
  Widget _geoBarChart() {
    final locs = (_data?['locations'] ?? []) as List;
    if (locs.isEmpty) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: kBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 3))
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Row(children: [
          Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                  color: kTealLight, borderRadius: BorderRadius.circular(10)),
              child:
                  const Icon(Icons.bar_chart_rounded, color: kTeal, size: 17)),
          const SizedBox(width: 10),
          const Expanded(
            child: Text('Geographic Distribution — High Risk Cases',
                style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: kDarkText)),
          ),
        ]),
        const SizedBox(height: 6),
        const Text('High risk cases by location in Kimironko Sector',
            style: TextStyle(fontSize: 11, color: kGray)),
        const SizedBox(height: 16),

        // Bar chart — SAME CustomPaint painter, better sized + labelled
        SizedBox(
          height: 200,
          child: CustomPaint(
            painter: _BarChartPainter(locations: locs),
            size: Size.infinite,
          ),
        ),
        const SizedBox(height: 8),

        // Location name labels
        Row(
            children: locs.map((l) {
          final name = (l['location'] ?? '').toString();
          final short = name.length > 6 ? name.substring(0, 6) : name;
          return Expanded(
              child: Text(short,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 9.5,
                      color: kGray,
                      fontWeight: FontWeight.w500)));
        }).toList()),

        const SizedBox(height: 12),

        // Location summary pills
        Wrap(
            spacing: 8,
            runSpacing: 8,
            children: locs.map((l) {
              final name = (l['location'] ?? 'N/A').toString();
              final high = (l['high_risk'] as int? ?? 0);
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: high > 0 ? kRed.withOpacity(0.08) : kBgPage,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: high > 0 ? kRed.withOpacity(0.25) : kBorder,
                      width: 1),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                          color: high > 0 ? kRed : kGray,
                          shape: BoxShape.circle)),
                  const SizedBox(width: 5),
                  Text('$name: $high',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: high > 0 ? kRed : kGray)),
                ]),
              );
            }).toList()),
      ]),
    );
  }
}

// ── COMPACT STAT CARD (4-column strip) ───────────────────────────────────────
class _CompactCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _CompactCard(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.18), width: 1.2),
        ),
        child: Column(children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 17),
          ),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: color,
                  letterSpacing: -0.3)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  fontSize: 9.5, color: kGray, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ]),
      );
}

// ── PIE CHART PAINTER ─────────────────────────────────────────────────────────
// LOGIC: 100% unchanged from original
class _PieChartPainter extends CustomPainter {
  final int high, medium, low;
  _PieChartPainter(
      {required this.high, required this.medium, required this.low});

  @override
  void paint(Canvas canvas, Size size) {
    final total = high + medium + low;
    if (total == 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius =
        size.width < size.height ? size.width / 2.5 : size.height / 2.5;
    double startAngle = -90 * math.pi / 180;

    // Gaps between slices for cleaner look
    const gap = 0.03;

    final highAngle = (high / total) * 2 * math.pi - gap;
    final mediumAngle = (medium / total) * 2 * math.pi - gap;
    final lowAngle = (low / total) * 2 * math.pi - gap;

    // High risk slice
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      highAngle,
      true,
      Paint()
        ..color = kRed
        ..style = PaintingStyle.fill,
    );
    startAngle += highAngle + gap;

    // Medium risk slice
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      mediumAngle,
      true,
      Paint()
        ..color = kOrange
        ..style = PaintingStyle.fill,
    );
    startAngle += mediumAngle + gap;

    // Low risk slice
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      lowAngle,
      true,
      Paint()
        ..color = kGreen
        ..style = PaintingStyle.fill,
    );

    // Donut hole — matches original white circle
    canvas.drawCircle(
      center,
      radius * 0.52,
      Paint()
        ..color = kWhite
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ── BAR CHART PAINTER ─────────────────────────────────────────────────────────
// LOGIC: 100% unchanged from original
class _BarChartPainter extends CustomPainter {
  final List locations;
  _BarChartPainter({required this.locations});

  @override
  void paint(Canvas canvas, Size size) {
    if (locations.isEmpty) return;

    final maxHigh = locations.fold<int>(
        0,
        (max, l) => (l['high_risk'] as int? ?? 0) > max
            ? (l['high_risk'] as int? ?? 0)
            : max);
    if (maxHigh == 0) return;

    const leftPad = 32.0;
    const bottomPad = 8.0;
    const topPad = 20.0;
    final chartW = size.width - leftPad - 10;
    final chartH = size.height - bottomPad - topPad;
    final barW = chartW / locations.length;

    // Horizontal grid lines
    final gridPaint = Paint()
      ..color = kBorder
      ..strokeWidth = 1;
    for (var g = 0; g <= 4; g++) {
      final y = topPad + chartH - (g / 4) * chartH;
      canvas.drawLine(
          Offset(leftPad, y), Offset(size.width - 10, y), gridPaint);

      // Y-axis labels
      final val = (maxHigh * g / 4).round();
      final tp = TextPainter(
        text: TextSpan(
            text: '$val',
            style: const TextStyle(
                color: kGray, fontSize: 9, fontWeight: FontWeight.w500)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(0, y - 6));
    }

    for (var i = 0; i < locations.length; i++) {
      final loc = locations[i];
      final high = (loc['high_risk'] as int? ?? 0);
      final barHeight = (high / maxHigh) * chartH;
      final x = leftPad + (i * barW) + (barW * 0.15);
      final y = topPad + chartH - barHeight;
      final bw = barW * 0.70;

      // Bar gradient effect — two rects, slightly different opacity
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(x, y, bw, barHeight),
          topLeft: const Radius.circular(6),
          topRight: const Radius.circular(6),
        ),
        Paint()
          ..color = kRed.withOpacity(0.15)
          ..style = PaintingStyle.fill,
      );
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(x + bw * 0.1, y, bw * 0.8, barHeight),
          topLeft: const Radius.circular(6),
          topRight: const Radius.circular(6),
        ),
        Paint()
          ..color = kRed
          ..style = PaintingStyle.fill,
      );

      // Value on top of bar
      if (high > 0) {
        final tp = TextPainter(
          text: TextSpan(
              text: '$high',
              style: const TextStyle(
                  color: kDarkText, fontSize: 11, fontWeight: FontWeight.w700)),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(x + (bw - tp.width) / 2, y - 16));
      }
    }

    // Baseline
    canvas.drawLine(
      Offset(leftPad, topPad + chartH),
      Offset(size.width - 10, topPad + chartH),
      Paint()
        ..color = kBorder
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
