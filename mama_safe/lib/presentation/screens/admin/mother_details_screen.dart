import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../services/api_service.dart';
import 'admin_shared.dart';

class MotherDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> mother;
  const MotherDetailsScreen({super.key, required this.mother});

  @override
  State<MotherDetailsScreen> createState() => _MotherDetailsScreenState();
}

class _MotherDetailsScreenState extends State<MotherDetailsScreen>
    with SingleTickerProviderStateMixin {
  final _api = ApiService();
  Map<String, dynamic>? _fullData;
  List<dynamic> _healthRecords = [];
  bool _loading = true;
  late AnimationController _animController;

  // ── LOGIC: 100% unchanged ────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
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
      final motherId = widget.mother['id'];
      final data = await _api.getMother(motherId);
      final records = await _api.getHealthRecords(motherId);
      setState(() {
        _fullData = data;
        _healthRecords = records;
        _loading = false;
      });
      _animController.forward(from: 0);
    } catch (e) {
      print('Error loading mother details: $e');
      setState(() => _loading = false);
    }
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    try {
      final dt = DateTime.parse(date.toString());
      return DateFormat('MMM dd, yyyy').format(dt);
    } catch (_) {
      return date.toString();
    }
  }

  String _formatDateTime(dynamic date) {
    if (date == null) return 'N/A';
    try {
      final dt = DateTime.parse(date.toString());
      return DateFormat('MMM dd, yyyy hh:mm a').format(dt);
    } catch (_) {
      return date.toString();
    }
  }

  Color _riskColor(String risk) {
    if (risk.toLowerCase().contains('high')) return kRed;
    if (risk.toLowerCase().contains('medium') ||
        risk.toLowerCase().contains('mid')) return kOrange;
    return kGreen;
  }
  // ── END LOGIC ────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: kBgPage,
        appBar: AppBar(
          title: const Text('Mother Details'),
          backgroundColor: kTeal,
          foregroundColor: kWhite,
        ),
        body: const Center(child: CircularProgressIndicator(color: kTeal)),
      );
    }

    final data = _fullData ?? widget.mother;
    final name = data['name'] ?? 'N/A';
    final age = data['age']?.toString() ?? 'N/A';
    final phone = data['phone'] ?? 'N/A';
    final province = data['province'] ?? 'N/A';
    final district = data['district'] ?? 'N/A';
    final sector = data['sector'] ?? 'N/A';
    final cell = data['cell'] ?? 'N/A';
    final village = data['village'] ?? 'N/A';
    final pregnancyStart = _formatDate(data['pregnancy_start_date']);
    final dueDate = _formatDate(data['due_date']);
    final risk = data['current_risk_level'] ?? 'Unknown';
    final referrals = (data['referrals'] ?? []) as List;
    final rColor = _riskColor(risk);
    final ini = initials(name);

    return Scaffold(
      backgroundColor: kBgPage,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Fixed Hero Header ─────────────────────────────────
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            snap: false,
            floating: false,
            backgroundColor: kTeal,
            foregroundColor: kWhite,
            // Hide the default title — we draw everything in flexibleSpace
            title: null,
            centerTitle: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                onPressed: _load,
              ),
            ],
            flexibleSpace: LayoutBuilder(
              builder: (context, constraints) {
                // How collapsed are we? 0 = fully expanded, 1 = fully collapsed
                final minExtent =
                    kToolbarHeight + MediaQuery.of(context).padding.top;
                final maxExtent = 160.0 + MediaQuery.of(context).padding.top;
                final collapse = ((maxExtent - constraints.maxHeight) /
                        (maxExtent - minExtent))
                    .clamp(0.0, 1.0);
                final expanded = collapse < 0.5;

                return Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF155C4A), kTeal],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 60, 12),
                      child: expanded
                          // ── Expanded: avatar + name + phone + risk pill
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 58,
                                  height: 58,
                                  decoration: BoxDecoration(
                                    color: kWhite.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                        color: kWhite.withOpacity(0.3),
                                        width: 1.5),
                                  ),
                                  child: Center(
                                    child: Text(
                                      ini,
                                      style: const TextStyle(
                                          color: kWhite,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.5),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        name,
                                        style: const TextStyle(
                                            color: kWhite,
                                            fontSize: 19,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: -0.3),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 3),
                                      Row(children: [
                                        const Icon(Icons.phone_outlined,
                                            size: 11, color: Colors.white60),
                                        const SizedBox(width: 4),
                                        Text(phone,
                                            style: const TextStyle(
                                                color: Colors.white60,
                                                fontSize: 11.5,
                                                fontWeight: FontWeight.w500)),
                                      ]),
                                      const SizedBox(height: 8),
                                      _RiskPill(risk: risk, color: rColor),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          // ── Collapsed: just centered name
                          : Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 40),
                                child: Text(
                                  name,
                                  style: const TextStyle(
                                      color: kWhite,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                    ),
                  ),
                );
              },
            ),
          ),

          // ── Body ──────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Quick stats row
                _QuickStats(
                    age: age, dueDate: dueDate, pregnancyStart: pregnancyStart),
                const SizedBox(height: 20),

                // Personal Information
                _Section(
                  title: 'Personal Information',
                  icon: Icons.person_outline_rounded,
                  iconColor: kTeal,
                  child: Column(children: [
                    _DetailRow(
                        label: 'Full Name',
                        value: name,
                        icon: Icons.badge_outlined),
                    _DetailRow(
                        label: 'Age',
                        value: '$age years',
                        icon: Icons.cake_outlined),
                    _DetailRow(
                        label: 'Phone',
                        value: phone,
                        icon: Icons.phone_outlined,
                        isLast: true),
                  ]),
                ),
                const SizedBox(height: 14),

                // Location
                _Section(
                  title: 'Location',
                  icon: Icons.location_on_outlined,
                  iconColor: const Color(0xFF3B82F6),
                  child: Column(children: [
                    _LocationBreadcrumb(
                      province: province,
                      district: district,
                      sector: sector,
                      cell: cell,
                      village: village,
                    ),
                  ]),
                ),
                const SizedBox(height: 14),

                // Pregnancy Information
                _Section(
                  title: 'Pregnancy Information',
                  icon: Icons.pregnant_woman_rounded,
                  iconColor: kOrange,
                  child: Column(children: [
                    _DetailRow(
                        label: 'Pregnancy Start',
                        value: pregnancyStart,
                        icon: Icons.play_circle_outline_rounded),
                    _DetailRow(
                        label: 'Expected Due Date',
                        value: dueDate,
                        icon: Icons.event_rounded),
                    _RiskDetailRow(
                        label: 'Current Risk Level', risk: risk, color: rColor),
                  ]),
                ),
                const SizedBox(height: 14),

                // Health Assessments
                if (_healthRecords.isNotEmpty) ...[
                  _Section(
                    title: 'Health Assessments (${_healthRecords.length})',
                    icon: Icons.monitor_heart_outlined,
                    iconColor: kRed,
                    child: Column(
                      children: _healthRecords.asMap().entries.map((entry) {
                        final i = entry.key;
                        final record = entry.value;
                        final riskLevel = record['risk_level'] ?? 'Unknown';
                        final createdAt = _formatDateTime(record['created_at']);
                        final rC = _riskColor(riskLevel);
                        return _HealthRecordCard(
                          record: record,
                          riskLevel: riskLevel,
                          createdAt: createdAt,
                          rColor: rC,
                          isLast: i == _healthRecords.length - 1,
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                // Referrals
                if (referrals.isNotEmpty)
                  _Section(
                    title: 'Appointments & Referrals (${referrals.length})',
                    icon: Icons.calendar_today_outlined,
                    iconColor: kGreen,
                    child: Column(
                      children: referrals.asMap().entries.map((entry) {
                        final i = entry.key;
                        final ref = entry.value;
                        final hospital = ref['hospital'] ?? 'N/A';
                        final status = ref['status'] ?? 'N/A';
                        final apptDate = ref['appointment_date'] != null
                            ? _formatDate(ref['appointment_date'])
                            : 'Not scheduled';
                        final apptTime = ref['appointment_time'] ?? '';
                        final dept = ref['department'] ?? 'N/A';
                        final createdAt = _formatDateTime(ref['created_at']);
                        return _ReferralCard(
                          hospital: hospital,
                          status: status,
                          apptDate: apptDate,
                          apptTime: apptTime,
                          dept: dept,
                          createdAt: createdAt,
                          isLast: i == referrals.length - 1,
                        );
                      }).toList(),
                    ),
                  ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ── RISK PILL ─────────────────────────────────────────────────────────────────
class _RiskPill extends StatelessWidget {
  final String risk;
  final Color color;
  const _RiskPill({required this.risk, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kWhite.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: kWhite,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '$risk Risk',
            style: const TextStyle(
                color: kWhite,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3),
          ),
        ],
      ),
    );
  }
}

// ── QUICK STATS ───────────────────────────────────────────────────────────────
class _QuickStats extends StatelessWidget {
  final String age, dueDate, pregnancyStart;
  const _QuickStats(
      {required this.age, required this.dueDate, required this.pregnancyStart});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      _StatChip(
          icon: Icons.cake_outlined, label: 'Age', value: age, color: kTeal),
      const SizedBox(width: 10),
      _StatChip(
          icon: Icons.event_rounded,
          label: 'Due Date',
          value: dueDate,
          color: kOrange),
      const SizedBox(width: 10),
      _StatChip(
          icon: Icons.play_circle_outline,
          label: 'Started',
          value: pregnancyStart,
          color: const Color(0xFF3B82F6)),
    ]);
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color color;
  const _StatChip(
      {required this.icon,
      required this.label,
      required this.value,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: kWhite,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: kBorder, width: 1),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 6,
                offset: const Offset(0, 2))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 15, color: color),
            ),
            const SizedBox(height: 8),
            Text(label,
                style: const TextStyle(
                    color: kGray, fontSize: 10, fontWeight: FontWeight.w500)),
            const SizedBox(height: 2),
            Text(value,
                style: const TextStyle(
                    color: kDarkText,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

// ── SECTION CARD ──────────────────────────────────────────────────────────────
class _Section extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Widget child;

  const _Section({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorder, width: 1),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Row(children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 16, color: iconColor),
              ),
              const SizedBox(width: 10),
              Text(title,
                  style: const TextStyle(
                      color: kDarkText,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2)),
            ]),
          ),
          Divider(color: kBorder.withOpacity(0.7), height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: child,
          ),
        ],
      ),
    );
  }
}

