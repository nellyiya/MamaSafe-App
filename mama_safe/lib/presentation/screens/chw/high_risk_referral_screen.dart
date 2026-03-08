import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/app_colors.dart';
import '../../../services/api_service.dart';
import '../../../providers/mother_provider.dart';

// ─────────────────────────────────────────────
//  DESIGN TOKENS
// ─────────────────────────────────────────────
const _teal        = Color(0xFF1A7A6E);
const _tealLight   = Color(0xFFE8F5F3);
const _navy        = Color(0xFF1E2D4E);
const _white       = Color(0xFFFFFFFF);
const _bgPage      = Color(0xFFF4F7F6);
const _gray        = Color(0xFF6B7280);
const _cardBorder  = Color(0xFFE5E9E8);
const _inputFill   = Color(0xFFF9FAFA);
const _inputBorder = Color(0xFFD1D9D7);
const _readonlyFill = Color(0xFFF1F5F4);
const _red         = Color(0xFFDC2626);
const _amber       = Color(0xFFD97706);

class HighRiskReferralScreen extends StatefulWidget {
  final String?  motherId;
  final int      age;
  final int      systolicBP;
  final int      diastolicBP;
  final double   bloodSugar;
  final double   bodyTemp;
  final int      heartRate;
  final String   riskLevel;
  final DateTime predictionDate;

  const HighRiskReferralScreen({
    Key? key,
    this.motherId,
    required this.age,
    required this.systolicBP,
    required this.diastolicBP,
    required this.bloodSugar,
    required this.bodyTemp,
    required this.heartRate,
    required this.riskLevel,
    required this.predictionDate,
  }) : super(key: key);

  @override
  State<HighRiskReferralScreen> createState() =>
      _HighRiskReferralScreenState();
}

class _HighRiskReferralScreenState extends State<HighRiskReferralScreen> {
  final _formKey             = GlobalKey<FormState>();
  final _nameController      = TextEditingController();
  final _phoneController     = TextEditingController();
  final _villageController   = TextEditingController();
  final _sectorController    = TextEditingController();

  final _notesController      = TextEditingController();

  String? _selectedHospital;
  String? _severityLevel;
  int?    _severityScore;
  String? _reasoning;
  bool    _isLoading               = false;
  bool    _isLoadingRecommendation = false;

  @override
  void initState() {
    super.initState();
    _loadMotherData();
    _getAutomaticHospitalRecommendation();
  }

