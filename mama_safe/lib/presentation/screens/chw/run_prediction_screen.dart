import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/app_colors.dart';
import '../../../providers/language_provider.dart';
import '../../../providers/mother_provider.dart';
import '../../../services/prediction_service.dart';
import '../../../services/api_service.dart';
import 'high_risk_referral_screen.dart';

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

/// Run Prediction Screen
class RunPredictionScreen extends StatefulWidget {
  final String? motherId;

  const RunPredictionScreen({super.key, this.motherId});

  @override
  State<RunPredictionScreen> createState() => _RunPredictionScreenState();
}

class _RunPredictionScreenState extends State<RunPredictionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ageController = TextEditingController();
  final _systolicBPController = TextEditingController();
  final _diastolicBPController = TextEditingController();
  final _bloodSugarController = TextEditingController();
  final _bodyTempController = TextEditingController();
  final _heartRateController = TextEditingController();

  bool _isLoading = false;
  String? _predictionResult;
  String? _riskExplanation;
  List<String> _recommendedActions = [];

  final PredictionService _predictionService = PredictionService();

  @override
  void initState() {
    super.initState();
    if (widget.motherId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final mother =
            context.read<MotherProvider>().getMotherById(widget.motherId!);
        if (mother != null) _ageController.text = mother.age.toString();
      });
    }
  }

  @override
  void dispose() {
    _ageController.dispose();
    _systolicBPController.dispose();
    _diastolicBPController.dispose();
    _bloodSugarController.dispose();
    _bodyTempController.dispose();
    _heartRateController.dispose();
    super.dispose();
  }

  // ── Prediction logic (UNCHANGED) ──────────────────────────────────────────
  Future<void> _runPrediction() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _predictionResult = null;
      _riskExplanation = null;
      _recommendedActions = [];
    });

    try {
      final age = int.parse(_ageController.text);
      final systolicBP = int.parse(_systolicBPController.text);
      final diastolicBP = int.parse(_diastolicBPController.text);
      final bloodSugar = double.parse(_bloodSugarController.text);
      final bodyTemp = double.parse(_bodyTempController.text);
      final heartRate = int.parse(_heartRateController.text);

      final result = await _predictionService.predictRisk(
        age: age,
        systolicBP: systolicBP,
        diastolicBP: diastolicBP,
        bloodSugar: bloodSugar,
        bodyTemp: bodyTemp,
        heartRate: heartRate,
      );

      final explanation = _predictionService.getRiskExplanation(
        age: age,
        systolicBP: systolicBP,
        diastolicBP: diastolicBP,
        bloodSugar: bloodSugar,
        bodyTemp: bodyTemp,
        heartRate: heartRate,
      );

      final actions = _predictionService.getRecommendedActions(result);

      setState(() {
        _predictionResult = result;
        _riskExplanation = explanation;
        _recommendedActions = actions;
      });

      if (widget.motherId != null) {
        final motherProvider = context.read<MotherProvider>();
        final mother = motherProvider.getMotherById(widget.motherId!);

        if (mother != null) {
          try {
            final apiService = ApiService();
            await apiService.createHealthRecord({
              'mother_id': int.parse(widget.motherId!),
              'age': age,
              'systolic_bp': systolicBP,
              'diastolic_bp': diastolicBP,
              'blood_sugar': bloodSugar,
              'body_temp': bodyTemp,
              'heart_rate': heartRate,
              'risk_level': result,
            });
          } catch (e) {
            print('Failed to save health record: $e');
          }

          await motherProvider.updateRiskLevel(
            widget.motherId!,
            result,
            systolicBP: systolicBP,
            diastolicBP: diastolicBP,
            bloodSugar: bloodSugar,
            bodyTemp: bodyTemp,
            heartRate: heartRate,
          );

          if (result == 'High') {
            if (mounted) {
              final shouldRefer = await _showHighRiskDialog();

              if (shouldRefer == true && mounted) {
                final referralCreated = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HighRiskReferralScreen(
                      motherId: widget.motherId,
                      age: age,
                      systolicBP: systolicBP,
                      diastolicBP: diastolicBP,
                      bloodSugar: bloodSugar,
                      bodyTemp: bodyTemp,
                      heartRate: heartRate,
                      riskLevel: result,
                      predictionDate: DateTime.now(),
                    ),
                  ),
                );

                if (referralCreated == true && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          const Text('High risk referral created successfully'),
                      backgroundColor: _teal,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      duration: const Duration(seconds: 3),
                    ),
                  );
                  Navigator.pop(context);
                }
              }
            }
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: _red,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── High Risk Dialog ───────────────────────────────────────────────────────
  Future<bool?> _showHighRiskDialog() {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: _white,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.warning_amber_rounded,
                        color: _red, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'High Risk Detected',
                      style: TextStyle(
                        color: _red,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'This patient has been identified as HIGH RISK.',
                style: TextStyle(
                  color: _navy,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Immediate referral to a healthcare professional is mandatory.',
                style: TextStyle(color: _gray, fontSize: 13, height: 1.5),
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _red.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _red.withOpacity(0.2), width: 1),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.local_hospital_outlined, color: _red, size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'You will now create a referral with auto-filled prediction data.',
                        style: TextStyle(color: _red, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context, true),
                  icon: const Icon(Icons.send, size: 18),
                  label: const Text('Make Referral Now'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _red,
                    foregroundColor: _white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Referral Dialog (UNCHANGED logic) ─────────────────────────────────────
  Future<void> _showReferralDialog(bool isEnglish) async {
    if (widget.motherId == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: _white,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isEnglish ? 'Make Referral' : 'Fata Referral',
                style: const TextStyle(
                    color: _navy, fontSize: 17, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                isEnglish
                    ? 'This mother has been identified as High Risk. Would you like to refer them to the hospital?'
                    : 'Mama iyi yabajwe nk\'ifite ibibazo biri hejuru. Washaka kumwoherereza kw\'isbyatros?',
                style: const TextStyle(color: _gray, fontSize: 13, height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _gray,
                        side: const BorderSide(color: _cardBorder),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(isEnglish ? 'Cancel' : 'Hagarika'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _red,
                        foregroundColor: _white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(isEnglish ? 'Confirm' : 'Emeza'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true && mounted) {
      final motherProvider = context.read<MotherProvider>();
      final success = await motherProvider.makeReferral(widget.motherId!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? (isEnglish
                      ? 'Referral made successfully!'
                      : 'Referral yagenze neza!')
                  : (isEnglish
                      ? 'Failed to make referral'
                      : 'Referral ntigenze neza'),
            ),
            backgroundColor: success ? _teal : _red,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        if (success) Navigator.pop(context);
      }
    }
  }

  // ── BUILD ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    final isEnglish = languageProvider.isEnglish;

    return Scaffold(
      backgroundColor: _bgPage,
      appBar: AppBar(
        title: Text(
          isEnglish ? 'Run Prediction' : 'Fata Ibitekerezo',
          style: const TextStyle(
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
              // ── Intro card ─────────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _tealLight,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _teal.withOpacity(0.2), width: 1),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: _teal,
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: const Icon(Icons.biotech_outlined,
                          color: _white, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isEnglish
                                ? 'Health Parameters'
                                : 'Ibikubiyemo n\'ubuzima',
                            style: const TextStyle(
                              color: _navy,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            isEnglish
                                ? 'Enter values to predict maternal risk level'
                                : 'Fura amakuru y\'ubuzima ngo ubone urushinge',
                            style: const TextStyle(
                                color: _gray, fontSize: 12, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Form card ──────────────────────────────────────────────────
              _FormCard(
                title: isEnglish ? 'Patient Info' : 'Amakuru y\'umurwayi',
                icon: Icons.person_outline,
                children: [
                  _Field(
                    controller: _ageController,
                    label: isEnglish ? 'Age' : 'Imyaka',
                    hint: isEnglish ? 'e.g. 28' : 'urugero: 28',
                    icon: Icons.cake_outlined,
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.isEmpty)
                        return isEnglish ? 'Please enter age' : 'Andika imyaka';
                      final age = int.tryParse(v);
                      if (age == null || age < 10 || age > 60)
                        return isEnglish
                            ? 'Valid age: 10–60'
                            : 'Imyaka nyakuri: 10–60';
                      return null;
                    },
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Blood pressure
              _FormCard(
                title: isEnglish ? 'Blood Pressure' : 'Umuvuduko w\'amaraso',
                icon: Icons.favorite_border,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _Field(
                          controller: _systolicBPController,
                          label: isEnglish ? 'Systolic' : 'BP igaragara',
                          hint: '120',
                          icon: Icons.arrow_upward,
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            if (v == null || v.isEmpty)
                              return isEnglish ? 'Required' : 'Ikenewe';
                            final bp = int.tryParse(v);
                            if (bp == null || bp < 50 || bp > 250)
                              return isEnglish ? 'Invalid' : 'Ntibyifashe';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _Field(
                          controller: _diastolicBPController,
                          label: isEnglish ? 'Diastolic' : 'BP ikigabo',
                          hint: '80',
                          icon: Icons.arrow_downward,
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            if (v == null || v.isEmpty)
                              return isEnglish ? 'Required' : 'Ikenewe';
                            final bp = int.tryParse(v);
                            if (bp == null || bp < 30 || bp > 150)
                              return isEnglish ? 'Invalid' : 'Ntibyifashe';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Vitals
              _FormCard(
                title: isEnglish ? 'Vitals' : 'Ibipimo by\'ubuzima',
                icon: Icons.monitor_heart_outlined,
                children: [
                  _Field(
                    controller: _bloodSugarController,
                    label: isEnglish
                        ? 'Blood Sugar (mmol/L)'
                        : 'Shugar inzuku (mmol/L)',
                    hint: 'e.g. 5.5',
                    icon: Icons.water_drop_outlined,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) {
                      if (v == null || v.isEmpty)
                        return isEnglish
                            ? 'Please enter blood sugar'
                            : 'Andika shugar';
                      final bs = double.tryParse(v);
                      if (bs == null || bs < 1.0 || bs > 30.0)
                        return isEnglish
                            ? 'Valid range: 1–30'
                            : 'Ikigero: 1–30';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  _Field(
                    controller: _bodyTempController,
                    label:
                        isEnglish ? 'Body Temperature (°C)' : 'Igipfungo (°C)',
                    hint: 'e.g. 37.0',
                    icon: Icons.thermostat_outlined,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) {
                      if (v == null || v.isEmpty)
                        return isEnglish
                            ? 'Please enter temperature'
                            : 'Andika igipfungo';
                      final temp = double.tryParse(v);
                      if (temp == null || temp < 30.0 || temp > 45.0)
                        return isEnglish
                            ? 'Valid range: 30–45'
                            : 'Ikigero: 30–45';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  _Field(
                    controller: _heartRateController,
                    label: isEnglish
                        ? 'Heart Rate (bpm)'
                        : 'Igipimo cya mutima (bpm)',
                    hint: 'e.g. 72',
                    icon: Icons.monitor_heart_outlined,
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.isEmpty)
                        return isEnglish
                            ? 'Please enter heart rate'
                            : 'Andika igipimo';
                      final hr = int.tryParse(v);
                      if (hr == null || hr < 30 || hr > 200)
                        return isEnglish
                            ? 'Valid range: 30–200'
                            : 'Ikigero: 30–200';
                      return null;
                    },
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // ── Submit button ──────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _runPrediction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _teal,
                    foregroundColor: _white,
                    disabledBackgroundColor: _teal.withOpacity(0.5),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              color: _white, strokeWidth: 2.5),
                        )
                      : Text(
                          isEnglish ? 'Run Prediction' : 'Fata Ibitekerezo',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                ),
              ),

              // ── Results section ────────────────────────────────────────────
              if (_predictionResult != null) ...[
                const SizedBox(height: 32),
                _buildResultsSection(isEnglish),
              ],

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ── Results section ────────────────────────────────────────────────────────
  Widget _buildResultsSection(bool isEnglish) {
    Color resultColor;
    IconData resultIcon;

    switch (_predictionResult) {
      case 'High':
        resultColor = _red;
        resultIcon = Icons.warning_amber_rounded;
        break;
      case 'Mid':
      case 'Medium':
        resultColor = _amber;
        resultIcon = Icons.info_outline;
        break;
      default:
        resultColor = _teal;
        resultIcon = Icons.check_circle_outline;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Divider with label ───────────────────────────────────────────────
        Row(
          children: [
            const Expanded(child: Divider(color: _cardBorder)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                isEnglish ? 'Prediction Result' : 'Igisubizo',
                style: const TextStyle(
                    color: _gray, fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ),
            const Expanded(child: Divider(color: _cardBorder)),
          ],
        ),
        const SizedBox(height: 16),

        // ── Result card ──────────────────────────────────────────────────────
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: resultColor.withOpacity(0.07),
            borderRadius: BorderRadius.circular(16),
            border:
                Border.all(color: resultColor.withOpacity(0.25), width: 1.5),
          ),
          child: Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: resultColor.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(resultIcon, color: resultColor, size: 34),
              ),
              const SizedBox(height: 12),
              Text(
                isEnglish ? 'Risk Level' : 'Ikirenge ry\'ibibazo',
                style: const TextStyle(color: _gray, fontSize: 13),
              ),
              const SizedBox(height: 4),
              Text(
                _predictionResult!,
                style: TextStyle(
                  color: resultColor,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_riskExplanation != null) ...[
                const SizedBox(height: 10),
                Text(
                  _riskExplanation!,
                  textAlign: TextAlign.center,
                  style:
                      const TextStyle(color: _gray, fontSize: 13, height: 1.5),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 20),

        // ── Recommended actions ──────────────────────────────────────────────
        const _SectionLabel(label: 'Recommended Actions'),
        const SizedBox(height: 12),
        ..._recommendedActions.map(
          (action) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: _white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _cardBorder, width: 1.2),
            ),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: _tealLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child:
                      const Icon(Icons.arrow_forward, color: _teal, size: 15),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    action,
                    style: const TextStyle(
                        color: _navy, fontSize: 13, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        // ── Disclaimer ───────────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _gray.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _cardBorder, width: 1.2),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, color: _gray, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Disclaimer: This risk assessment is generated by the MamaSafe system based on the provided health data. It is intended for monitoring purposes only and does not replace professional medical advice, diagnosis, or treatment. Always consult a qualified healthcare professional for medical decisions.',
                  style: TextStyle(color: _gray, fontSize: 11.5, height: 1.5),
                ),
              ),
            ],
          ),
        ),

        // ── High risk referral banner ────────────────────────────────────────
        if (_predictionResult == 'High') ...[
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: _red.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _red.withOpacity(0.3), width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: _red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.warning_amber_rounded,
                          color: _red, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'High Risk — Referral Required',
                        style: TextStyle(
                          color: _red,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'Immediate referral to a healthcare professional is required.',
                  style: TextStyle(color: _gray, fontSize: 13, height: 1.5),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final age = int.parse(_ageController.text);
                      final systolicBP = int.parse(_systolicBPController.text);
                      final diastolicBP =
                          int.parse(_diastolicBPController.text);
                      final bloodSugar =
                          double.parse(_bloodSugarController.text);
                      final bodyTemp = double.parse(_bodyTempController.text);
                      final heartRate = int.parse(_heartRateController.text);

                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HighRiskReferralScreen(
                            motherId: widget.motherId,
                            age: age,
                            systolicBP: systolicBP,
                            diastolicBP: diastolicBP,
                            bloodSugar: bloodSugar,
                            bodyTemp: bodyTemp,
                            heartRate: heartRate,
                            riskLevel: _predictionResult!,
                            predictionDate: DateTime.now(),
                          ),
                        ),
                      );

                      if (result == true && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                const Text('Referral created successfully'),
                            backgroundColor: _teal,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        );
                        Navigator.pop(context);
                      }
                    },
                    icon: const Icon(Icons.send_outlined, size: 18),
                    label: Text(isEnglish ? 'Make Referral' : 'Fata Referral'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _red,
                      foregroundColor: _white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  FORM CARD WRAPPER
// ─────────────────────────────────────────────
class _FormCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _FormCard({
    required this.title,
    required this.icon,
    required this.children,
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
          ...children,
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  FIELD
// ─────────────────────────────────────────────
class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _Field({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: _navy, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: _gray, fontSize: 13),
        hintStyle: const TextStyle(color: _cardBorder, fontSize: 13),
        prefixIcon: Icon(icon, color: _teal, size: 19),
        filled: true,
        fillColor: _inputFill,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(color: _inputBorder, width: 1.2),
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
    return Text(
      label,
      style: const TextStyle(
        color: _navy,
        fontSize: 15,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
      ),
    );
  }
}
