import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../services/api_service.dart';
import 'admin_shared.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});
  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  final _api = ApiService();
  bool _loading = true;
  String _period = 'Last 30 days';
  DateTime? _lastUpdated;

  Map<String, dynamic> _summary = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final d = _days(_period);
      final r = await Future.wait([
        _api.getAdminDashboard(days: d),
      ]);
      setState(() {
        _summary = r[0] as Map<String, dynamic>;
        _lastUpdated = DateTime.now();
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  int _days(String p) {
    switch (p) {
      case 'Last 7 days':
        return 7;
      case 'Last 6 months':
        return 180;
      case 'Last year':
        return 365;
      default:
        return 30;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminPage(
      title: 'Reports & Analytics',
      subtitle: 'System performance & insights',
      icon: Icons.bar_chart_rounded,
      headerActions: [
        GhostBtn(icon: Icons.refresh_rounded, tooltip: 'Refresh', onTap: _load),
        const SizedBox(width: 8),
        GhostBtn(
            icon: Icons.file_download_outlined,
            tooltip: 'Export All',
            onTap: _showExport),
      ],
      body: _loading
          ? const AdminLoading()
          : RefreshIndicator(
              color: kTeal,
              onRefresh: _load,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _periodRow(),
                      const SizedBox(height: 20),
                      _sectionLabel('System Summary', Icons.speed_rounded),
                      const SizedBox(height: 10),
                      _summaryGrid(),
                      const SizedBox(height: 24),
                      _sectionLabel('Risk Level Breakdown',
                          Icons.pie_chart_outline_rounded),
                      const SizedBox(height: 10),
                      _riskDonut(),
                      const SizedBox(height: 24),
                      _sectionLabel('Geographic — Kimironko Sector',
                          Icons.location_on_rounded),
                      const SizedBox(height: 10),
                      _geoStackedBar(),
                    ]),
              ),
            ),
    );
  }

  // ── Period row ────────────────────────────────────────────────────────────────
  Widget _periodRow() =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              'Last 7 days',
              'Last 30 days',
              'Last 6 months',
              'Last year'
            ].map((p) {
              final sel = _period == p;
              return GestureDetector(
                onTap: () {
                  setState(() => _period = p);
                  _load();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  margin: const EdgeInsets.only(right: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                  decoration: BoxDecoration(
                    color: sel ? kTeal : kWhite,
                    borderRadius: BorderRadius.circular(22),
                    border:
                        Border.all(color: sel ? kTeal : kBorder, width: 1.3),
                    boxShadow: sel
                        ? [
                            BoxShadow(
                                color: kTeal.withOpacity(0.22),
                                blurRadius: 6,
                                offset: const Offset(0, 2))
                          ]
                        : [],
                  ),
                  child: Text(p,
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: sel ? kWhite : kGray)),
                ),
              );
            }).toList(),
          ),
        ),
        if (_lastUpdated != null) ...[
          const SizedBox(height: 8),
          Row(children: [
            const Icon(Icons.access_time_rounded, size: 11, color: kGray),
            const SizedBox(width: 4),
            Text(
                'Updated ${DateFormat('MMM dd, yyyy • hh:mm a').format(_lastUpdated!)}',
                style: const TextStyle(fontSize: 11, color: kGray)),
          ]),
        ],
      ]);

  // ── Section label ─────────────────────────────────────────────────────────────
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
                color: kDarkText, fontSize: 13.5, fontWeight: FontWeight.w700)),
        const SizedBox(width: 10),
        Expanded(child: Container(height: 1, color: kBorder)),
      ]);

  // ── Summary grid ──────────────────────────────────────────────────────────────
  Widget _summaryGrid() {
    final items = [
      _Tile('Total Mothers', '${_summary['total_mothers'] ?? 0}',
          Icons.pregnant_woman_rounded, kTeal),
      _Tile('Total Referrals', '${_summary['total_referrals'] ?? 0}',
          Icons.share_outlined, kTealDark),
      _Tile('Pending', '${_summary['pending_referrals'] ?? 0}',
          Icons.hourglass_top_rounded, kOrange),
      _Tile('Active CHWs', '${_summary['active_chws'] ?? 0}',
          Icons.people_alt_rounded, kTealDark),
      _Tile('High Risk', '${_summary['high_risk'] ?? 0}',
          Icons.warning_amber_rounded, kRed),
      _Tile('Low Risk', '${_summary['low_risk'] ?? 0}',
          Icons.check_circle_outline, kGreen),
    ];
    return Column(children: [
      Row(children: [
        _StatCard(items[0]),
        const SizedBox(width: 10),
        _StatCard(items[1]),
        const SizedBox(width: 10),
        _StatCard(items[2])
      ]),
      const SizedBox(height: 10),
      Row(children: [
        _StatCard(items[3]),
        const SizedBox(width: 10),
        _StatCard(items[4]),
        const SizedBox(width: 10),
        _StatCard(items[5])
      ]),
    ]);
  }

  // ── Risk donut chart ──────────────────────────────────────────────────────────
  Widget _riskDonut() {
    final high = (_summary['high_risk'] ?? 0) as int;
    final medium = (_summary['medium_risk'] ?? 0) as int;
    final low = (_summary['low_risk'] ?? 0) as int;
    final total = high + medium + low;

    if (total == 0)
      return const AdminEmpty(
          message: 'No risk data available',
          icon: Icons.pie_chart_outline_rounded);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        // ── Donut ────────────────────────────────────────
        SizedBox(
          width: 150,
          height: 150,
          child: CustomPaint(
            painter: _DonutPainter(
              slices: [
                _Slice(high, kRed),
                _Slice(medium, kOrange),
                _Slice(low, kGreen),
              ],
              total: total,
            ),
            child: Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text('$total',
                  style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: kDarkText,
                      letterSpacing: -0.5)),
              const Text('Total',
                  style: TextStyle(
                      fontSize: 11, color: kGray, fontWeight: FontWeight.w500)),
            ])),
          ),
        ),
        const SizedBox(width: 24),

        // ── Legend ───────────────────────────────────────
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _DonutLegendRow(
                label: 'High Risk', count: high, total: total, color: kRed),
            const SizedBox(height: 14),
            _DonutLegendRow(
                label: 'Medium Risk',
                count: medium,
                total: total,
                color: kOrange),
            const SizedBox(height: 14),
            _DonutLegendRow(
                label: 'Low Risk', count: low, total: total, color: kGreen),
          ]),
        ),
      ]),
    );
  }

  // ── Geographic stacked bar chart ──────────────────────────────────────────────
  Widget _geoStackedBar() {
    final locs = (_summary['locations'] ?? []) as List<dynamic>;
    if (locs.isEmpty)
      return const AdminEmpty(
          message: 'No geographic data', icon: Icons.map_outlined);

    final maxTotal = locs.fold<int>(
        0, (m, l) => ((l['total'] ?? 0) as int) > m ? (l['total'] as int) : m);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ── Legend pills ────────────────────────────────
        Row(children: [
          _LegendPill('High Risk', kRed),
          const SizedBox(width: 8),
          _LegendPill('Medium Risk', kOrange),
          const SizedBox(width: 8),
          _LegendPill('Low Risk', kGreen),
        ]),
        const SizedBox(height: 20),

        // ── Bars ────────────────────────────────────────
        SizedBox(
          height: 180,
          child: CustomPaint(
            painter: _StackedBarPainter(locs: locs, maxTotal: maxTotal),
            size: Size.infinite,
          ),
        ),
      ]),
    );
  }

  // ── Export dialog ─────────────────────────────────────────────────────────────
  void _showExport() => showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: kWhite,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Export All Reports',
              style: TextStyle(
                  color: kDarkText, fontSize: 17, fontWeight: FontWeight.w700)),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            for (final f in ['CSV', 'Excel', 'PDF'])
              ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: kTealLight,
                        borderRadius: BorderRadius.circular(10)),
                    child: Icon(
                        f == 'CSV'
                            ? Icons.table_chart_rounded
                            : f == 'Excel'
                                ? Icons.description_rounded
                                : Icons.picture_as_pdf_rounded,
                        color: kTeal,
                        size: 20)),
                title: Text(f,
                    style: const TextStyle(
                        color: kDarkText,
                        fontSize: 14,
                        fontWeight: FontWeight.w500)),
                trailing: const Icon(Icons.chevron_right_rounded,
                    color: kGray, size: 20),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Exporting as $f…'),
                      backgroundColor: kTeal));
                },
              ),
          ]),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(foregroundColor: kGray),
                child: const Text('Cancel')),
          ],
        ),
      );
}

