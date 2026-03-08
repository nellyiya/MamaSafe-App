import 'package:flutter/material.dart';
import '../../../models/mother_model.dart';
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
const _inputFill = Color(0xFFF9FAFA);
const _inputBorder = Color(0xFFD1D9D7);
const _red = Color(0xFFDC2626);
const _amber = Color(0xFFD97706);

class CreateReferralScreen extends StatefulWidget {
  final MotherModel mother;

  const CreateReferralScreen({Key? key, required this.mother})
      : super(key: key);

  @override
  State<CreateReferralScreen> createState() => _CreateReferralScreenState();
}

class _CreateReferralScreenState extends State<CreateReferralScreen> {
  final _formKey = GlobalKey<FormState>();
  final _hospitalController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isLoading = false;

  final List<String> _hospitals = [
    'King Faisal Hospital Rwanda',
    'Kibagabaga Level II Teaching Hospital',
    'Kacyiru District Hospital',
  ];

  @override
  void dispose() {
    _hospitalController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // ── Logic (UNCHANGED) ─────────────────────────────────────────────────────
  Future<void> _createReferral() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final apiService = ApiService();
      await apiService.createReferral({
        'mother_id': int.parse(widget.mother.id),
        'hospital': _hospitalController.text,
        'notes': _notesController.text,
      });
      if (mounted) {
        _showSnack('Referral created successfully');
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ── Risk helpers ───────────────────────────────────────────────────────────
  Color _riskColor() {
    switch (widget.mother.riskLevel) {
      case 'High':
        return _red;
      case 'Medium':
      case 'Mid':
        return _amber;
      default:
        return _teal;
    }
  }

  // ── BUILD ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isHighRisk = widget.mother.riskLevel == 'High';
    final riskColor = _riskColor();

    return Scaffold(
      backgroundColor: _bgPage,
      appBar: AppBar(
        title: const Text(
          'Create Referral',
          style: TextStyle(
              color: _white, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        backgroundColor: _teal,
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
              // ── Patient info card ──────────────────────────────────────────
              _SectionCard(
                title: 'Patient Information',
                icon: Icons.person_outline,
                child: Column(
                  children: [
                    // Avatar + name row
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: _tealLight,
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: Center(
                            child: Text(
                              widget.mother.fullName
                                  .trim()
                                  .split(' ')
                                  .map((w) => w.isNotEmpty ? w[0] : '')
                                  .take(2)
                                  .join()
                                  .toUpperCase(),
                              style: const TextStyle(
                                color: _teal,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.mother.fullName,
                                style: const TextStyle(
                                  color: _navy,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Text(
                                    'Risk: ',
                                    style:
                                        TextStyle(color: _gray, fontSize: 12),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: riskColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                          color: riskColor.withOpacity(0.3),
                                          width: 1),
                                    ),
                                    child: Text(
                                      widget.mother.riskLevel,
                                      style: TextStyle(
                                        color: riskColor,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
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

                    // High-risk warning
                    if (isHighRisk) ...[
                      const SizedBox(height: 14),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _red.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: _red.withOpacity(0.25), width: 1),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.warning_amber_outlined,
                                color: _red, size: 16),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'High risk — immediate referral required.',
                                style: TextStyle(
                                    color: _red,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // ── Hospital selection card ────────────────────────────────────
              _SectionCard(
                title: 'Select Hospital',
                icon: Icons.local_hospital_outlined,
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.local_hospital_outlined,
                        color: _teal, size: 20),
                    hintText: 'Choose a hospital',
                    hintStyle: const TextStyle(color: _gray, fontSize: 14),
                    filled: true,
                    fillColor: _inputFill,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 14),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(11),
                      borderSide:
                          const BorderSide(color: _inputBorder, width: 1.2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(11),
                      borderSide: const BorderSide(color: _teal, width: 1.8),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(11),
                      borderSide: const BorderSide(color: _red, width: 1.2),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(11),
                      borderSide: const BorderSide(color: _red, width: 1.8),
                    ),
                  ),
                  icon: const Icon(Icons.keyboard_arrow_down, color: _teal),
                  dropdownColor: _white,
                  style: const TextStyle(color: _navy, fontSize: 14),
                  items: _hospitals
                      .map((h) => DropdownMenuItem(
                            value: h,
                            child: Text(h),
                          ))
                      .toList(),
                  onChanged: (value) => _hospitalController.text = value ?? '',
                  validator: (value) =>
                      value == null ? 'Please select a hospital' : null,
                ),
              ),
              const SizedBox(height: 14),

              // ── Referral notes card ────────────────────────────────────────
              _SectionCard(
                title: 'Referral Notes',
                icon: Icons.edit_note_outlined,
                child: TextFormField(
                  controller: _notesController,
                  maxLines: 5,
                  style: const TextStyle(color: _navy, fontSize: 14),
                  decoration: InputDecoration(
                    hintText:
                        'Enter reason for referral and any important notes…',
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
                      borderSide: const BorderSide(color: _teal, width: 1.8),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(11),
                      borderSide: const BorderSide(color: _red, width: 1.2),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(11),
                      borderSide: const BorderSide(color: _red, width: 1.8),
                    ),
                  ),
                  validator: (value) =>
                      (value?.isEmpty ?? true) ? 'Please enter notes' : null,
                ),
              ),

              const SizedBox(height: 28),

              // ── Submit button ──────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _createReferral,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: _white, strokeWidth: 2.5),
                        )
                      : const Icon(Icons.send_outlined, size: 20),
                  label: Text(
                    _isLoading ? 'Submitting…' : 'Create Referral',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _teal,
                    foregroundColor: _white,
                    disabledBackgroundColor: _teal.withOpacity(0.5),
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
//  SECTION CARD
// ─────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({
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
