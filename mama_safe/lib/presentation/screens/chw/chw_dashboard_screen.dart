import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/app_colors.dart';
import '../../../core/responsive.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/language_provider.dart';
import '../../../providers/mother_provider.dart';
import '../../../services/api_service.dart';
import 'mothers_list_screen.dart';

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

/// CHW Dashboard – clean MamaSafe design
class ChwDashboardScreen extends StatefulWidget {
  final Function(VoidCallback)? onRefreshCallback;

  const ChwDashboardScreen({super.key, this.onRefreshCallback});

  @override
  State<ChwDashboardScreen> createState() => _ChwDashboardScreenState();
}

class _ChwDashboardScreenState extends State<ChwDashboardScreen> {
  Map<String, dynamic>? _dashboardData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    widget.onRefreshCallback?.call(_loadDashboardData);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadDashboardData());
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    try {
      final motherProvider = context.read<MotherProvider>();
      await motherProvider.loadMothers();
      final apiService = ApiService();
      final data = await apiService.getCHWDashboard();
      print('📊 Dashboard Data: $data');
      setState(() {
        _dashboardData = data;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Dashboard Error: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final languageProvider = context.watch<LanguageProvider>();
    final motherProvider = context.watch<MotherProvider>();
    final isEnglish = languageProvider.isEnglish;
    final userName = authProvider.currentUserName ?? 'User';

    return Scaffold(
      backgroundColor: _bgPage,
      body: SafeArea(
        child: RefreshIndicator(
          color: _teal,
          onRefresh: _loadDashboardData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.padding(context),
              vertical: 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ──────────────────────────────
                _Header(userName: userName, isEnglish: isEnglish),
                const SizedBox(height: 28),

                // ── Section label ────────────────────────
                _SectionLabel(
                  label: isEnglish ? 'Overview' : 'Incamake',
                ),
                const SizedBox(height: 14),

                // ── Stats grid ───────────────────────────
                _buildStatsSection(context, isEnglish, motherProvider),
                const SizedBox(height: 28),

                // ── Due date countdown ───────────────────
                _buildDueDateCountdown(context, isEnglish, motherProvider),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Stats Section ──────────────────────────────────────────────────────────
  Widget _buildStatsSection(
      BuildContext context, bool isEnglish, MotherProvider motherProvider) {
    final totalMothers =
        _dashboardData?['total_mothers'] ?? motherProvider.totalMothersCount;
    final highRisk =
        _dashboardData?['high_risk_cases'] ?? motherProvider.highRiskCount;
    final midRisk = _dashboardData?['mid_risk_cases'] ?? 0;
    final lowRisk = _dashboardData?['low_risk_cases'] ?? 0;
    final activeReferrals =
        _dashboardData?['active_referrals'] ?? motherProvider.referralsCount;
    final scheduledAppointments = _dashboardData?['scheduled_appointments'] ?? 0;

    final stats = [
      _StatData(
        title: isEnglish ? 'Total Mothers' : 'Ababyeyi bose',
        value: totalMothers.toString(),
        icon: Icons.people_alt_outlined,
        accentColor: _teal,
      ),
      _StatData(
        title: isEnglish ? 'High Risk' : 'Ingorane z\'ingeri',
        value: highRisk.toString(),
        icon: Icons.warning_amber_outlined,
        accentColor: _teal,
      ),
      _StatData(
        title: isEnglish ? 'Mid Risk' : 'Hagati',
        value: midRisk.toString(),
        icon: Icons.info_outline,
        accentColor: _teal,
      ),
      _StatData(
        title: isEnglish ? 'Low Risk' : 'Ibibazo bike',
        value: lowRisk.toString(),
        icon: Icons.check_circle_outline,
        accentColor: _teal,
      ),
      _StatData(
        title: isEnglish ? 'Referrals' : 'Referrals',
        value: activeReferrals.toString(),
        icon: Icons.send_outlined,
        accentColor: _teal,
      ),
      _StatData(
        title: isEnglish ? 'Appointments' : 'Gahunda',
        value: scheduledAppointments.toString(),
        icon: Icons.calendar_today_outlined,
        accentColor: _teal,
      ),
    ];

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: Responsive.gridCrossAxisCount(context),
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 1.4,
          ),
          itemCount: stats.length,
          itemBuilder: (context, index) => _StatCard(data: stats[index]),
        ),
      ),
    );
  }

  // ── Due Date Countdown ─────────────────────────────────────────────────────
  Widget _buildDueDateCountdown(
      BuildContext context, bool isEnglish, MotherProvider motherProvider) {
    final mothersWithDueDates =
        motherProvider.mothers.where((m) => m.dueDate != null).toList();

    if (mothersWithDueDates.isEmpty) return const SizedBox.shrink();

    mothersWithDueDates.sort((a, b) => a.dueDate!.compareTo(b.dueDate!));
    final nearestMother = mothersWithDueDates.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(
          label: isEnglish ? 'Upcoming Due Date' : 'Itariki y\'kubyara',
        ),
        const SizedBox(height: 14),
        _DueDateCountdownCard(mother: nearestMother, isEnglish: isEnglish),
        const SizedBox(height: 10),
        Center(
          child: TextButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => MothersListScreen()),
            ),
            icon: const Icon(Icons.arrow_forward, size: 16),
            label: Text(isEnglish ? 'See All Mothers' : 'Reba byinshi'),
            style: TextButton.styleFrom(
              foregroundColor: _teal,
              textStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  HEADER
// ─────────────────────────────────────────────
class _Header extends StatelessWidget {
  final String userName;
  final bool isEnglish;

  const _Header({required this.userName, required this.isEnglish});

  void _downloadReport(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _tealLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.download, color: _teal, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              isEnglish ? 'Download Report' : 'Kuramo Raporo',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ReportOption(
              title: isEnglish ? 'All Mothers' : 'Ababyeyi Bose',
              subtitle: isEnglish ? 'Complete list of all pregnant women' : 'Urutonde rw\'ababyeyi bose',
              icon: Icons.people_alt_outlined,
              onTap: () {
                Navigator.pop(context);
                _downloadReportType(context, 'all');
              },
            ),
            const SizedBox(height: 8),
            _ReportOption(
              title: isEnglish ? 'High Risk Only' : 'Ingorane Nyinshi Gusa',
              subtitle: isEnglish ? 'Mothers with high risk status' : 'Ababyeyi bafite ingorane nyinshi',
              icon: Icons.warning_amber_outlined,
              color: const Color(0xFFDC2626),
              onTap: () {
                Navigator.pop(context);
                _downloadReportType(context, 'high_risk');
              },
            ),
            const SizedBox(height: 8),
            _ReportOption(
              title: isEnglish ? 'With Referrals' : 'Bafite Referrals',
              subtitle: isEnglish ? 'Mothers with active referrals' : 'Ababyeyi bafite referrals',
              icon: Icons.send_outlined,
              onTap: () {
                Navigator.pop(context);
                _downloadReportType(context, 'referrals');
              },
            ),
            const SizedBox(height: 8),
            _ReportOption(
              title: isEnglish ? 'With Appointments' : 'Bafite Gahunda',
              subtitle: isEnglish ? 'Mothers with scheduled appointments' : 'Ababyeyi bafite gahunda',
              icon: Icons.calendar_today_outlined,
              onTap: () {
                Navigator.pop(context);
                _downloadReportType(context, 'appointments');
              },
            ),
            const SizedBox(height: 8),
            _ReportOption(
              title: isEnglish ? 'Due This Month' : 'Bazabyara Uku Kwezi',
              subtitle: isEnglish ? 'Mothers due in current month' : 'Ababyeyi bazabyara uku kwezi',
              icon: Icons.event_outlined,
              onTap: () {
                Navigator.pop(context);
                _downloadReportType(context, 'due_this_month');
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              isEnglish ? 'Cancel' : 'Hagarika',
              style: const TextStyle(color: _gray),
            ),
          ),
        ],
      ),
    );
  }

  void _downloadReportType(BuildContext context, String reportType) {
    // TODO: Implement actual download
    // URL format: http://localhost:8000/reports/chw/mothers?type={reportType}
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isEnglish
            ? 'Downloading $reportType report...'
            : 'Kuramo raporo ya $reportType...'),
        backgroundColor: _teal,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A7A6E), Color(0xFF1D8C7F)],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A7A6E).withOpacity(0.30),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circle top-right
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _white.withOpacity(0.06),
              ),
            ),
          ),
          Positioned(
            right: 20,
            bottom: -30,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _white.withOpacity(0.04),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${isEnglish ? 'Hello' : 'Muraho'}, $userName ',
                      style: const TextStyle(
                        color: _white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isEnglish
                          ? 'Community Health Worker'
                          : 'Umuruhinzi w\'ubuzima',
                      style: TextStyle(
                        color: _white.withOpacity(0.80),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              // Download Report Button
              IconButton(
                onPressed: () => _downloadReport(context),
                icon: const Icon(Icons.download_outlined),
                color: _white,
                tooltip: isEnglish ? 'Download Report' : 'Kuramo Raporo',
                style: IconButton.styleFrom(
                  backgroundColor: _white.withOpacity(0.15),
                  padding: const EdgeInsets.all(10),
                ),
              ),
              const SizedBox(width: 8),
              // Avatar
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.10),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      color: _teal,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  SECTION LABEL
// ─────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: _teal,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: _navy,
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  STAT DATA MODEL
// ─────────────────────────────────────────────
class _StatData {
  final String title;
  final String value;
  final IconData icon;
  final Color accentColor;

  const _StatData({
    required this.title,
    required this.value,
    required this.icon,
    required this.accentColor,
  });
}

// ─────────────────────────────────────────────
//  STAT CARD — clean white + teal icon design
// ─────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final _StatData data;
  const _StatCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _cardBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ── Top row: icon left, tiny accent dot right ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Teal icon square — softly tinted bg, teal icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _tealLight,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(data.icon, color: _teal, size: 21),
              ),
              // Small accent circle — colored per stat type
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: data.accentColor,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),

          // ── Bottom: number + label ──
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.value,
                style: const TextStyle(
                  color: _navy,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.8,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                data.title,
                style: const TextStyle(
                  color: _gray,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  RISK BADGE
// ─────────────────────────────────────────────
class _RiskBadge extends StatelessWidget {
  final String risk;

  const _RiskBadge({required this.risk});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color text;

    if (risk == 'High') {
      bg = const Color(0xFFDC2626);
      text = const Color(0xFFDC2626);
    } else if (risk == 'Medium') {
      bg = const Color(0xFFD97706);
      text = const Color(0xFFD97706);
    } else {
      bg = _teal;
      text = _teal;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: bg.withOpacity(0.3), width: 1),
      ),
      child: Text(
        risk,
        style: TextStyle(
          color: text,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  MOTHER LIST ITEM
// ─────────────────────────────────────────────
class _MotherListItem extends StatelessWidget {
  final dynamic mother;
  final bool isEnglish;

  const _MotherListItem({required this.mother, required this.isEnglish});

  @override
  Widget build(BuildContext context) {
    final dueDate = mother.nextVisitDate;
    final dateStr = dueDate != null
        ? '${dueDate.day}/${dueDate.month}/${dueDate.year}'
        : 'No visit scheduled';

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => MothersListScreen()),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: _white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _cardBorder, width: 1.0),
          boxShadow: [
            BoxShadow(
              color: _teal.withOpacity(0.05),
              blurRadius: 14,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: _tealLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.pregnant_woman, color: _teal, size: 22),
            ),
            const SizedBox(width: 12),
            // Name + date
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mother.fullName,
                    style: const TextStyle(
                      color: _navy,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    dateStr,
                    style: const TextStyle(
                      color: _gray,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            _RiskBadge(risk: mother.riskLevel),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  ACTION CARD  (kept for use elsewhere)
// ─────────────────────────────────────────────
class _ActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Color> gradient;
  final VoidCallback? onTap;

  const _ActionCard({
    required this.title,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _cardBorder, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradient),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, color: _white, size: 22),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                color: _navy,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  DUE DATE COUNTDOWN CARD
// ─────────────────────────────────────────────
class _DueDateCountdownCard extends StatefulWidget {
  final dynamic mother;
  final bool isEnglish;

  const _DueDateCountdownCard({required this.mother, required this.isEnglish});

  @override
  State<_DueDateCountdownCard> createState() => _DueDateCountdownCardState();
}

class _DueDateCountdownCardState extends State<_DueDateCountdownCard> {
  late Stream<Duration> _countdownStream;

  @override
  void initState() {
    super.initState();
    _countdownStream = Stream.periodic(
      const Duration(seconds: 1),
      (_) => widget.mother.dueDate!.difference(DateTime.now()),
    );
  }

  String _formatCountdown(Duration duration) {
    if (duration.isNegative) return '0d 0h 0m 0s';
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;
    return '${days}d  ${hours}h  ${minutes}m  ${seconds}s';
  }

  Color _urgencyColor(Duration remaining) {
    if (remaining.inDays <= 7) return const Color(0xFFDC2626);
    if (remaining.inDays <= 30) return const Color(0xFFD97706);
    return _teal;
  }

  @override
  Widget build(BuildContext context) {
    final dueDate = widget.mother.dueDate!;
    final dateStr = '${dueDate.day}/${dueDate.month}/${dueDate.year}';

    return StreamBuilder<Duration>(
      stream: _countdownStream,
      initialData: dueDate.difference(DateTime.now()),
      builder: (context, snapshot) {
        final remaining = snapshot.data ?? Duration.zero;
        final urgency = _urgencyColor(remaining);

        return Container(
          decoration: BoxDecoration(
            color: _white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: _teal.withOpacity(0.10),
                blurRadius: 24,
                spreadRadius: 0,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Teal gradient header strip
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [_teal, const Color(0xFF22958A)],
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: _white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.pregnant_woman,
                            color: _white, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.mother.fullName,
                              style: const TextStyle(
                                color: _white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Icon(Icons.calendar_today_outlined,
                                    size: 11, color: _white.withOpacity(0.8)),
                                const SizedBox(width: 4),
                                Text(
                                  '${widget.isEnglish ? 'Due' : 'Itariki'}: $dateStr',
                                  style: TextStyle(
                                    color: _white.withOpacity(0.85),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      _RiskBadge(risk: widget.mother.riskLevel ?? 'Low'),
                    ],
                  ),
                ),

                // Countdown section
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 18, horizontal: 16),
                    decoration: BoxDecoration(
                      color: urgency.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: urgency.withOpacity(0.2), width: 1.5),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.timer_outlined,
                                color: urgency, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              widget.isEnglish
                                  ? 'Time Remaining'
                                  : 'Igihe gisigaye',
                              style: TextStyle(
                                color: urgency,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _formatCountdown(remaining),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: urgency,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}


// ─────────────────────────────────────────────
//  REPORT OPTION
// ─────────────────────────────────────────────
class _ReportOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color? color;
  final VoidCallback onTap;

  const _ReportOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final optionColor = color ?? _teal;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: _cardBorder),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: optionColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: optionColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _navy,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: _gray,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 14, color: _gray),
          ],
        ),
      ),
    );
  }
}