// ── DATA MODELS ───────────────────────────────────────────────────────────────
class _Tile {
  final String label, value;
  final IconData icon;
  final Color color;
  const _Tile(this.label, this.value, this.icon, this.color);
}

class _Slice {
  final int value;
  final Color color;
  const _Slice(this.value, this.color);
}

// ── STAT CARD ─────────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final _Tile t;
  const _StatCard(this.t);
  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          decoration: BoxDecoration(
            color: t.color.withOpacity(0.07),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: t.color.withOpacity(0.18), width: 1.2),
          ),
          child: Column(children: [
            Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                    color: t.color.withOpacity(0.13),
                    borderRadius: BorderRadius.circular(8)),
                child: Icon(t.icon, size: 14, color: t.color)),
            const SizedBox(height: 6),
            Text(t.value,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: t.color,
                    letterSpacing: -0.3)),
            const SizedBox(height: 1),
            Text(t.label,
                style: const TextStyle(fontSize: 9.5, color: kGray),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ]),
        ),
      );
}

// ── DONUT CHART PAINTER ───────────────────────────────────────────────────────
class _DonutPainter extends CustomPainter {
  final List<_Slice> slices;
  final int total;
  const _DonutPainter({required this.slices, required this.total});

  @override
  void paint(Canvas canvas, Size size) {
    if (total == 0) return;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = math.min(cx, cy) - 6;
    const strokeW = 22.0;
    const gapAngle = 0.04; // radians gap between slices

    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: r);
    double start = -math.pi / 2;

