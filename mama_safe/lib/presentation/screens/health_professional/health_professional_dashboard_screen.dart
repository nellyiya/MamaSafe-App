import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/app_colors.dart';
import '../../../core/responsive.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/language_provider.dart';
import '../../../services/api_service.dart';
import 'case_management_screen.dart';

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
const _border = Color(0xFFE5E9E8);

class HealthProfessionalDashboardScreen extends StatefulWidget {
  final Function(VoidCallback)? onRefreshCallback;

  const HealthProfessionalDashboardScreen({super.key, this.onRefreshCallback});

  @override
  State<HealthProfessionalDashboardScreen> createState() =>
      _HealthProfessionalDashboardScreenState();
}

class _HealthProfessionalDashboardScreenState
    extends State<HealthProfessionalDashboardScreen> {
  Map<String, dynamic>? _dashboardData;
  List<dynamic> _referrals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    widget.onRefreshCallback?.call(_loadDashboardData);
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
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

  @override
  Widget build(BuildContext context) {
    final authProvider    = context.watch<AuthProvider>();
    final languageProvider = context.watch<LanguageProvider>();
    final isEnglish       = languageProvider.isEnglish;
    final userName        = authProvider.currentUserName ?? 'Doctor';

    return Scaffold(
      backgroundColor: _bgPage,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.padding(context),
              ),
              child: _Header(userName: userName, isEnglish: isEnglish),
            ),

            // ── Body ────────────────────────────────────────────
            Expanded(
              child: RefreshIndicator(
                color: _teal,
                onRefresh: _loadDashboardData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: Responsive.padding(context),
                    vertical: 24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionLabel(
                        label: isEnglish ? 'Overview' : 'Incamake',
                      ),
                      const SizedBox(height: 14),
                      _buildStatsSection(context, isEnglish),
                      const SizedBox(height: 28),
                      if (_dashboardData?['performance'] != null)
                        _buildPerformanceMetrics(context, isEnglish),
                      if (_dashboardData?['performance'] != null)
                        const SizedBox(height: 28),
                      _SectionLabel(
                        label: isEnglish ? 'Incoming Referrals' : 'Referrals zitahariye',
                      ),
                      const SizedBox(height: 12),
                      _buildReferralsList(context, isEnglish),
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

  Widget _buildStatsSection(BuildContext context, bool isEnglish) {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40.0),
          child: CircularProgressIndicator(color: _teal),
        ),
      );
    }

    final totalReferrals = _dashboardData?['total_referrals'] ?? 0;
    final pendingReferrals = _dashboardData?['pending_referrals'] ?? 0;
    final emergencyCases = _dashboardData?['emergency_cases'] ?? 0;
    final scheduledAppointments = _dashboardData?['scheduled_appointments'] ?? 0;
    final completedCases = _dashboardData?['completed_cases'] ?? 0;

    final stats = [
      _StatData(
        title: isEnglish ? 'Total Referrals' : 'Referrals Zose',
        value: totalReferrals.toString(),
        icon: Icons.inbox_outlined,
        accentColor: _teal,
      ),
      _StatData(
        title: isEnglish ? 'Pending' : 'Bitegerejwe',
        value: pendingReferrals.toString(),
        icon: Icons.pending_outlined,
        accentColor: const Color(0xFFF59E0B),
      ),
      _StatData(
        title: isEnglish ? 'Emergency' : 'Byihutirwa',
        value: emergencyCases.toString(),
        icon: Icons.warning_amber_outlined,
        accentColor: const Color(0xFFDC2626),
      ),
      _StatData(
        title: isEnglish ? 'Scheduled' : 'Gahunda',
        value: scheduledAppointments.toString(),
        icon: Icons.calendar_today_outlined,
        accentColor: const Color(0xFF059669),
      ),
      _StatData(
        title: isEnglish ? 'Completed' : 'Byakiriwe',
        value: completedCases.toString(),
        icon: Icons.check_circle_outline,
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
            childAspectRatio: 1.15,
          ),
          itemCount: stats.length,
          itemBuilder: (context, index) => _StatCard(data: stats[index]),
        ),
      ),
    );
  }

  Widget _buildPerformanceMetrics(BuildContext context, bool isEnglish) {
    final performance      = _dashboardData?['performance'];
    final casesHandled     = performance?['cases_handled'] ?? 0;
    final avgTreatmentTime = performance?['avg_treatment_time_days'] ?? 0;
    final successRate      = performance?['resolution_success_rate'] ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(
          label: isEnglish ? 'Performance Metrics' : 'Imikorere',
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: _white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _cardBorder, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _MetricItem(
                      icon: Icons.medical_information_outlined,
                      label: isEnglish ? 'Cases Handled' : 'Ibibazo',
                      value: casesHandled.toString(),
                      color: _teal,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MetricItem(
                      icon: Icons.timer_outlined,
                      label: isEnglish ? 'Avg Time' : 'Igihe',
                      value: '${avgTreatmentTime}d',
                      color: _navy,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _MetricItem(
                icon: Icons.check_circle_outline_rounded,
                label: isEnglish ? 'Success Rate' : 'Intsinzi',
                value: '${successRate}%',
                color: _teal,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReferralsList(BuildContext context, bool isEnglish) {
    if (_referrals.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: _white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _cardBorder, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.inbox_outlined, color: _gray.withOpacity(0.5), size: 40),
              const SizedBox(height: 10),
              Text(
                isEnglish ? 'No incoming referrals' : 'Nta referrals',
                style: const TextStyle(color: _gray, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: _referrals.take(5).map((referral) {
        final notes = referral['notes'] ?? '';

        String extractValue(String label) {
          final regex = RegExp('$label:\\s*(.+?)(?=\n|\r|$)', multiLine: true);
          final match = regex.firstMatch(notes);
          return match?.group(1)?.trim() ?? '';
        }

        String patientName    = extractValue('Name');
        String patientPhone   = extractValue('Phone');
        String location       = extractValue('Location');
        String age            = extractValue('Age');
        String systolicBP     = extractValue('Systolic BP');
        String diastolicBP    = extractValue('Diastolic BP');
        String bloodSugar     = extractValue('Blood Sugar');
        String bodyTemp       = extractValue('Body Temperature');
        String heartRate      = extractValue('Heart Rate');
        String riskLevel      = extractValue('RISK LEVEL');
        String medication     = extractValue('Current Medication');
        String allergies      = extractValue('Known Allergies');
        String chronicDiseases = extractValue('Existing Diseases');
        String chwName        = referral['chw']?['name'] ?? 'Unknown CHW';

        final dateMatch    = RegExp(r'PREDICTION DATA \((.+?)\)').firstMatch(notes);
        String predictionDate = dateMatch?.group(1) ?? '';

        final notesIndex = notes.indexOf('ADDITIONAL NOTES:');
        String additionalNotes = '';
        if (notesIndex != -1) {
          additionalNotes = notes.substring(notesIndex + 17).trim();
          if (additionalNotes == 'None') additionalNotes = '';
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: _white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _cardBorder, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Card header ──
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  color: Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        color: Color(0xFFDC2626), size: 22),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'HIGH RISK REFERRAL',
                        style: TextStyle(
                          color: Color(0xFFDC2626),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    _RiskBadge(risk: riskLevel.isNotEmpty ? riskLevel : 'High'),
                  ],
                ),
              ),

              // ── Card body ──
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoSection(
                      context,
                      'Referred by CHW',
                      chwName,
                      Icons.person_outline_rounded,
                      _teal,
                    ),
                    const _Divider(),

                    _InnerSectionLabel('PATIENT INFORMATION'),
                    const SizedBox(height: 8),
                    _buildInfoRow('Name',     patientName),
                    _buildInfoRow('Phone',    patientPhone),
                    _buildInfoRow('Location', location),
                    const _Divider(),

                    _InnerSectionLabel('PREDICTION DATA ($predictionDate)'),
                    const SizedBox(height: 8),
                    _buildInfoRow('Age',              age),
                    _buildInfoRow('Systolic BP',      systolicBP),
                    _buildInfoRow('Diastolic BP',     diastolicBP),
                    _buildInfoRow('Blood Sugar',      bloodSugar),
                    _buildInfoRow('Body Temperature', bodyTemp),
                    _buildInfoRow('Heart Rate',       heartRate),
                    _buildInfoRow('Risk Level',       riskLevel, isRisk: true),
                    const _Divider(),

                    _InnerSectionLabel('MEDICAL HISTORY'),
                    const SizedBox(height: 8),
                    _buildInfoRow('Current Medication', medication),
                    _buildInfoRow('Known Allergies',    allergies),
                    _buildInfoRow('Chronic Diseases',   chronicDiseases),

                    if (additionalNotes.isNotEmpty) ...[
                      const _Divider(),
                      _InnerSectionLabel('ADDITIONAL NOTES'),
                      const SizedBox(height: 8),
                      Text(
                        additionalNotes,
                        style: const TextStyle(fontSize: 13, color: _gray, height: 1.5),
                      ),
                    ],

                    const SizedBox(height: 16),

                    // ── Action buttons ──
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CaseManagementScreen(
                                    referralId:   referral['id'],
                                    referralData: referral,
                                  ),
                                ),
                              ).then((_) => _loadDashboardData());
                            },
                            icon: const Icon(Icons.medical_services_outlined, size: 16),
                            label: const Text('Manage Case'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: _navy,
                              side: const BorderSide(color: _border, width: 1.3),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async => await _acceptReferral(referral['id']),
                            icon: const Icon(Icons.check_rounded, size: 16),
                            label: const Text('Accept'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _teal,
                              foregroundColor: _white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInfoSection(BuildContext context, String label, String value,
      IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.10),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(fontSize: 11, color: _gray)),
              Text(value,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _navy)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isRisk = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label,
                style: const TextStyle(fontSize: 13, color: _gray)),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? 'None' : value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isRisk ? AppColors.highRisk : _navy,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _acceptReferral(int referralId) async {
    try {
      final apiService = ApiService();
      await apiService.updateReferral(referralId, {'status': 'ACCEPTED'});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Referral accepted successfully'),
          backgroundColor: AppColors.success,
        ),
      );
      _loadDashboardData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to accept referral'),
          backgroundColor: AppColors.error,
        ),
      );
    }
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
//  INNER SECTION LABEL (for card sections)
// ─────────────────────────────────────────────
class _InnerSectionLabel extends StatelessWidget {
  final String text;
  const _InnerSectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: _gray,
          letterSpacing: 0.5,
        ),
      );
}

