import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../services/api_service.dart';
import 'admin_shared.dart';
import 'mother_details_screen.dart';

class AdminMothersScreen extends StatefulWidget {
  const AdminMothersScreen({super.key});
  @override
  State<AdminMothersScreen> createState() => _AdminMothersScreenState();
}

class _AdminMothersScreenState extends State<AdminMothersScreen>
    with SingleTickerProviderStateMixin {
  final _api = ApiService();
  List<dynamic> _all = [];
  bool _loading = true;
  String _filter = 'All';
  String _search = '';
  late AnimationController _animController;

  static const _filters = ['All', 'High Risk', 'Medium Risk', 'Low Risk'];

  // ── LOGIC: 100% unchanged ────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _load();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await _api.getAllMothersAdmin();
      print('🔍 MOTHERS DATA RECEIVED: ${data.length} mothers');

      int highCount = 0, midCount = 0, lowCount = 0, unknownCount = 0;
      for (var m in data) {
        final risk = (m['current_risk_level'] ?? '').toString().toLowerCase();
        if (risk.contains('high')) {
          highCount++;
        } else if (risk.contains('mid') || risk.contains('medium')) {
          midCount++;
        } else if (risk.contains('low')) {
          lowCount++;
        } else {
          unknownCount++;
          print('⚠️ Unknown risk: ${m['name']} - "${m['current_risk_level']}"');
        }
      }

      print('📊 RISK BREAKDOWN:');
      print('   High: $highCount');
      print('   Mid: $midCount');
      print('   Low: $lowCount');
      print('   Unknown: $unknownCount');
      print('   Total: ${highCount + midCount + lowCount + unknownCount}');

      setState(() {
        _all = data;
        _loading = false;
      });
      _animController.forward(from: 0);
    } catch (e) {
      print('❌ ERROR LOADING MOTHERS: $e');
      setState(() => _loading = false);
    }
  }

  List<dynamic> get _filtered => _all.where((m) {
        final risk =
            (m['risk_level'] ?? m['riskLevel'] ?? m['current_risk_level'] ?? '')
                .toString()
                .toLowerCase();
        if (_filter == 'High Risk' && !risk.contains('high')) return false;
        if (_filter == 'Medium Risk' &&
            !risk.contains('medium') &&
            !risk.contains('mid')) return false;
        if (_filter == 'Low Risk' && !risk.contains('low')) return false;
        if (_search.isNotEmpty) {
          final q = _search.toLowerCase();
          return (m['name'] ?? '').toString().toLowerCase().contains(q) ||
              (m['phone'] ?? '').toString().toLowerCase().contains(q) ||
              (m['location'] ?? m['sector'] ?? '')
                  .toString()
                  .toLowerCase()
                  .contains(q);
        }
        return true;
      }).toList();

  int _cnt(String f) {
    if (f == 'All') return _all.length;
    final key = f.toLowerCase().replaceAll(' risk', '');
    final count = _all.where((m) {
      final risk =
          (m['risk_level'] ?? m['riskLevel'] ?? m['current_risk_level'] ?? '')
              .toString()
              .toLowerCase();
      return risk.contains(key) || (key == 'medium' && risk.contains('mid'));
    }).length;

    print('🔢 Filter "$f" count: $count');
    if (f != 'All') {
      _all.where((m) {
        final risk =
            (m['risk_level'] ?? m['riskLevel'] ?? m['current_risk_level'] ?? '')
                .toString()
                .toLowerCase();
        return risk.contains(key) || (key == 'medium' && risk.contains('mid'));
      }).forEach((m) {
        print('   - ${m['name']}: ${m['current_risk_level']}');
      });
    }

    return count;
  }

  String _fmt(String? raw) {
    if (raw == null) return 'N/A';
    try {
      return DateFormat('MMM dd, yyyy').format(DateTime.parse(raw));
    } catch (_) {
      return raw;
    }
  }
  // ── END LOGIC ────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return AdminPage(
      title: 'Mothers',
      subtitle: 'Registered pregnant mothers',
      icon: Icons.pregnant_woman_rounded,
      headerActions: [
        GhostBtn(icon: Icons.refresh_rounded, tooltip: 'Refresh', onTap: _load),
      ],
      body: _loading
          ? const AdminLoading()
          : RefreshIndicator(
              color: kTeal,
              onRefresh: _load,
              child: Column(children: [
                // ── Search ────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                  child: AdminSearchBar(
                    hint: 'Search mothers…',
                    onChanged: (v) => setState(() => _search = v),
                    query: _search,
                  ),
                ),

                // ── Filter chips ──────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: AdminFilterChips(
                    labels: _filters,
                    selected: _filter,
                    onChanged: (v) => setState(() => _filter = v),
                    counts: {for (final f in _filters) f: _cnt(f)},
                    dotColors: {
                      'High Risk': kRed,
                      'Medium Risk': kOrange,
                      'Low Risk': kGreen
                    },
                  ),
                ),

                const SizedBox(height: 8),
                Divider(color: kBorder.withOpacity(0.6), height: 1),

                // ── Count + clear filter row ──────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
                  child: Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: kTeal.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${filtered.length} mother${filtered.length == 1 ? '' : 's'}',
                        style: const TextStyle(
                            color: kTeal,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2),
                      ),
                    ),
                    const Spacer(),
                    if (_filter != 'All')
                      GestureDetector(
                        onTap: () => setState(() => _filter = 'All'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: kGray.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(children: [
                            Icon(Icons.close_rounded, size: 11, color: kGray),
                            SizedBox(width: 4),
                            Text('Clear filter',
                                style: TextStyle(
                                    color: kGray,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500)),
                          ]),
                        ),
                      ),
                  ]),
                ),

                const SizedBox(height: 4),

                // ── List ──────────────────────────────────────
                Expanded(
                  child: filtered.isEmpty
                      ? const AdminEmpty(
                          message: 'No mothers found',
                          icon: Icons.pregnant_woman_outlined)
                      : ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                          itemCount: filtered.length,
                          itemBuilder: (_, i) {
                            final m = filtered[i];
                            final name = m['name'] ?? 'Unknown';
                            final location = m['location'] ??
                                m['sector'] ??
                                m['cell'] ??
                                'N/A';
                            final risk = m['risk_level'] ??
                                m['riskLevel'] ??
                                m['current_risk_level'] ??
                                'Unknown';
                            final dueDate = _fmt(m['due_date']);
                            final chw = m['chw'];
                            final chwName = chw is Map
                                ? chw['name'] ?? 'N/A'
                                : (m['chw_name'] ?? m['chwName'] ?? 'N/A');
                            final rColor = riskColor(risk);
                            final ini = initials(name);

                            return FadeTransition(
                              opacity: CurvedAnimation(
                                parent: _animController,
                                curve: Interval(
                                  (i * 0.06).clamp(0.0, 0.8),
                                  ((i * 0.06) + 0.4).clamp(0.0, 1.0),
                                  curve: Curves.easeOut,
                                ),
                              ),
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0, 0.08),
                                  end: Offset.zero,
                                ).animate(CurvedAnimation(
                                  parent: _animController,
                                  curve: Interval(
                                    (i * 0.06).clamp(0.0, 0.8),
                                    ((i * 0.06) + 0.4).clamp(0.0, 1.0),
                                    curve: Curves.easeOut,
                                  ),
                                )),
                                child: GestureDetector(
                                  onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => MotherDetailsScreen(
                                              mother: Map<String, dynamic>.from(
                                                  m)))),
                                  child: _MotherCard(
                                    ini: ini,
                                    name: name,
                                    location: location,
                                    risk: risk,
                                    rColor: rColor,
                                    dueDate: dueDate,
                                    chwName: chwName,
                                    index: i,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ]),
            ),
    );
  }
}