    for (final s in slices) {
      if (s.value == 0) continue;
      final sweep = (s.value / total) * 2 * math.pi - gapAngle;

      // Shadow arc
      final shadowPaint = Paint()
        ..color = s.color.withOpacity(0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeW + 4
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(rect, start + gapAngle / 2, sweep, false, shadowPaint);

      // Main arc
      final paint = Paint()
        ..color = s.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeW
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(rect, start + gapAngle / 2, sweep, false, paint);

      start += sweep + gapAngle;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter old) => old.total != total;
}

// ── DONUT LEGEND ROW ──────────────────────────────────────────────────────────
class _DonutLegendRow extends StatelessWidget {
  final String label;
  final int count, total;
  final Color color;
  const _DonutLegendRow(
      {required this.label,
      required this.count,
      required this.total,
      required this.color});

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? (count / total * 100) : 0.0;
    return Row(children: [
      Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(3))),
      const SizedBox(width: 8),
      Expanded(
          child: Text(label,
              style: const TextStyle(
                  fontSize: 12.5,
                  color: kDarkText,
                  fontWeight: FontWeight.w500))),
      Text('$count',
          style: TextStyle(
              fontSize: 15, fontWeight: FontWeight.w800, color: color)),
      const SizedBox(width: 6),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
            color: color.withOpacity(0.10),
            borderRadius: BorderRadius.circular(20)),
        child: Text('${pct.toStringAsFixed(0)}%',
            style: TextStyle(
                fontSize: 10.5, color: color, fontWeight: FontWeight.w700)),
      ),
    ]);
  }
}

// ── STACKED BAR CHART PAINTER ─────────────────────────────────────────────────
class _StackedBarPainter extends CustomPainter {
  final List<dynamic> locs;
  final int maxTotal;
  const _StackedBarPainter({required this.locs, required this.maxTotal});

