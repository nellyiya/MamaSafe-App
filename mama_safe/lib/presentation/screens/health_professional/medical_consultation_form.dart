import 'package:flutter/material.dart';
import '../../../core/app_colors.dart';
import '../../../services/api_service.dart';

// ─────────────────────────────────────────────
//  DESIGN TOKENS
// ─────────────────────────────────────────────
const _teal = Color(0xFF1A7A6E);
const _navy = Color(0xFF1E2D4E);
const _white = Color(0xFFFFFFFF);
const _bgPage = Color(0xFFF0F4F3);
const _gray = Color(0xFF6B7280);
const _border = Color(0xFFDDE3E2);

class MedicalConsultationForm extends StatefulWidget {
  final int referralId;
  final Map<String, dynamic> referralData;

  const MedicalConsultationForm({
    super.key,
    required this.referralId,
    required this.referralData,
  });

  @override
  State<MedicalConsultationForm> createState() =>
      _MedicalConsultationFormState();
}

class _MedicalConsultationFormState extends State<MedicalConsultationForm> {
  final _formKey = GlobalKey<FormState>();
  final _complaintsController = TextEditingController();
  final _bpController = TextEditingController();
  final _sugarController = TextEditingController();
  final _tempController = TextEditingController();
  final _hrController = TextEditingController();
  final _fetalHrController = TextEditingController();
  final _examinationController = TextEditingController();
  final _diagnosisController = TextEditingController();
  final _treatmentController = TextEditingController();
  final _followUpController = TextEditingController();
  final _doctorNameController = TextEditingController();