// ── STATS SUMMARY BAR ─────────────────────────────────────────────────────────
class _StatsBar extends StatelessWidget {
  final int total, high, medium, low;
  const _StatsBar(
      {required this.total,
      required this.high,
      required this.medium,
      required this.low});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            _StatCell(
              value: '$total',
              label: 'Total',
              color: kTeal,
              icon: Icons.pregnant_woman_rounded,
              showDivider: true,
            ),
            _StatCell(
              value: '$high',
              label: 'High Risk',
              color: kRed,
              icon: Icons.warning_amber_rounded,
              showDivider: true,
            ),
            _StatCell(
              value: '$medium',
              label: 'Medium',
              color: kOrange,
              icon: Icons.info_outline_rounded,
              showDivider: true,
            ),
            _StatCell(
              value: '$low',
              label: 'Low Risk',
              color: kGreen,
              icon: Icons.check_circle_outline_rounded,
              showDivider: false,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final String value, label;
  final Color color;
  final IconData icon;
  final bool showDivider;

  const _StatCell({
    required this.value,
    required this.label,
    required this.color,
    required this.icon,
    required this.showDivider,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 16, color: color),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: color,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: const TextStyle(
                      fontSize: 10,
                      color: kGray,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.1),
                ),
              ],
            ),
          ),
          if (showDivider)
            Container(
              width: 1,
              height: 48,
              color: kBorder,
            ),
        ],
      ),
    );
  }
}