  @override
  void paint(Canvas canvas, Size size) {
    if (locs.isEmpty || maxTotal == 0) return;

    const labelH = 28.0; // space at bottom for location labels
    const topPad = 20.0; // space at top for value labels
    final chartH = size.height - labelH - topPad;
    final barCount = locs.length;
    final totalW = size.width;
    final barW = (totalW / barCount) * 0.5;
    final gap = (totalW / barCount) * 0.5;

    // Grid lines
    final gridPaint = Paint()
      ..color = const Color(0xFFE5E7EB)
      ..strokeWidth = 1;
    for (int i = 0; i <= 4; i++) {
      final y = topPad + chartH - (chartH * i / 4);
      canvas.drawLine(Offset(0, y), Offset(totalW, y), gridPaint);
    }

    for (int i = 0; i < barCount; i++) {
      final loc = locs[i];
      final high = (loc['high_risk'] ?? 0) as int;
      final medium = (loc['medium_risk'] ?? 0) as int;
      final low = (loc['low_risk'] ?? 0) as int;
      final total = (loc['total'] ?? 0) as int;

      final x = gap / 2 + i * (barW + gap);
      final bottom = topPad + chartH;

      // Draw stacked segments bottom→top: low, medium, high
      double stackY = bottom;

      void drawSegment(int val, Color color) {
        if (val == 0) return;
        final h = (val / maxTotal) * chartH;
        final rect = RRect.fromRectAndRadius(
          Rect.fromLTWH(x, stackY - h, barW, h),
          const Radius.circular(4),
        );
        canvas.drawRRect(rect, Paint()..color = color);
        stackY -= h;
      }

      drawSegment(low, kGreen);
      drawSegment(medium, kOrange);
      drawSegment(high, kRed);

      // Total label above bar
      if (total > 0) {
        final topY = topPad + chartH - (total / maxTotal) * chartH;
        final tp = TextPainter(
          text: TextSpan(
              text: '$total',
              style: const TextStyle(
                  fontSize: 10, fontWeight: FontWeight.w700, color: kDarkText)),
          textDirection: ui.TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(x + barW / 2 - tp.width / 2, topY - 16));
      }

      // Location label below
      final name = (loc['location'] ?? 'N/A').toString();
      // Shorten long names
      final short = name.length > 8 ? '${name.substring(0, 7)}…' : name;
      final lp = TextPainter(
        text: TextSpan(
            text: short,
            style: const TextStyle(
                fontSize: 9.5, color: kGray, fontWeight: FontWeight.w500)),
        textDirection: ui.TextDirection.ltr,
      )..layout();
      lp.paint(canvas, Offset(x + barW / 2 - lp.width / 2, bottom + 6));
    }
  }

  @override
  bool shouldRepaint(_StackedBarPainter old) => old.locs != locs;
}

// ── LEGEND PILL ───────────────────────────────────────────────────────────────
class _LegendPill extends StatelessWidget {
  final String label;
  final Color color;
  const _LegendPill(this.label, this.color);
  @override
  Widget build(BuildContext context) =>
      Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 5),
        Text(label,
            style: const TextStyle(
                fontSize: 11, color: kGray, fontWeight: FontWeight.w500)),
      ]);
}

// ── CHW HELPERS ───────────────────────────────────────────────────────────────
class _CHWHead extends StatelessWidget {
  final String text;
  const _CHWHead(this.text);
  @override
  Widget build(BuildContext context) => SizedBox(
      width: 52,
      child: Text(text,
          textAlign: TextAlign.center,
          style: const TextStyle(
              fontSize: 11, fontWeight: FontWeight.w700, color: kTeal)));
}

class _CHWVal extends StatelessWidget {
  final String text;
  final Color color;
  final bool bold;
  const _CHWVal(this.text, this.color, {this.bold = false});
  @override
  Widget build(BuildContext context) => SizedBox(
      width: 52,
      child: Text(text,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500)));
}

// ── RANK BADGE ────────────────────────────────────────────────────────────────
class _RankBadge extends StatelessWidget {
  final int rank;
  const _RankBadge(this.rank);
  @override
  Widget build(BuildContext context) {
    if (rank == 1) return const Text('🥇', style: TextStyle(fontSize: 16));
    if (rank == 2) return const Text('🥈', style: TextStyle(fontSize: 16));
    if (rank == 3) return const Text('🥉', style: TextStyle(fontSize: 16));
    return Text('$rank',
        style: const TextStyle(
            fontSize: 12, color: kGray, fontWeight: FontWeight.w600));
  }
}