// ─────────────────────────────────────────────
//  DIVIDER
// ─────────────────────────────────────────────
class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Container(height: 1, color: _border),
      );
}

// ─────────────────────────────────────────────
//  HEADER
// ─────────────────────────────────────────────
class _Header extends StatelessWidget {
  final String userName;
  final bool isEnglish;

  const _Header({required this.userName, required this.isEnglish});

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
                      '${isEnglish ? 'Hello' : 'Muraho'}, Dr. $userName 👋',
                      style: const TextStyle(
                        color: _white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isEnglish ? 'Healthcare Professional' : 'Umuganga',
                      style: TextStyle(
                        color: _white.withOpacity(0.80),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
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
                    userName.isNotEmpty ? userName[0].toUpperCase() : 'D',
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
//  STAT CARD
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _tealLight,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(data.icon, color: _teal, size: 21),
              ),
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
    Color color;
    if (risk == 'High') {
      color = AppColors.highRisk;
    } else if (risk == 'Mid' || risk == 'Medium') {
      color = AppColors.mediumRisk;
    } else {
      color = AppColors.lowRisk;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        risk,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  URGENCY BADGE
// ─────────────────────────────────────────────
class _UrgencyBadge extends StatelessWidget {
  final String urgency;
  const _UrgencyBadge({required this.urgency});

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    if (urgency == 'Critical') {
      color = const Color(0xFFDC2626);
      icon  = Icons.emergency_rounded;
    } else if (urgency == 'High') {
      color = const Color(0xFFF59E0B);
      icon  = Icons.priority_high_rounded;
    } else {
      color = _teal;
      icon  = Icons.info_outline_rounded;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            urgency,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  METRIC ITEM
// ─────────────────────────────────────────────
class _MetricItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _MetricItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    color: color.withOpacity(0.75),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}