// ── MOTHER CARD ───────────────────────────────────────────────────────────────
class _MotherCard extends StatelessWidget {
  final String ini, name, location, risk, dueDate, chwName;
  final Color rColor;
  final int index;

  const _MotherCard({
    required this.ini,
    required this.name,
    required this.location,
    required this.risk,
    required this.rColor,
    required this.dueDate,
    required this.chwName,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Left accent bar
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 4,
                decoration: BoxDecoration(
                  color: rColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 14, 14),
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                // ── Avatar ────────────────────────────────────
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        rColor.withOpacity(0.15),
                        rColor.withOpacity(0.06),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border:
                        Border.all(color: rColor.withOpacity(0.2), width: 1),
                  ),
                  child: Center(
                      child: Text(ini,
                          style: TextStyle(
                              color: rColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5))),
                ),
                const SizedBox(width: 12),

                // ── Name / Location / Info ────────────────────
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name + badge
                        Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text(name,
                                    style: const TextStyle(
                                        color: kDarkText,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: -0.2),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                              ),
                              const SizedBox(width: 8),
                              _RiskBadge(
                                  label: '${riskLabel(risk)} Risk',
                                  color: rColor),
                            ]),
                        const SizedBox(height: 5),

                        // Location
                        Row(children: [
                          Icon(Icons.location_on_outlined,
                              size: 12, color: kGray.withOpacity(0.7)),
                          const SizedBox(width: 3),
                          Expanded(
                              child: Text(location,
                                  style: TextStyle(
                                      color: kGray.withOpacity(0.8),
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w500),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis)),
                        ]),
                        const SizedBox(height: 7),

                        // Info chips row
                        Row(children: [
                          _InfoChip(
                            icon: Icons.calendar_today_outlined,
                            label: dueDate,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _InfoChip(
                              icon: Icons.person_pin_outlined,
                              label: chwName,
                              expanded: true,
                            ),
                          ),
                        ]),
                      ]),
                ),

                // ── Chevron ───────────────────────────────────
                const SizedBox(width: 4),
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: kGray.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.chevron_right_rounded,
                      size: 18, color: kGray.withOpacity(0.5)),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

// ── RISK BADGE ────────────────────────────────────────────────────────────────
class _RiskBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _RiskBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.25), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

// ── INFO CHIP ─────────────────────────────────────────────────────────────────
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool expanded;
  const _InfoChip(
      {required this.icon, required this.label, this.expanded = false});

  @override
  Widget build(BuildContext context) {
    final content = Row(
      mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: kGray.withOpacity(0.6)),
        const SizedBox(width: 4),
        if (expanded)
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                  fontSize: 11,
                  color: kGray.withOpacity(0.8),
                  fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          )
        else
          Text(
            label,
            style: TextStyle(
                fontSize: 11,
                color: kGray.withOpacity(0.8),
                fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7F6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: kBorder, width: 1),
      ),
      child: content,
    );
  }
}

// ── SUMMARY TILE (kept for backward compat) ───────────────────────────────────
class _SummaryTile extends StatelessWidget {
  final String label, value;
  final Color color;
  final IconData icon;
  const _SummaryTile({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.07),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.18), width: 1.2),
          ),
          child: Column(children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(7)),
              child: Icon(icon, size: 13, color: color),
            ),
            const SizedBox(height: 5),
            Text(value,
                style: TextStyle(
                    fontSize: 17, fontWeight: FontWeight.w800, color: color)),
            Text(label, style: const TextStyle(fontSize: 9.5, color: kGray)),
          ]),
        ),
      );
}

// ── INFO PILL (kept for backward compat) ──────────────────────────────────────
class _Pill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _Pill({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) =>
      Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 11, color: color),
        const SizedBox(width: 3),
        Text(label,
            style: TextStyle(
                fontSize: 10.5, color: color, fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
      ]);
}