// ── DETAIL ROW ────────────────────────────────────────────────────────────────
class _DetailRow extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final bool isLast;

  const _DetailRow({
    required this.label,
    required this.value,
    required this.icon,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 8 : 14),
      child: Row(children: [
        Icon(icon, size: 14, color: kGray.withOpacity(0.6)),
        const SizedBox(width: 8),
        SizedBox(
          width: 130,
          child: Text(label,
              style: TextStyle(
                  color: kGray.withOpacity(0.8),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500)),
        ),
        Expanded(
          child: Text(value,
              style: const TextStyle(
                  color: kDarkText, fontSize: 13, fontWeight: FontWeight.w600)),
        ),
      ]),
    );
  }
}

// ── RISK DETAIL ROW ───────────────────────────────────────────────────────────
class _RiskDetailRow extends StatelessWidget {
  final String label, risk;
  final Color color;

  const _RiskDetailRow(
      {required this.label, required this.risk, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        Icon(Icons.shield_outlined, size: 14, color: kGray.withOpacity(0.6)),
        const SizedBox(width: 8),
        SizedBox(
          width: 130,
          child: Text(label,
              style: TextStyle(
                  color: kGray.withOpacity(0.8),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500)),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: color.withOpacity(0.10),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.3), width: 1),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(risk,
                style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2)),
          ]),
        ),
      ]),
    );
  }
}