  // ── Data loading (UNCHANGED) ───────────────────────────────────────────────
  void _loadMotherData() {
    if (widget.motherId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final motherProvider = context.read<MotherProvider>();
        final mother = motherProvider.getMotherById(widget.motherId!);
        if (mother != null) {
          setState(() {
            _nameController.text     = mother.fullName;
            _phoneController.text    = mother.phoneNumber;
            _villageController.text  = mother.address.split(',').last.trim();
            _sectorController.text   = mother.address.split(',').length > 1
                ? mother.address.split(',')[1].trim()
                : '';

          });
        }
      });
    }
  }

  Future<void> _getAutomaticHospitalRecommendation() async {
    if (widget.motherId == null) return;
    setState(() => _isLoadingRecommendation = true);
    try {
      final apiService = ApiService();
      final response = await apiService.predictWithReferral(
        motherId:    int.parse(widget.motherId!),
        age:         widget.age,
        systolicBP:  widget.systolicBP,
        diastolicBP: widget.diastolicBP,
        bloodSugar:  widget.bloodSugar,
        bodyTemp:    widget.bodyTemp,
        heartRate:   widget.heartRate,
      );
      if (response['referral_required'] == true) {
        setState(() {
          _selectedHospital = response['recommended_hospital'];
          _severityLevel    = response['severity'];
          _severityScore    = response['severity_score'];
          _reasoning        = response['reasoning'];
        });
      }
    } catch (e) {
      print('Error getting hospital recommendation: $e');
    } finally {
      setState(() => _isLoadingRecommendation = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _villageController.dispose();
    _sectorController.dispose();

    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitReferral() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedHospital == null) {
      _showSnack('Please wait for hospital recommendation', error: true);
      return;
    }
    setState(() => _isLoading = true);
    try {
      if (widget.motherId == null) {
        throw Exception('Mother ID is required for referral');
      }

      final comprehensiveNotes = '''
PATIENT INFORMATION:
Name: ${_nameController.text}
Phone: ${_phoneController.text}
Location: ${_villageController.text}, ${_sectorController.text}

PREDICTION DATA (${widget.predictionDate.toString().split(' ')[0]}):
Age: ${widget.age} years
Systolic BP: ${widget.systolicBP} mmHg
Diastolic BP: ${widget.diastolicBP} mmHg
Blood Sugar: ${widget.bloodSugar} mmol/L
Body Temperature: ${widget.bodyTemp} °C
Heart Rate: ${widget.heartRate} bpm
RISK LEVEL: ${widget.riskLevel}

SEVERITY ASSESSMENT:
Severity Level: ${_severityLevel ?? 'Not calculated'}
Severity Score: ${_severityScore ?? 0}/7
Reasoning: ${_reasoning ?? 'N/A'}

ADDITIONAL NOTES:
${_notesController.text.isEmpty ? 'None' : _notesController.text}
''';

      final apiService = ApiService();
      await apiService.createReferral({
        'mother_id'          : int.parse(widget.motherId!),
        'hospital'           : _selectedHospital!,
        'severity'           : _severityLevel,
        'notes'              : comprehensiveNotes,
        'risk_detected_time' : widget.predictionDate.toIso8601String(),
      });

      if (mounted) {
        _showSnack('High-risk referral created successfully');
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) _showSnack('Failed to create referral: $e', error: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: error ? _red : _teal,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ── BUILD ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgPage,
      appBar: AppBar(
        title: const Text(
          'High Risk Referral',
          style: TextStyle(
              color: _white, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        backgroundColor: _red,
        foregroundColor: _white,
        elevation: 0,
        iconTheme: const IconThemeData(color: _white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Alert banner ───────────────────────────────────────────────
              _AlertBanner(),
              const SizedBox(height: 20),

              // ── Prediction data card ───────────────────────────────────────
              _SectionCard(
                title: 'Prediction Data',
                subtitle: 'Auto-filled · read only',
                icon: Icons.lock_outline,
                iconBg: _navy,
                child: _PredictionDataTable(widget: widget),
              ),
              const SizedBox(height: 14),

              // ── Patient info card ──────────────────────────────────────────
              _SectionCard(
                title: 'Patient Information',
                subtitle: 'Auto-filled · read only',
                icon: Icons.person_outline,
                iconBg: _navy,
                child: Column(
                  children: [
                    _ReadOnlyRow(label: 'Full Name',     value: _nameController.text),
                    _RowDivider(),
                    _ReadOnlyRow(label: 'Phone Number',  value: _phoneController.text),
                    _RowDivider(),
                    _ReadOnlyRow(label: 'Village',       value: _villageController.text),
                    _RowDivider(),
                    _ReadOnlyRow(label: 'Sector',        value: _sectorController.text),
                  ],
                ),
              ),


              // ── Additional notes ───────────────────────────────────────────
              _SectionCard(
                title: 'Additional Notes',
                subtitle: 'Optional',
                icon: Icons.edit_note_outlined,
                iconBg: _teal,
                child: TextFormField(
                  controller: _notesController,
                  maxLines: 4,
                  style: const TextStyle(color: _navy, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Add any additional observations or notes…',
                    hintStyle: const TextStyle(color: _gray, fontSize: 13),
                    filled: true,
                    fillColor: _inputFill,
                    contentPadding: const EdgeInsets.all(14),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(11),
                      borderSide:
                          const BorderSide(color: _inputBorder, width: 1.2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(11),
                      borderSide:
                          const BorderSide(color: _teal, width: 1.8),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // ── Hospital selection card ────────────────────────────────────
              _SectionCard(
                title: 'Assigned Hospital',
                subtitle: 'Auto-selected based on severity',
                icon: Icons.local_hospital_outlined,
                iconBg: _teal,
                child: _isLoadingRecommendation
                    ? _HospitalLoading()
                    : _selectedHospital != null
                        ? _HospitalSelected(
                            hospital:      _selectedHospital!,
                            severityLevel: _severityLevel,
                            severityScore: _severityScore,
                            reasoning:     _reasoning,
                          )
                        : _HospitalError(),
              ),
              const SizedBox(height: 28),

              // ── Submit button ──────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _submitReferral,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: _white, strokeWidth: 2.5),
                        )
                      : const Icon(Icons.send_outlined, size: 20),
                  label: Text(
                    _isLoading ? 'Submitting…' : 'Submit Referral',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _red,
                    foregroundColor: _white,
                    disabledBackgroundColor: _red.withOpacity(0.5),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  ALERT BANNER
// ─────────────────────────────────────────────
class _AlertBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _red.withOpacity(0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _red.withOpacity(0.3), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _red.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.warning_amber_rounded,
                color: _red, size: 24),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'High Risk Detected',
                  style: TextStyle(
                    color: _red,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Immediate referral to a healthcare professional is required.',
                  style: TextStyle(
                      color: _gray, fontSize: 12, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  SECTION CARD
// ─────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final String   title;
  final String   subtitle;
  final IconData icon;
  final Color    iconBg;
  final Widget   child;

  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconBg,
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
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconBg == _teal ? _tealLight : iconBg.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon,
                    color: iconBg == _teal ? _teal : iconBg, size: 18),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: _navy,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(color: _gray, fontSize: 11),
                  ),
                ],
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
//  PREDICTION DATA TABLE
// ─────────────────────────────────────────────
class _PredictionDataTable extends StatelessWidget {
  final HighRiskReferralScreen widget;

  const _PredictionDataTable({required this.widget});

  @override
  Widget build(BuildContext context) {
    final rows = [
      _DataRow('Age',               '${widget.age} years'),
      _DataRow('Systolic BP',       '${widget.systolicBP} mmHg'),
      _DataRow('Diastolic BP',      '${widget.diastolicBP} mmHg'),
      _DataRow('Blood Sugar',       '${widget.bloodSugar} mmol/L'),
      _DataRow('Body Temperature',  '${widget.bodyTemp} °C'),
      _DataRow('Heart Rate',        '${widget.heartRate} bpm'),
      _DataRow('Prediction Date',
          widget.predictionDate.toString().split(' ')[0]),
    ];

    return Column(
      children: [
        // Risk level badge row
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Risk Level',
                  style: TextStyle(color: _gray, fontSize: 13)),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: _red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: _red.withOpacity(0.3), width: 1),
                ),
                child: Text(
                  widget.riskLevel,
                  style: const TextStyle(
                    color: _red,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(color: _cardBorder, height: 1),
        const SizedBox(height: 4),
        ...rows.map((r) => _ReadOnlyRow(label: r.label, value: r.value)),
      ],
    );
  }
}

class _DataRow {
  final String label;
  final String value;
  const _DataRow(this.label, this.value);
}

// ─────────────────────────────────────────────
//  READ-ONLY ROW
// ─────────────────────────────────────────────
class _ReadOnlyRow extends StatelessWidget {
  final String label;
  final String value;

  const _ReadOnlyRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(color: _gray, fontSize: 13)),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value.isEmpty ? '—' : value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: _navy,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  ROW DIVIDER
// ─────────────────────────────────────────────
class _RowDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      const Divider(color: Color(0xFFF0F3F2), height: 1);
}

// ─────────────────────────────────────────────
//  HOSPITAL LOADING
// ─────────────────────────────────────────────
class _HospitalLoading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
                color: _teal, strokeWidth: 2.5),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Calculating severity and selecting hospital…',
              style: TextStyle(color: _gray, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  HOSPITAL SELECTED
// ─────────────────────────────────────────────
class _HospitalSelected extends StatelessWidget {
  final String  hospital;
  final String? severityLevel;
  final int?    severityScore;
  final String? reasoning;

  const _HospitalSelected({
    required this.hospital,
    this.severityLevel,
    this.severityScore,
    this.reasoning,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hospital name row
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _tealLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.local_hospital_outlined,
                  color: _teal, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hospital,
                    style: const TextStyle(
                      color: _navy,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (severityLevel != null)
                    Text(
                      'Severity: $severityLevel',
                      style: const TextStyle(
                          color: _gray, fontSize: 12),
                    ),
                ],
              ),
            ),
          ],
        ),

        // Severity score
        if (severityScore != null) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _bgPage,
              borderRadius: BorderRadius.circular(10),
              border:
                  Border.all(color: _cardBorder, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('Severity Score',
                        style: TextStyle(
                            color: _gray, fontSize: 12)),
                    const Spacer(),
                    Text(
                      '$severityScore / 7',
                      style: const TextStyle(
                        color: _navy,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                // Score bar
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (severityScore! / 7).clamp(0.0, 1.0),
                    backgroundColor: _cardBorder,
                    valueColor: AlwaysStoppedAnimation(
                      severityScore! >= 5
                          ? _red
                          : severityScore! >= 3
                              ? _amber
                              : _teal,
                    ),
                    minHeight: 6,
                  ),
                ),
                if (reasoning != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    reasoning!,
                    style: const TextStyle(
                        color: _gray, fontSize: 12, height: 1.4),
                  ),
                ],
              ],
            ),
          ),
        ],

        // Lock notice
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: _amber.withOpacity(0.07),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: _amber.withOpacity(0.25), width: 1),
          ),
          child: Row(
            children: const [
              Icon(Icons.lock_outline, size: 14, color: _amber),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Hospital automatically selected based on severity score. Cannot be changed.',
                  style: TextStyle(
                      fontSize: 12, color: _amber, height: 1.4),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  HOSPITAL ERROR
// ─────────────────────────────────────────────
class _HospitalError extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _red.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _red.withOpacity(0.25), width: 1),
      ),
      child: Row(
        children: const [
          Icon(Icons.error_outline, color: _red, size: 18),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Unable to determine hospital. Please try again.',
              style: TextStyle(color: _red, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}