  final _investigations = <String>[];
  String? _selectedOutcome;
  bool _confirmationChecked = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final riskLevel = widget.referralData['mother']?['risk_level'] ?? 'High';
    final severity = widget.referralData['severity'] ?? 'Unknown';
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 40,
        vertical: isMobile ? 16 : 24,
      ),
      child: Container(
        width: isMobile ? double.infinity : 900,
        decoration: BoxDecoration(
          color: _bgPage,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            _buildHeader(riskLevel, isMobile),
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(isMobile ? 16 : 24),
                  child: Column(
                    children: [
                      _buildHospitalDetailsCard(isMobile),
                      const SizedBox(height: 14),
                      _buildPatientInfoCard(isMobile),
                      const SizedBox(height: 14),
                      _buildReferralSummaryCard(riskLevel, severity, isMobile),
                      const SizedBox(height: 14),
                      _buildClinicalConsultationCard(isMobile),
                      const SizedBox(height: 14),
                      _buildFollowUpCard(isMobile),
                      const SizedBox(height: 14),
                      _buildDoctorConfirmationCard(isMobile),
                    ],
                  ),
                ),
              ),
            ),
            _buildActionBar(isMobile),
          ],
        ),
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────
  Widget _buildHeader(String riskLevel, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 24,
        vertical: isMobile ? 14 : 18,
      ),
      decoration: const BoxDecoration(
        color: _teal,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.medical_services_outlined,
              color: _white,
              size: isMobile ? 20 : 22,
            ),
          ),
          SizedBox(width: isMobile ? 10 : 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Medical Consultation Form',
                  style: TextStyle(
                    color: _white,
                    fontSize: isMobile ? 15 : 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
                Text(
                  'Referral Review & Clinical Documentation',
                  style: TextStyle(
                    color: _white.withOpacity(0.80),
                    fontSize: isMobile ? 11 : 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Badge ────────────────────────────────────────────────────
  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  // ── Generic section card ─────────────────────────────────────
  Widget _buildCard(
      String title, IconData icon, List<Widget> children, bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: _navy,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, color: _white, size: 16),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  color: _navy,
                  fontSize: isMobile ? 13 : 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.1,
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 14 : 16),
          Container(height: 1, color: _border),
          SizedBox(height: isMobile ? 14 : 16),
          ...children,
        ],
      ),
    );
  }

  // ── Hospital Details ─────────────────────────────────────────
  Widget _buildHospitalDetailsCard(bool isMobile) {
    final now = DateTime.now();
    return _buildCard(
        '1. Hospital Details',
        Icons.local_hospital_rounded,
        [
          if (isMobile)
            Column(children: [
              _buildReadOnlyField(
                  'Hospital Name', widget.referralData['hospital'] ?? 'N/A'),
              const SizedBox(height: 12),
              _buildReadOnlyField('Department', 'Obstetrics & Gynecology'),
              const SizedBox(height: 12),
              _buildReadOnlyField('Date',
                  '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}'),
              const SizedBox(height: 12),
              _buildReadOnlyField('Time',
                  '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}'),
            ])
          else
            Column(children: [
              Row(children: [
                Expanded(
                    child: _buildReadOnlyField('Hospital Name',
                        widget.referralData['hospital'] ?? 'N/A')),
                const SizedBox(width: 16),
                Expanded(
                    child: _buildReadOnlyField(
                        'Department', 'Obstetrics & Gynecology')),
              ]),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(
                    child: _buildReadOnlyField('Date',
                        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}')),
                const SizedBox(width: 16),
                Expanded(
                    child: _buildReadOnlyField('Time',
                        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}')),
              ]),
            ]),
        ],
        isMobile);
  }

  // ── Patient Info ─────────────────────────────────────────────
  Widget _buildPatientInfoCard(bool isMobile) {
    return _buildCard(
        '2. Patient Information',
        Icons.person_outline_rounded,
        [
          if (isMobile)
            Column(children: [
              Row(children: [
                Icon(Icons.person_outline_rounded, size: 16, color: _teal),
                const SizedBox(width: 8),
                Expanded(
                    child: _buildReadOnlyField('Full Name',
                        widget.referralData['mother']?['name'] ?? 'N/A')),
              ]),
              const SizedBox(height: 12),
              _buildReadOnlyField('Age',
                  widget.referralData['mother']?['age']?.toString() ?? 'N/A'),
              const SizedBox(height: 12),
              _buildReadOnlyField(
                  'Phone', widget.referralData['mother']?['phone'] ?? 'N/A'),
              const SizedBox(height: 12),
              _buildReadOnlyField(
                'Address',
                '${widget.referralData['mother']?['sector']}, ${widget.referralData['mother']?['cell']}, ${widget.referralData['mother']?['village']}',
              ),
            ])
          else
            Column(children: [
              Row(children: [
                Icon(Icons.person_outline_rounded, size: 18, color: _teal),
                const SizedBox(width: 8),
                Expanded(
                    child: _buildReadOnlyField('Full Name',
                        widget.referralData['mother']?['name'] ?? 'N/A')),
                const SizedBox(width: 16),
                Expanded(
                    child: _buildReadOnlyField(
                        'Age',
                        widget.referralData['mother']?['age']?.toString() ??
                            'N/A')),
              ]),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(
                    child: _buildReadOnlyField('Phone',
                        widget.referralData['mother']?['phone'] ?? 'N/A')),
                const SizedBox(width: 16),
                Expanded(
                    child: _buildReadOnlyField(
                  'Address',
                  '${widget.referralData['mother']?['sector']}, ${widget.referralData['mother']?['cell']}, ${widget.referralData['mother']?['village']}',
                )),
              ]),
            ]),
        ],
        isMobile);
  }

  // ── Referral Summary ─────────────────────────────────────────
  Widget _buildReferralSummaryCard(
      String riskLevel, String severity, bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFECACA)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFDC2626),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(Icons.warning_amber_rounded,
                    color: _white, size: 16),
              ),
              const SizedBox(width: 10),
              Text(
                '3. Referral Summary',
                style: TextStyle(
                  color: const Color(0xFF991B1B),
                  fontSize: isMobile ? 13 : 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 14 : 16),
          Container(height: 1, color: const Color(0xFFFECACA)),
          SizedBox(height: isMobile ? 12 : 14),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text('Risk Level:',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: isMobile ? 12 : 13,
                      color: _navy)),
              _buildBadge(riskLevel, const Color(0xFFDC2626)),
              const SizedBox(width: 4),
              Text('Severity:',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: isMobile ? 12 : 13,
                      color: _navy)),
              _buildBadge(
                severity,
                severity.toLowerCase() == 'critical'
                    ? const Color(0xFF991B1B)
                    : const Color(0xFFF59E0B),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 12 : 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFFECACA)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Referral Reason:',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: isMobile ? 12 : 13,
                    color: _navy,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.referralData['notes'] ?? 'N/A',
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 13,
                    height: 1.55,
                    color: _gray,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Clinical Consultation ────────────────────────────────────
  Widget _buildClinicalConsultationCard(bool isMobile) {
    return _buildCard(
        '4. Clinical Consultation',
        Icons.medical_services_outlined,
        [
          _subLabel('A. Presenting Complaints', isMobile),
          const SizedBox(height: 8),
          _buildTextField(
              _complaintsController, 'Describe patient complaints...',
              maxLines: 3, required: true),
          const SizedBox(height: 16),
          _subLabel('B. Vital Signs at Hospital', isMobile),
          const SizedBox(height: 8),
          if (isMobile)
            Column(children: [
              _buildTextField(_bpController, 'e.g., 120/80',
                  label: 'Blood Pressure'),
              const SizedBox(height: 12),
              _buildTextField(_sugarController, 'mmol/L', label: 'Blood Sugar'),
              const SizedBox(height: 12),
              _buildTextField(_tempController, '°C', label: 'Temperature'),
              const SizedBox(height: 12),
              _buildTextField(_hrController, 'bpm', label: 'Heart Rate'),
              const SizedBox(height: 12),
              _buildTextField(_fetalHrController, 'bpm',
                  label: 'Fetal Heart Rate'),
            ])
          else
            Column(children: [
              Row(children: [
                Expanded(
                    child: _buildTextField(_bpController, 'e.g., 120/80',
                        label: 'Blood Pressure')),
                const SizedBox(width: 16),
                Expanded(
                    child: _buildTextField(_sugarController, 'mmol/L',
                        label: 'Blood Sugar')),
                const SizedBox(width: 16),
                Expanded(
                    child: _buildTextField(_tempController, '°C',
                        label: 'Temperature')),
              ]),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(
                    child: _buildTextField(_hrController, 'bpm',
                        label: 'Heart Rate')),
                const SizedBox(width: 16),
                Expanded(
                    child: _buildTextField(_fetalHrController, 'bpm',
                        label: 'Fetal Heart Rate')),
                Expanded(child: const SizedBox()),
              ]),
            ]),
          const SizedBox(height: 16),
          _subLabel('C. Examination Findings', isMobile),
          const SizedBox(height: 8),
          _buildTextField(
              _examinationController, 'Physical examination findings...',
              maxLines: 3, required: true),
          const SizedBox(height: 16),
          _subLabel('D. Investigations Ordered', isMobile),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              'Ultrasound',
              'Urine Test',
              'Blood Test',
              'CTG Monitoring',
              'Other'
            ].map((inv) {
              final selected = _investigations.contains(inv);
              return FilterChip(
                label: Text(inv,
                    style: TextStyle(
                      fontSize: isMobile ? 10 : 12,
                      color: selected ? _teal : _gray,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                    )),
                selected: selected,
                onSelected: (s) {
                  setState(() {
                    if (s)
                      _investigations.add(inv);
                    else
                      _investigations.remove(inv);
                  });
                },
                selectedColor: _teal.withOpacity(0.12),
                checkmarkColor: _teal,
                backgroundColor: _bgPage,
                side: BorderSide(color: selected ? _teal : _border),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          _subLabel('E. Final Diagnosis', isMobile),
          const SizedBox(height: 8),
          _buildTextField(_diagnosisController, 'Enter diagnosis...',
              maxLines: 2, required: true),
          const SizedBox(height: 16),
          _subLabel('F. Treatment / Management Provided', isMobile),
          const SizedBox(height: 8),
          _buildTextField(
              _treatmentController, 'Describe treatment provided...',
              maxLines: 3, required: true),
          const SizedBox(height: 16),
          _subLabel('G. Outcome / Disposition', isMobile),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _selectedOutcome,
            decoration: InputDecoration(
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
              filled: true,
              fillColor: _bgPage,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              hintText: 'Select outcome',
              hintStyle: const TextStyle(color: _gray, fontSize: 13),
            ),
            style: TextStyle(fontSize: isMobile ? 12 : 13, color: _navy),
            items: [
              'Patient Stable – Routine Follow-up',
              'Admitted for Monitoring',
              'Emergency Managed',
              'Referred to Higher-Level Facility',
              'Delivery Conducted',
              'Other',
            ]
                .map((o) => DropdownMenuItem(
                      value: o,
                      child: Text(o,
                          style: TextStyle(
                              fontSize: isMobile ? 12 : 13, color: _navy)),
                    ))
                .toList(),
            onChanged: (v) => setState(() => _selectedOutcome = v),
            validator: (v) => v == null ? 'Required' : null,
          ),
        ],
        isMobile);
  }

  // ── Follow-Up ────────────────────────────────────────────────
  Widget _buildFollowUpCard(bool isMobile) {
    return _buildCard(
        '5. Follow-Up Instructions',
        Icons.event_note_rounded,
        [
          _buildTextField(
              _followUpController, 'Instructions given to patient...',
              maxLines: 3, required: true),
        ],
        isMobile);
  }

  // ── Doctor Confirmation ──────────────────────────────────────
  Widget _buildDoctorConfirmationCard(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _teal.withOpacity(0.30), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: _teal,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(Icons.verified_user_outlined,
                    color: _white, size: 16),
              ),
              const SizedBox(width: 10),
              Text(
                '6. Doctor Confirmation',
                style: TextStyle(
                  color: _navy,
                  fontSize: isMobile ? 13 : 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 14 : 16),
          Container(height: 1, color: _border),
          SizedBox(height: isMobile ? 14 : 16),
          _buildTextField(
            _doctorNameController,
            'Enter doctor full name',
            label: 'Doctor Full Name',
            required: true,
          ),
          SizedBox(height: isMobile ? 12 : 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Transform.scale(
                scale: 1.1,
                child: Checkbox(
                  value: _confirmationChecked,
                  onChanged: (v) =>
                      setState(() => _confirmationChecked = v ?? false),
                  activeColor: _teal,
                  side: const BorderSide(color: _border, width: 1.5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4)),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 11),
                  child: Text(
                    'I confirm that I have personally examined and managed the above-named patient and the information provided is accurate.',
                    style: TextStyle(
                      fontSize: isMobile ? 11 : 12,
                      fontStyle: FontStyle.italic,
                      color: _gray,
                      height: 1.5,
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

  // ── Action Bar ───────────────────────────────────────────────
  Widget _buildActionBar(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
        border: Border(top: BorderSide(color: _border)),
      ),
      child: isMobile
          ? Column(children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _teal,
                    foregroundColor: _white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: _white, strokeWidth: 2),
                        )
                      : const Text('Submit & Complete',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed:
                      _isLoading ? null : () => Navigator.pop(context, false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _gray,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: _border, width: 1.3),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
            ])
          : Row(children: [
              OutlinedButton(
                onPressed:
                    _isLoading ? null : () => Navigator.pop(context, false),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _gray,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  side: const BorderSide(color: _border, width: 1.3),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Cancel'),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _teal,
                  foregroundColor: _white,
                  elevation: 0,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: _white, strokeWidth: 2),
                      )
                    : const Text('Submit & Complete',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ]),
    );
  }

  // ── Field helpers ────────────────────────────────────────────
  Widget _subLabel(String text, bool isMobile) => Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: isMobile ? 12 : 13,
          color: _navy,
        ),
      );

  Widget _buildReadOnlyField(String label, String value) {
    return TextFormField(
      initialValue: value,
      readOnly: true,
      style: const TextStyle(fontSize: 13, color: _navy),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: _gray, fontSize: 12),
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
          borderSide: const BorderSide(color: _border),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        filled: true,
        fillColor: _bgPage,
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    String? label,
    int maxLines = 1,
    bool required = false,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 13, color: _navy),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: _gray, fontSize: 12),
        hintText: hint,
        hintStyle: TextStyle(color: _gray.withOpacity(0.55), fontSize: 13),
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
        filled: true,
        fillColor: _bgPage,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      validator:
          required ? (v) => v == null || v.isEmpty ? 'Required' : null : null,
    );
  }

  // ── Submit logic (unchanged) ─────────────────────────────────
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_confirmationChecked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please confirm the examination'),
          backgroundColor: Color(0xFFDC2626),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final report = '''
MEDICAL CONSULTATION REPORT

1. HOSPITAL DETAILS
Hospital: ${widget.referralData['hospital']}
Department: Obstetrics & Gynecology
Date: ${DateTime.now().toString().split(' ')[0]}
Time: ${DateTime.now().toString().split(' ')[1].substring(0, 5)}

2. PATIENT INFORMATION
Name: ${widget.referralData['mother']?['name']}
Age: ${widget.referralData['mother']?['age']}
Phone: ${widget.referralData['mother']?['phone']}
Address: ${widget.referralData['mother']?['sector']}, ${widget.referralData['mother']?['cell']}, ${widget.referralData['mother']?['village']}

3. REFERRAL SUMMARY
Risk Level: ${widget.referralData['mother']?['risk_level']}
Severity: ${widget.referralData['severity']}
AI Reason: ${widget.referralData['notes']}

4. CLINICAL CONSULTATION
A. Presenting Complaints: ${_complaintsController.text}

B. Vital Signs:
- Blood Pressure: ${_bpController.text}
- Blood Sugar: ${_sugarController.text}
- Temperature: ${_tempController.text}
- Heart Rate: ${_hrController.text}
- Fetal Heart Rate: ${_fetalHrController.text}

C. Examination Findings: ${_examinationController.text}

D. Investigations: ${_investigations.join(', ')}

E. Final Diagnosis: ${_diagnosisController.text}

F. Treatment Provided: ${_treatmentController.text}

G. Outcome: $_selectedOutcome

5. FOLLOW-UP INSTRUCTIONS
${_followUpController.text}

6. DOCTOR CONFIRMATION
Doctor: ${_doctorNameController.text}
Date: ${DateTime.now()}
''';

      await ApiService().updateReferral(widget.referralId, {
        'status': 'Completed',
        'treatment_notes': report,
        'diagnosis': _diagnosisController.text,
      });

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed: $e'),
            backgroundColor: const Color(0xFFDC2626),
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
