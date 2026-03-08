import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/app_colors.dart';
import '../../../core/responsive.dart';
import '../../../providers/language_provider.dart';
import '../../../services/api_service.dart';
import 'medical_consultation_form.dart';

// ─────────────────────────────────────────────
//  DESIGN TOKENS
// ─────────────────────────────────────────────
const _teal = Color(0xFF1A7A6E);
const _tealDark = Color(0xFF145F55);
const _tealLight = Color(0xFFE8F5F3);
const _darkText = Color(0xFF1A2B2A); // dark teal-black — zero blue
const _white = Color(0xFFFFFFFF);
const _bgPage = Color(0xFFF4F7F6);
const _gray = Color(0xFF6B7280);
const _border = Color(0xFFE5E9E8);

class CaseManagementScreen extends StatefulWidget {
  final int referralId;
  final Map<String, dynamic> referralData;

  const CaseManagementScreen({
    super.key,
    required this.referralId,
    required this.referralData,
  });

  @override
  State<CaseManagementScreen> createState() => _CaseManagementScreenState();
}

class _CaseManagementScreenState extends State<CaseManagementScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    final isEnglish = languageProvider.isEnglish;

    final mother = widget.referralData['mother'];
    final chw = widget.referralData['chw'];
    final healthReadings = widget.referralData['health_readings'];
    final status = widget.referralData['status'] ?? 'PENDING';
    final severity = widget.referralData['severity'] ?? 'Unknown';
    final notes = widget.referralData['notes'] ?? '';

    final motherName = mother?['name'] ?? 'Unknown';
    final motherAge = mother?['age'] ?? 'N/A';
    final motherPhone = mother?['phone'] ?? 'N/A';
    final riskLevel = mother?['risk_level'] ?? 'Unknown';
    final location =
        '${mother?['village'] ?? ''}, ${mother?['cell'] ?? ''}, ${mother?['sector'] ?? ''}';

    final chwName = chw?['name'] ?? 'Unknown';
    final chwPhone = chw?['phone'] ?? 'N/A';
    final hospital = widget.referralData['hospital'] ?? 'N/A';

    return Scaffold(
      backgroundColor: _bgPage,

      // ── AppBar ─────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: _teal,
        foregroundColor: _white,
        elevation: 0,
        centerTitle: false,
        title: Text(
          isEnglish ? 'Case Management' : 'Gucunga Ibibazo',
          style: const TextStyle(
            color: _white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
        iconTheme: const IconThemeData(color: _white),
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.padding(context),
          vertical: 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Patient Information ───────────────────────────
            _SectionCard(
              title: isEnglish ? 'Patient Information' : 'Amakuru y\'umubare',
              icon: Icons.person_outline_rounded,
              children: [
                _InfoRow(label: 'Name', value: motherName),
                _InfoRow(label: 'Age', value: motherAge.toString()),
                _InfoRow(label: 'Phone', value: motherPhone),
                _InfoRow(label: 'Location', value: location),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text('Risk Level: ',
                        style: TextStyle(color: _gray, fontSize: 13)),
                    _RiskBadge(risk: riskLevel),
                    const SizedBox(width: 12),
                    Text('Severity: ',
                        style: TextStyle(color: _gray, fontSize: 13)),
                    _SeverityBadge(severity: severity),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 14),

            // ── Health Readings ───────────────────────────────
            if (healthReadings != null) ...[
              _SectionCard(
                title: isEnglish ? 'Health Readings' : 'Isuzuma',
                icon: Icons.favorite_border_rounded,
                children: [
                  _InfoRow(
                      label: 'Systolic BP',
                      value: '${healthReadings['systolic_bp']} mmHg'),
                  _InfoRow(
                      label: 'Diastolic BP',
                      value: '${healthReadings['diastolic_bp']} mmHg'),
                  _InfoRow(
                      label: 'Blood Sugar',
                      value: '${healthReadings['blood_sugar']} mmol/L'),
                  _InfoRow(
                      label: 'Body Temperature',
                      value: '${healthReadings['body_temp']} °C'),
                  _InfoRow(
                      label: 'Heart Rate',
                      value: '${healthReadings['heart_rate']} bpm'),
                ],
              ),
              const SizedBox(height: 14),
            ],

            // ── Referred By ───────────────────────────────────
            _SectionCard(
              title: isEnglish ? 'Referred By' : 'Yoherejwe na',
              icon: Icons.health_and_safety_outlined,
              children: [
                _InfoRow(label: 'CHW Name', value: chwName),
                _InfoRow(label: 'CHW Phone', value: chwPhone),
                _InfoRow(label: 'Hospital', value: hospital),
              ],
            ),

            const SizedBox(height: 14),

            // ── Referral Notes ────────────────────────────────
            if (notes.isNotEmpty) ...[
              _SectionCard(
                title: isEnglish ? 'Referral Notes' : 'Ibyifashisho',
                icon: Icons.notes_rounded,
                children: [
                  Text(
                    notes,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.6,
                      color: _gray,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
            ],

            // ── Appointment Details ───────────────────────────
            if (widget.referralData['appointment_date'] != null) ...[
              _SectionCard(
                title:
                    isEnglish ? 'Scheduled Appointment' : 'Gahunda yashyizweho',
                icon: Icons.event_available_rounded,
                children: [
                  _InfoRow(
                    label: 'Date',
                    value:
                        DateTime.parse(widget.referralData['appointment_date'])
                            .toString()
                            .split(' ')[0],
                  ),
                  if (widget.referralData['appointment_time'] != null)
                    _InfoRow(
                        label: 'Time',
                        value: widget.referralData['appointment_time']),
                  if (widget.referralData['department'] != null)
                    _InfoRow(
                        label: 'Department',
                        value: widget.referralData['department']),
                ],
              ),
              const SizedBox(height: 14),
            ],

            // ── Actions ───────────────────────────────────────
            if (status != 'COMPLETED') ...[
              Text(
                isEnglish ? 'Actions' : 'Ibikorwa',
                style: const TextStyle(
                  color: _darkText,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.1,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      label: widget.referralData['appointment_date'] != null
                          ? (isEnglish ? 'Reschedule' : 'Hindura')
                          : (isEnglish ? 'Appointment' : 'Gahunda'),
                      icon: Icons.calendar_today_rounded,
                      color: _teal,
                      isLoading: _isLoading,
                      onPressed: _scheduleAppointment,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ActionButton(
                      label: isEnglish ? 'Emergency' : 'Ibihutirwa',
                      icon: Icons.emergency_rounded,
                      color: const Color(0xFFDC2626),
                      isLoading: _isLoading,
                      onPressed: () => _updateStatus('Emergency Care Required'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ActionButton(
                      label: isEnglish ? 'Complete' : 'Rangiza',
                      icon: Icons.check_circle_outline_rounded,
                      color: _tealDark,
                      isLoading: _isLoading,
                      onPressed: _markAsCompleted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }

  // ── Logic (unchanged) ───────────────────────────────────────

  Future<void> _updateStatus(String newStatus) async {
    print('🔄 Updating status to: $newStatus');

    if (newStatus == 'Completed') {
      await _markAsCompleted();
      return;
    }

    setState(() => _isLoading = true);
    try {
      final apiService = ApiService();
      final updateData = {'status': newStatus};

      if (newStatus == 'Received') {
        updateData['hospital_received_time'] = DateTime.now().toIso8601String();
      }

      print('📤 Sending update for referral ${widget.referralId}');
      await apiService.updateReferral(widget.referralId, updateData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Status updated successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      print('❌ Error updating status: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update status: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _markAsCompleted() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => MedicalConsultationForm(
        referralId: widget.referralId,
        referralData: widget.referralData,
      ),
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Case completed successfully'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context, true);
    }
  }

  Future<void> _scheduleAppointment() async {
    final languageProvider = context.read<LanguageProvider>();
    final isEnglish = languageProvider.isEnglish;
    final bool isReschedule = widget.referralData['appointment_date'] != null;

    // Pre-fill with existing appointment data if rescheduling
    DateTime initialDate = DateTime.now().add(const Duration(days: 1));
    TimeOfDay initialTime = const TimeOfDay(hour: 9, minute: 0);
    String initialDepartment = '';
    
    if (isReschedule) {
      try {
        initialDate = DateTime.parse(widget.referralData['appointment_date']);
        if (widget.referralData['appointment_time'] != null) {
          final timeParts = widget.referralData['appointment_time'].split(':');
          initialTime = TimeOfDay(hour: int.parse(timeParts[0]), minute: int.parse(timeParts[1]));
        }
        initialDepartment = widget.referralData['department'] ?? '';
      } catch (e) {
        // Use defaults if parsing fails
      }
    }

    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (time == null) return;

    final departmentController = TextEditingController(text: initialDepartment);
    final notesController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          isReschedule
              ? (isEnglish ? 'Reschedule Appointment' : 'Hindura Gahunda')
              : (isEnglish ? 'Schedule Appointment' : 'Shyiraho Gahunda'),
          style: const TextStyle(
            color: _darkText,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.calendar_today_rounded,
                      size: 16, color: _teal),
                  const SizedBox(width: 8),
                  Text('Date: ${date.day}/${date.month}/${date.year}',
                      style: const TextStyle(color: _darkText, fontSize: 13)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.access_time_rounded, size: 16, color: _teal),
                  const SizedBox(width: 8),
                  Text(
                    'Time: ${time.hour}:${time.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(color: _darkText, fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: departmentController,
                style: const TextStyle(color: _darkText, fontSize: 13),
                decoration: InputDecoration(
                  labelText: 'Department',
                  labelStyle: const TextStyle(color: _gray, fontSize: 13),
                  hintText: 'e.g., Maternity, OB/GYN',
                  hintStyle:
                      TextStyle(color: _gray.withOpacity(0.5), fontSize: 13),
                  filled: true,
                  fillColor: _bgPage,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: _border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: _border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: _teal, width: 1.8),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesController,
                maxLines: 2,
                style: const TextStyle(color: _darkText, fontSize: 13),
                decoration: InputDecoration(
                  labelText: 'Optional Notes',
                  labelStyle: const TextStyle(color: _gray, fontSize: 13),
                  hintText: 'Add any special instructions...',
                  hintStyle:
                      TextStyle(color: _gray.withOpacity(0.5), fontSize: 13),
                  filled: true,
                  fillColor: _bgPage,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: _border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: _border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: _teal, width: 1.8),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(foregroundColor: _gray),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: _teal,
              foregroundColor: _white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);
    try {
      final apiService = ApiService();
      final updateData = {
        'status': 'Appointment Scheduled',
        'appointment_date': date.toIso8601String(),
        'appointment_time':
            '${time.hour}:${time.minute.toString().padLeft(2, '0')}',
        'department': departmentController.text,
      };

      if (notesController.text.isNotEmpty) {
        updateData['treatment_notes'] = notesController.text;
      }

      await apiService.updateReferral(widget.referralId, updateData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isReschedule
                  ? (isEnglish ? 'Appointment rescheduled successfully' : 'Gahunda yahinduwe')
                  : (isEnglish ? 'Appointment scheduled successfully' : 'Gahunda yashyizweho'),
            ),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to schedule appointment'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }
}

// ─────────────────────────────────────────────
//  SECTION CARD
// ─────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
          // Section header
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: _tealLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: _teal, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  color: _darkText,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(height: 1, color: _border),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  INFO ROW
// ─────────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(color: _gray, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: _darkText,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  ACTION BUTTON
// ─────────────────────────────────────────────
class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isLoading;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: _white,
        disabledBackgroundColor: color.withOpacity(0.50),
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20),
          const SizedBox(height: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.1,
            ),
            textAlign: TextAlign.center,
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
//  SEVERITY BADGE
// ─────────────────────────────────────────────
class _SeverityBadge extends StatelessWidget {
  final String severity;
  const _SeverityBadge({required this.severity});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (severity.toLowerCase()) {
      case 'critical':
        color = const Color(0xFFDC2626);
        break;
      case 'moderate':
        color = const Color(0xFFF59E0B);
        break;
      case 'lower':
        color = _teal;
        break;
      default:
        color = _gray;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        severity,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
