import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../../core/app_colors.dart';
import '../../../core/responsive.dart';
import '../../../providers/language_provider.dart';
import '../../../services/api_service.dart';

// ─────────────────────────────────────────────
//  DESIGN TOKENS
// ─────────────────────────────────────────────
const _teal = Color(0xFF1A7A6E);
const _tealDark = Color(0xFF145F55);
const _navy = Color(0xFF1E2D4E);
const _white = Color(0xFFFFFFFF);
const _bgPage = Color(0xFFF0F4F3);
const _gray = Color(0xFF6B7280);
const _border = Color(0xFFDDE3E2);

/// Hospital Reports Screen - Performance & Analytics
class HospitalReportsScreen extends StatefulWidget {
  const HospitalReportsScreen({super.key});

  @override
  State<HospitalReportsScreen> createState() => _HospitalReportsScreenState();
}

class _HospitalReportsScreenState extends State<HospitalReportsScreen> {
  Map<String, dynamic>? _dashboardData;
  List<dynamic> _referrals = [];
  bool _isLoading = true;
  Timer? _autoRefreshTimer;

  @override
  void initState() {
    super.initState();
    _loadReports();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    super.dispose();
  }

  void _startAutoRefresh() {
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _loadReports();
    });
  }

  Future<void> _loadReports() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final apiService = ApiService();
      final data = await apiService.getHealthcareProDashboard();
      final referrals = await apiService.getIncomingReferrals();
      if (!mounted) return;
      setState(() {
        _dashboardData = data;
        _referrals = referrals;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  void _downloadReport(String type) {
    final parts = type.split('_');
    final period = parts[0];
    final format = parts[1];
    final now = DateTime.now();
    String dateRange;
    List<dynamic> filteredData;

    switch (period) {
      case 'daily':
        dateRange =
            '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
        filteredData = _referrals.where((ref) {
          if (ref['created_at'] == null) return false;
          final createdAt = DateTime.parse(ref['created_at']);
          return createdAt.year == now.year &&
              createdAt.month == now.month &&
              createdAt.day == now.day;
        }).toList();
        break;
      case 'monthly':
        dateRange = '${now.year}-${now.month.toString().padLeft(2, '0')}';
        filteredData = _referrals.where((ref) {
          if (ref['created_at'] == null) return false;
          final createdAt = DateTime.parse(ref['created_at']);
          return createdAt.year == now.year && createdAt.month == now.month;
        }).toList();
        break;
      case 'yearly':
        dateRange = '${now.year}';
        filteredData = _referrals.where((ref) {
          if (ref['created_at'] == null) return false;
          final createdAt = DateTime.parse(ref['created_at']);
          return createdAt.year == now.year;
        }).toList();
        break;
      default:
        filteredData = _referrals;
        dateRange = 'all';
    }

    final emergencyCount = filteredData
        .where((r) => r['status'] == 'Emergency Care Required')
        .length;
    final completedCount =
        filteredData.where((r) => r['status'] == 'Completed').length;
    final totalCount = filteredData.length;
    final emergencyRate = totalCount > 0
        ? (emergencyCount / totalCount * 100).toStringAsFixed(1)
        : '0.0';
    final completionRate = totalCount > 0
        ? (completedCount / totalCount * 100).toStringAsFixed(1)
        : '0.0';

    final reportData = '''
HOSPITAL PERFORMANCE REPORT
Period: ${period.toUpperCase()} ($dateRange)
Generated: ${DateTime.now()}

=== KEY METRICS ===
Total Referrals: $totalCount
Emergency Cases: $emergencyCount
Completed Cases: $completedCount
Emergency Rate: $emergencyRate%
Completion Rate: $completionRate%
Avg Response Time: ${_dashboardData?['avg_response_time'] ?? 'N/A'}

=== STATUS DISTRIBUTION ===
Pending: ${filteredData.where((r) => r['status'] == 'Pending').length}
Received: ${filteredData.where((r) => r['status'] == 'Received').length}
Emergency: $emergencyCount
Scheduled: ${filteredData.where((r) => r['status'] == 'Appointment Scheduled').length}
Completed: $completedCount

=== REFERRAL DETAILS ===
''';

    final csvData = format == 'csv' ? _generateCSV(filteredData) : reportData;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Downloading ${period.toUpperCase()} report as ${format.toUpperCase()}...'),
        backgroundColor: AppColors.success,
        action: SnackBarAction(
          label: 'View',
          textColor: _white,
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: _white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                title: const Text(
                  'Report Preview',
                  style: TextStyle(
                    color: _navy,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                content: SingleChildScrollView(
                  child: Text(
                    csvData,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      color: _navy,
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(foregroundColor: _gray),
                    child: const Text('Close'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String _generateCSV(List<dynamic> data) {
    String csv =
        'ID,Patient Name,Age,Status,Severity,Risk Level,Created At,CHW Name\n';
    for (var ref in data) {
      csv +=
          '${ref['id']},\"${ref['mother']?['name'] ?? 'N/A'}\",${ref['mother']?['age'] ?? 'N/A'},\"${ref['status'] ?? 'N/A'}\",\"${ref['severity'] ?? 'N/A'}\",\"${ref['mother']?['risk_level'] ?? 'N/A'}\",\"${ref['created_at'] ?? 'N/A'}\",\"${ref['chw']?['name'] ?? 'N/A'}\"\n';
    }
    return csv;
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    final isEnglish = languageProvider.isEnglish;

    return Scaffold(
      backgroundColor: _bgPage,
      body: SafeArea(
        child: Column(
          children: [
            // ── Teal header ─────────────────────────────────────
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.padding(context),
                vertical: 18,
              ),
              decoration: const BoxDecoration(
                color: _teal,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEnglish ? 'Reports' : 'Raporo',
                          style: const TextStyle(
                            color: _white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isEnglish
                              ? 'Performance & Analytics'
                              : 'Imikorere n\'isesengura',
                          style: TextStyle(
                            color: _white.withOpacity(0.80),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // ── Download button ──
                  PopupMenuButton<String>(
                    onSelected: _downloadReport,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    color: _white,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: _white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: _white.withOpacity(0.35), width: 1.2),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.download_rounded, color: _white, size: 18),
                          SizedBox(width: 6),
                          Text(
                            'Download',
                            style: TextStyle(
                              color: _white,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                          SizedBox(width: 2),
                          Icon(Icons.arrow_drop_down_rounded,
                              color: _white, size: 20),
                        ],
                      ),
                    ),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'daily_pdf',
                        child: _popupItem(Icons.picture_as_pdf_rounded,
                            'Daily Report (PDF)', const Color(0xFFDC2626)),
                      ),
                      PopupMenuItem(
                        value: 'daily_csv',
                        child: _popupItem(Icons.table_chart_rounded,
                            'Daily Report (CSV)', const Color(0xFF059669)),
                      ),
                      const PopupMenuDivider(),
                      PopupMenuItem(
                        value: 'monthly_pdf',
                        child: _popupItem(Icons.picture_as_pdf_rounded,
                            'Monthly Report (PDF)', const Color(0xFFDC2626)),
                      ),
                      PopupMenuItem(
                        value: 'monthly_csv',
                        child: _popupItem(Icons.table_chart_rounded,
                            'Monthly Report (CSV)', const Color(0xFF059669)),
                      ),
                      const PopupMenuDivider(),
                      PopupMenuItem(
                        value: 'yearly_pdf',
                        child: _popupItem(Icons.picture_as_pdf_rounded,
                            'Yearly Report (PDF)', const Color(0xFFDC2626)),
                      ),
                      PopupMenuItem(
                        value: 'yearly_csv',
                        child: _popupItem(Icons.table_chart_rounded,
                            'Yearly Report (CSV)', const Color(0xFF059669)),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Body ────────────────────────────────────────────
            Expanded(
              child: RefreshIndicator(
                color: _teal,
                onRefresh: _loadReports,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: Responsive.padding(context),
                    vertical: 20,
                  ),
                  child: _isLoading
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.only(top: 60),
                            child: CircularProgressIndicator(color: _teal),
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildMetricsSection(context, isEnglish),
                            const SizedBox(height: 16),
                            _buildReferralTrends(context, isEnglish),
                            const SizedBox(height: 16),
                            _buildStatusDistribution(context, isEnglish),
                            const SizedBox(height: 8),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Popup menu item helper ───────────────────────────────────
  Widget _popupItem(IconData icon, String label, Color color) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
              color: _navy, fontSize: 13, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  // ── Section header helper ────────────────────────────────────
  Widget _sectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: _navy,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: _white, size: 18),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            color: _navy,
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.1,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricsSection(BuildContext context, bool isEnglish) {
    final avgResponseTime = _dashboardData?['avg_response_time'] ?? '0h';
    final emergencyCases = _dashboardData?['emergency_cases'] ?? 0;
    final totalReferrals = _dashboardData?['total_referrals'] ?? 0;
    final completedCases = _dashboardData?['completed_cases'] ?? 0;

    final emergencyRate = totalReferrals > 0
        ? (emergencyCases / totalReferrals * 100).toStringAsFixed(1)
        : '0.0';
    final completionRate = totalReferrals > 0
        ? (completedCases / totalReferrals * 100).toStringAsFixed(1)
        : '0.0';

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildMetricCard(
          icon: Icons.timer_outlined,
          label: isEnglish ? 'Avg Response Time' : 'Igihe',
          value: avgResponseTime,
          iconBg: _navy,
        ),
        _buildMetricCard(
          icon: Icons.emergency_rounded,
          label: isEnglish ? 'Emergency Rate' : 'Ibibazo bikomeye',
          value: '$emergencyRate%',
          iconBg: const Color(0xFFDC2626),
        ),
        _buildMetricCard(
          icon: Icons.calendar_month_rounded,
          label: isEnglish ? 'Total This Month' : 'Iki kwezi',
          value: totalReferrals.toString(),
          iconBg: _teal,
        ),
        _buildMetricCard(
          icon: Icons.check_circle_outline_rounded,
          label: isEnglish ? 'Completion Rate' : 'Byarangiye',
          value: '$completionRate%',
          iconBg: const Color(0xFF059669),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required String label,
    required String value,
    required Color iconBg,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: _white, size: 18),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              color: _navy,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: _gray, fontSize: 11),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildReferralTrends(BuildContext context, bool isEnglish) {
    final now = DateTime.now();
    final last7Days =
        List.generate(7, (i) => now.subtract(Duration(days: 6 - i)));

    final dailyCounts = <int>[];
    for (var day in last7Days) {
      final count = _referrals.where((ref) {
        if (ref['created_at'] == null) return false;
        final createdAt = DateTime.parse(ref['created_at']);
        return createdAt.year == day.year &&
            createdAt.month == day.month &&
            createdAt.day == day.day;
      }).length;
      dailyCounts.add(count);
    }

    final maxCount =
        dailyCounts.isEmpty ? 1 : dailyCounts.reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            isEnglish
                ? 'Referrals Per Day (Last 7 Days)'
                : 'Referrals ku munsi',
            Icons.bar_chart_rounded,
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 150,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(7, (i) {
                final barH =
                    maxCount > 0 ? (dailyCounts[i] / maxCount * 110) : 0.0;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      dailyCounts[i].toString(),
                      style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: _navy),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 28,
                      height: barH < 20 ? 20 : barH,
                      decoration: BoxDecoration(
                        color: _teal,
                        borderRadius: BorderRadius.circular(7),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      [
                        'Mon',
                        'Tue',
                        'Wed',
                        'Thu',
                        'Fri',
                        'Sat',
                        'Sun'
                      ][last7Days[i].weekday - 1],
                      style: const TextStyle(fontSize: 10, color: _gray),
                    ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusDistribution(BuildContext context, bool isEnglish) {
    final emergencyCount = _referrals
        .where((r) => r['status'] == 'Emergency Care Required')
        .length;
    final scheduledCount =
        _referrals.where((r) => r['status'] == 'Appointment Scheduled').length;
    final completedCount =
        _referrals.where((r) => r['status'] == 'Completed').length;
    final pendingCount =
        _referrals.where((r) => r['status'] == 'Pending').length;
    final receivedCount =
        _referrals.where((r) => r['status'] == 'Received').length;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            isEnglish ? 'Status Distribution' : 'Imiterere',
            Icons.pie_chart_outline_rounded,
          ),
          const SizedBox(height: 16),
          _buildStatusBar('Emergency', emergencyCount, const Color(0xFFDC2626)),
          const SizedBox(height: 10),
          _buildStatusBar('Scheduled', scheduledCount, _teal),
          const SizedBox(height: 10),
          _buildStatusBar('Completed', completedCount, const Color(0xFF059669)),
          const SizedBox(height: 10),
          _buildStatusBar('Pending', pendingCount, const Color(0xFFF59E0B)),
          const SizedBox(height: 10),
          _buildStatusBar('Received', receivedCount, _navy),
        ],
      ),
    );
  }

  Widget _buildStatusBar(String label, int count, Color color) {
    final total = _referrals.length;
    final percentage = total > 0 ? (count / total) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: _navy,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            Text(
              '$count (${(percentage * 100).toStringAsFixed(0)}%)',
              style: const TextStyle(fontSize: 12, color: _gray),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: percentage,
            backgroundColor: _border,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}