// ── LOCATION BREADCRUMB ───────────────────────────────────────────────────────
class _LocationBreadcrumb extends StatelessWidget {
  final String province, district, sector, cell, village;
  const _LocationBreadcrumb({
    required this.province,
    required this.district,
    required this.sector,
    required this.cell,
    required this.village,
  });

  @override
  Widget build(BuildContext context) {
    final parts = [province, district, sector, cell, village];
    final labels = ['Province', 'District', 'Sector', 'Cell', 'Village'];
    final icons = [
      Icons.public_rounded,
      Icons.location_city_rounded,
      Icons.map_outlined,
      Icons.grid_view_rounded,
      Icons.home_outlined,
    ];

    return Column(
      children: List.generate(parts.length, (i) {
        return Padding(
          padding: EdgeInsets.only(bottom: i == parts.length - 1 ? 8 : 14),
          child: Row(children: [
            Icon(icons[i], size: 14, color: kGray.withOpacity(0.6)),
            const SizedBox(width: 8),
            SizedBox(
              width: 130,
              child: Text(labels[i],
                  style: TextStyle(
                      color: kGray.withOpacity(0.8),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500)),
            ),
            Expanded(
              child: Text(parts[i],
                  style: const TextStyle(
                      color: kDarkText,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
            ),
          ]),
        );
      }),
    );
  }
}

// ── HEALTH RECORD CARD ────────────────────────────────────────────────────────
class _HealthRecordCard extends StatelessWidget {
  final Map<String, dynamic> record;
  final String riskLevel, createdAt;
  final Color rColor;
  final bool isLast;

  const _HealthRecordCard({
    required this.record,
    required this.riskLevel,
    required this.createdAt,
    required this.rColor,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 8 : 12),
      decoration: BoxDecoration(
        color: rColor.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: rColor.withOpacity(0.15), width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(children: [
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(width: 3, color: rColor),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(
                    child: Text('Assessment · $createdAt',
                        style: TextStyle(
                            fontSize: 11,
                            color: kGray.withOpacity(0.8),
                            fontWeight: FontWeight.w500)),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: rColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: rColor.withOpacity(0.25)),
                    ),
                    child: Text(riskLevel,
                        style: TextStyle(
                            color: rColor,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700)),
                  ),
                ]),
                const SizedBox(height: 10),
                // Vitals grid
                Row(children: [
                  _VitalBox(
                    label: 'Blood Pressure',
                    value: '${record['systolic_bp']}/${record['diastolic_bp']}',
                    unit: 'mmHg',
                    icon: Icons.favorite_border_rounded,
                    color: kRed,
                  ),
                  const SizedBox(width: 8),
                  _VitalBox(
                    label: 'Blood Sugar',
                    value: '${record['blood_sugar']}',
                    unit: 'mg/dL',
                    icon: Icons.water_drop_outlined,
                    color: kOrange,
                  ),
                ]),
                const SizedBox(height: 8),
                Row(children: [
                  _VitalBox(
                    label: 'Temperature',
                    value: '${record['body_temp']}',
                    unit: '°C',
                    icon: Icons.thermostat_outlined,
                    color: const Color(0xFF3B82F6),
                  ),
                  const SizedBox(width: 8),
                  _VitalBox(
                    label: 'Heart Rate',
                    value: '${record['heart_rate']}',
                    unit: 'bpm',
                    icon: Icons.monitor_heart_outlined,
                    color: kTeal,
                  ),
                ]),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

class _VitalBox extends StatelessWidget {
  final String label, value, unit;
  final IconData icon;
  final Color color;

  const _VitalBox({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: kWhite,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: kBorder, width: 1),
        ),
        child: Row(children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 14, color: color),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 9.5,
                        color: kGray,
                        fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 1),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(value,
                        style: const TextStyle(
                            fontSize: 13,
                            color: kDarkText,
                            fontWeight: FontWeight.w800)),
                    const SizedBox(width: 2),
                    Text(unit,
                        style: const TextStyle(fontSize: 9, color: kGray)),
                  ],
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

// ── REFERRAL CARD ─────────────────────────────────────────────────────────────
class _ReferralCard extends StatelessWidget {
  final String hospital, status, apptDate, apptTime, dept, createdAt;
  final bool isLast;

  const _ReferralCard({
    required this.hospital,
    required this.status,
    required this.apptDate,
    required this.apptTime,
    required this.dept,
    required this.createdAt,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final isScheduled = status.contains('Scheduled');
    final statusColor = isScheduled ? kGreen : kOrange;

    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 8 : 12),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorder, width: 1),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 1))
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(children: [
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(width: 3, color: kTeal),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: kTeal.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.local_hospital_outlined,
                        size: 16, color: kTeal),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(hospital,
                        style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: kDarkText),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: statusColor.withOpacity(0.25)),
                    ),
                    child: Text(status,
                        style: TextStyle(
                            color: statusColor,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700)),
                  ),
                ]),
                const SizedBox(height: 10),
                Divider(color: kBorder.withOpacity(0.6), height: 1),
                const SizedBox(height: 10),
                _ReferralDetail(
                    icon: Icons.medical_services_outlined,
                    label: 'Department',
                    value: dept),
                const SizedBox(height: 6),
                _ReferralDetail(
                    icon: Icons.event_rounded,
                    label: 'Appointment',
                    value: apptDate +
                        (apptTime.isNotEmpty ? ' at $apptTime' : '')),
                const SizedBox(height: 6),
                _ReferralDetail(
                    icon: Icons.access_time_outlined,
                    label: 'Referred on',
                    value: createdAt),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

class _ReferralDetail extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _ReferralDetail(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, size: 13, color: kGray.withOpacity(0.6)),
      const SizedBox(width: 8),
      SizedBox(
        width: 90,
        child: Text(label,
            style: TextStyle(
                fontSize: 11.5,
                color: kGray.withOpacity(0.8),
                fontWeight: FontWeight.w500)),
      ),
      Expanded(
        child: Text(value,
            style: const TextStyle(
                fontSize: 11.5, color: kDarkText, fontWeight: FontWeight.w600),
            maxLines: 2,
            overflow: TextOverflow.ellipsis),
      ),
    ]);
  }
}
