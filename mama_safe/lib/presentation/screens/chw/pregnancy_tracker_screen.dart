import 'package:flutter/material.dart';
import '../../../models/mother_model.dart';
import '../../../models/health_record_model.dart';
import '../../../services/api_service.dart';
import '../../../core/app_colors.dart';

// ─────────────────────────────────────────────
//  DESIGN TOKENS
// ─────────────────────────────────────────────
const _teal = Color(0xFF1A7A6E);
const _tealLight = Color(0xFFE8F5F3);
const _navy = Color(0xFF1E2D4E);
const _white = Color(0xFFFFFFFF);
const _bgPage = Color(0xFFF4F7F6);
const _gray = Color(0xFF6B7280);
const _cardBorder = Color(0xFFE5E9E8);
const _divider = Color(0xFFF0F3F2);
const _red = Color(0xFFDC2626);
const _amber = Color(0xFFD97706);

class PregnancyTrackerScreen extends StatefulWidget {
  final MotherModel mother;

  const PregnancyTrackerScreen({Key? key, required this.mother})
      : super(key: key);

  @override
  State<PregnancyTrackerScreen> createState() => _PregnancyTrackerScreenState();
}

class _PregnancyTrackerScreenState extends State<PregnancyTrackerScreen> {
  List<HealthRecord> _healthRecords = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHealthRecords();
  }

  // ── Logic (UNCHANGED) ─────────────────────────────────────────────────────
  Future<void> _loadHealthRecords() async {
    try {
      final apiService = ApiService();
      final records =
          await apiService.getHealthRecords(int.parse(widget.mother.id));
      setState(() {
        _healthRecords = records.map((r) => HealthRecord.fromJson(r)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  int _getWeeksPregnant() {
    final now = DateTime.now();
    final start = widget.mother.createdAt;
    return now.difference(start).inDays ~/ 7;
  }

  String _getTrimester() {
    final weeks = _getWeeksPregnant();
    if (weeks <= 13) return '1st';
    if (weeks <= 26) return '2nd';
    return '3rd';
  }

  int _getDaysUntilDue() {
    final dueDate = widget.mother.createdAt.add(const Duration(days: 280));
    return dueDate.difference(DateTime.now()).inDays;
  }

  // ── Risk helpers ───────────────────────────────────────────────────────────
  Color _riskColor(String risk) {
    switch (risk) {
      case 'High':
        return _red;
      case 'Mid':
      case 'Medium':
        return _amber;
      default:
        return _teal;
    }
  }

  // ── BUILD ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgPage,
      appBar: AppBar(
        title: const Text(
          'Pregnancy Tracker',
          style: TextStyle(
              color: _white, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        backgroundColor: _teal,
        foregroundColor: _white,
        elevation: 0,
        iconTheme: const IconThemeData(color: _white),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: _teal),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPregnancyOverview(),
                  const SizedBox(height: 20),
                  _buildRiskHistory(),
                  const SizedBox(height: 20),
                  _buildVitalsTrends(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  // ── Pregnancy Overview ─────────────────────────────────────────────────────
  Widget _buildPregnancyOverview() {
    final weeks = _getWeeksPregnant();
    final trimester = _getTrimester();
    final daysToDue = _getDaysUntilDue();
    final totalDays = 280;
    final elapsed = totalDays - daysToDue.clamp(0, totalDays);
    final progress = (elapsed / totalDays).clamp(0.0, 1.0);

    return _Card(
      title: 'Pregnancy Overview',
      icon: Icons.pregnant_woman_outlined,
      child: Column(
        children: [
          // Three stat tiles
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  icon: Icons.calendar_today_outlined,
                  value: '$weeks',
                  label: 'Weeks',
                  iconBg: _navy,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatTile(
                  icon: Icons.pregnant_woman_outlined,
                  value: trimester,
                  label: 'Trimester',
                  iconBg: _teal,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatTile(
                  icon: Icons.timer_outlined,
                  value: '$daysToDue',
                  label: 'Days to Due',
                  iconBg: daysToDue <= 14 ? _red : _amber,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Progress bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Pregnancy Progress',
                    style: TextStyle(
                        color: _gray,
                        fontSize: 12,
                        fontWeight: FontWeight.w500),
                  ),
                  Text(
                    '${(progress * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(
                        color: _navy,
                        fontSize: 12,
                        fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: _cardBorder,
                  valueColor: const AlwaysStoppedAnimation(_teal),
                  minHeight: 8,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Risk History ───────────────────────────────────────────────────────────
  Widget _buildRiskHistory() {
    return _Card(
      title: 'Risk History',
      icon: Icons.history_outlined,
      child: _healthRecords.isEmpty
          ? _EmptyData(label: 'No health records yet')
          : Column(
              children: [
                for (int i = 0; i < _healthRecords.take(5).length; i++) ...[
                  _buildRiskItem(_healthRecords[i]),
                  if (i < _healthRecords.take(5).length - 1)
                    const Divider(color: _divider, height: 1),
                ],
              ],
            ),
    );
  }

  Widget _buildRiskItem(HealthRecord record) {
    final color = _riskColor(record.riskLevel);
    final dateStr =
        '${record.createdAt.day}/${record.createdAt.month}/${record.createdAt.year}';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          // Risk icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(Icons.favorite_outline, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          // Label + date
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                        border:
                            Border.all(color: color.withOpacity(0.3), width: 1),
                      ),
                      child: Text(
                        record.riskLevel,
                        style: TextStyle(
                          color: color,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  dateStr,
                  style: const TextStyle(color: _gray, fontSize: 12),
                ),
              ],
            ),
          ),
          // BP reading
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _bgPage,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _cardBorder, width: 1),
            ),
            child: Text(
              'BP ${record.systolicBP}/${record.diastolicBP}',
              style: const TextStyle(
                color: _navy,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Vitals Trends ──────────────────────────────────────────────────────────
  Widget _buildVitalsTrends() {
    return _Card(
      title: 'Latest Vitals',
      icon: Icons.monitor_heart_outlined,
      child: _healthRecords.isEmpty
          ? _EmptyData(label: 'No vitals data available')
          : Column(
              children: [
                _VitalRow(
                  icon: Icons.favorite_outlined,
                  label: 'Blood Pressure',
                  value:
                      '${_healthRecords.first.systolicBP}/${_healthRecords.first.diastolicBP} mmHg',
                ),
                const Divider(color: _divider, height: 1),
                _VitalRow(
                  icon: Icons.water_drop_outlined,
                  label: 'Blood Sugar',
                  value: '${_healthRecords.first.bloodSugar} mmol/L',
                ),
                const Divider(color: _divider, height: 1),
                _VitalRow(
                  icon: Icons.monitor_heart_outlined,
                  label: 'Heart Rate',
                  value: '${_healthRecords.first.heartRate} bpm',
                ),
              ],
            ),
    );
  }
}

// ─────────────────────────────────────────────
//  CARD WRAPPER
// ─────────────────────────────────────────────
class _Card extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _Card({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: _tealLight,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, color: _teal, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  color: _navy,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: _cardBorder, height: 1),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  STAT TILE  (overview grid)
// ─────────────────────────────────────────────
class _StatTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color iconBg;

  const _StatTile({
    required this.icon,
    required this.value,
    required this.label,
    required this.iconBg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: _bgPage,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _cardBorder, width: 1),
      ),
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: _white, size: 18),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: _navy,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(color: _gray, fontSize: 11),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  VITAL ROW
// ─────────────────────────────────────────────
class _VitalRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _VitalRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: _tealLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: _teal, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: _navy, fontSize: 14),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: _navy,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  EMPTY STATE
// ─────────────────────────────────────────────
class _EmptyData extends StatelessWidget {
  final String label;

  const _EmptyData({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.inbox_outlined, color: _gray, size: 18),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: _gray, fontSize: 13)),
        ],
      ),
    );
  }
}
