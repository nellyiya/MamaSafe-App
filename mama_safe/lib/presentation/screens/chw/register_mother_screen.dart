import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/app_colors.dart';
import '../../../providers/language_provider.dart';
import '../../../services/api_service.dart';

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
const _readonlyFill = Color(0xFFF1F5F4);

class RegisterMotherScreen extends StatefulWidget {
  const RegisterMotherScreen({super.key});

  @override
  State<RegisterMotherScreen> createState() => _RegisterMotherScreenState();
}

class _RegisterMotherScreenState extends State<RegisterMotherScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _phoneController = TextEditingController();
  final _provinceController = TextEditingController(text: 'Kigali City');
  final _districtController = TextEditingController(text: 'Gasabo');
  final _sectorController = TextEditingController(text: 'Kimironko');

  String? _selectedCell;
  String? _selectedVillage;
  DateTime? _selectedDueDate;
  bool _isLoading = false;

  final List<String> _allCells = ['Kibagabaga', 'Bibare', 'Nyagatovu'];
  List<String> _availableVillages = [];

  final Map<String, List<String>> _cellVillages = {
    'Kibagabaga': [
      'Akintwari',
      'Buranga',
      'Gasharu',
      'Ibuhoro',
      'Kageyo',
      'Kamahinda',
      'Karisimbi',
      'Karongi',
      'Nyirabwana',
      'Ramiro',
      'Rindiro',
      'Rugero',
      'Rukurazo',
      'Urumuri'
    ],
    'Bibare': [
      'Abatuje',
      'Amariza',
      'Imanzi',
      'Imena',
      'Imitari',
      'Inganji',
      'Ingenzi',
      'Ingeri',
      'Inshuti',
      'Intashyo',
      'Intwari',
      'Inyamibwa',
      'Inyange',
      'Ubwiza',
      'Umwezi'
    ],
    'Nyagatovu': [
      'Ibukinanyana',
      'Ibuhoro',
      'Ijabiro',
      'Isangano',
      'Itetero',
      'Urugwiro'
    ],
  };

  void _onCellChanged(String? cell) {
    setState(() {
      _selectedCell = cell;
      _selectedVillage = null;
      _availableVillages = cell != null ? (_cellVillages[cell] ?? []) : [];
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    _provinceController.dispose();
    _districtController.dispose();
    _sectorController.dispose();
    super.dispose();
  }

  Future<void> _selectDueDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 180)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: _teal,
            onPrimary: _white,
            onSurface: _navy,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDueDate = picked);
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCell == null) {
      _showSnack('Please select a cell');
      return;
    }
    if (_selectedVillage == null) {
      _showSnack('Please select a village');
      return;
    }
    if (_selectedDueDate == null) {
      _showSnack('Please select expected due date');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final apiService = ApiService();
      final pregnancyStartDate =
          DateTime.now().subtract(const Duration(days: 90));

      await apiService.createMother({
        'name': _nameController.text.trim(),
        'age': int.parse(_ageController.text),
        'phone': _phoneController.text.trim(),
        'province': _provinceController.text.trim(),
        'district': _districtController.text.trim(),
        'sector': _sectorController.text.trim(),
        'cell': _selectedCell,
        'village': _selectedVillage,
        'pregnancy_start_date': pregnancyStartDate.toIso8601String(),
        'due_date': _selectedDueDate!.toIso8601String(),
      });

      if (mounted) {
        _showSnack('Mother registered successfully!', success: true);
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) _showSnack('Error: ${e.toString()}', error: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg, {bool success = false, bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: error
            ? const Color(0xFFDC2626)
            : success
                ? _teal
                : _navy,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ─── Input decoration factory ──────────────────────────────────────────────
  InputDecoration _fieldDecor({
    required String label,
    required IconData icon,
    bool readOnly = false,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: _gray, fontSize: 14),
      prefixIcon: Icon(icon, color: readOnly ? _gray : _teal, size: 20),
      filled: true,
      fillColor: readOnly ? _readonlyFill : _inputFill,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _inputBorder, width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _teal, width: 1.8),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1.8),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _inputBorder, width: 1.2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    final isEnglish = languageProvider.isEnglish;

    return Scaffold(
      backgroundColor: _bgPage,
      appBar: AppBar(
        backgroundColor: _teal,
        foregroundColor: _white,
        elevation: 0,
        centerTitle: false,
        title: Text(
          isEnglish ? 'Register Mother' : 'Andikisha Mama',
          style: const TextStyle(
            color: _white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: _white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Card: Personal Info ──────────────────────────────────────
              _SectionCard(
                title: isEnglish ? 'Personal Information' : 'Amakuru y\'umuntu',
                icon: Icons.person_outline,
                children: [
                  // Full Name
                  TextFormField(
                    controller: _nameController,
                    decoration: _fieldDecor(
                      label: isEnglish ? 'Full Name' : 'Amazina yuzuye',
                      icon: Icons.person_outline,
                    ),
                    style: const TextStyle(color: _navy, fontSize: 15),
                    validator: (v) => (v == null || v.isEmpty)
                        ? (isEnglish ? 'Please enter name' : 'Andika amazina')
                        : null,
                  ),
                  const SizedBox(height: 14),

                  // Age
                  TextFormField(
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    decoration: _fieldDecor(
                      label: isEnglish ? 'Age' : 'Imyaka',
                      icon: Icons.cake_outlined,
                    ),
                    style: const TextStyle(color: _navy, fontSize: 15),
                    validator: (v) => (v == null || v.isEmpty)
                        ? (isEnglish ? 'Please enter age' : 'Andika imyaka')
                        : null,
                  ),
                  const SizedBox(height: 14),

                  // Phone
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: _fieldDecor(
                      label: isEnglish ? 'Phone Number' : 'Nimero ya telephone',
                      icon: Icons.phone_outlined,
                    ),
                    style: const TextStyle(color: _navy, fontSize: 15),
                    validator: (v) => (v == null || v.isEmpty)
                        ? (isEnglish ? 'Please enter phone' : 'Andika numero')
                        : null,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ── Card: Location ───────────────────────────────────────────
              _SectionCard(
                title: isEnglish ? 'Location' : 'Aho atuye',
                icon: Icons.location_on_outlined,
                children: [
                  // Province (readonly)
                  TextFormField(
                    controller: _provinceController,
                    readOnly: true,
                    decoration: _fieldDecor(
                      label: isEnglish ? 'Province' : 'Intara',
                      icon: Icons.location_city_outlined,
                      readOnly: true,
                    ),
                    style: const TextStyle(color: _gray, fontSize: 15),
                  ),
                  const SizedBox(height: 14),

                  // District (readonly)
                  TextFormField(
                    controller: _districtController,
                    readOnly: true,
                    decoration: _fieldDecor(
                      label: isEnglish ? 'District' : 'Akarere',
                      icon: Icons.location_city_outlined,
                      readOnly: true,
                    ),
                    style: const TextStyle(color: _gray, fontSize: 15),
                  ),
                  const SizedBox(height: 14),

                  // Sector (readonly)
                  TextFormField(
                    controller: _sectorController,
                    readOnly: true,
                    decoration: _fieldDecor(
                      label: isEnglish ? 'Sector' : 'Umurenge',
                      icon: Icons.location_on_outlined,
                      readOnly: true,
                    ),
                    style: const TextStyle(color: _gray, fontSize: 15),
                  ),
                  const SizedBox(height: 14),

                  // Cell dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedCell,
                    decoration: _fieldDecor(
                      label: isEnglish ? 'Cell' : 'Akagari',
                      icon: Icons.location_on_outlined,
                    ),
                    icon: const Icon(Icons.keyboard_arrow_down, color: _teal),
                    dropdownColor: _white,
                    style: const TextStyle(color: _navy, fontSize: 15),
                    items: _allCells
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: _onCellChanged,
                    validator: (v) => v == null
                        ? (isEnglish ? 'Please select cell' : 'Hitamo akagari')
                        : null,
                  ),
                  const SizedBox(height: 14),

                  // Village dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedVillage,
                    decoration: _fieldDecor(
                      label: isEnglish ? 'Village' : 'Umudugudu',
                      icon: Icons.home_outlined,
                    ),
                    icon: const Icon(Icons.keyboard_arrow_down, color: _teal),
                    dropdownColor: _white,
                    style: const TextStyle(color: _navy, fontSize: 15),
                    items: _availableVillages
                        .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedVillage = v),
                    validator: (v) => v == null
                        ? (isEnglish
                            ? 'Please select village'
                            : 'Hitamo umudugudu')
                        : null,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ── Card: Due Date ───────────────────────────────────────────
              _SectionCard(
                title: isEnglish ? 'Expected Due Date' : 'Itariki y\'kubyara',
                icon: Icons.calendar_today_outlined,
                children: [
                  GestureDetector(
                    onTap: _selectDueDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        color: _inputFill,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              _selectedDueDate != null ? _teal : _inputBorder,
                          width: _selectedDueDate != null ? 1.8 : 1.2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            color: _selectedDueDate != null ? _teal : _gray,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _selectedDueDate == null
                                ? (isEnglish
                                    ? 'Tap to select date'
                                    : 'Kanda uhitemo itariki')
                                : '${_selectedDueDate!.day}/'
                                    '${_selectedDueDate!.month}/'
                                    '${_selectedDueDate!.year}',
                            style: TextStyle(
                              color: _selectedDueDate != null ? _navy : _gray,
                              fontSize: 15,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.chevron_right,
                            color: _selectedDueDate != null ? _teal : _gray,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // ── Submit button ────────────────────────────────────────────
              SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _teal,
                    foregroundColor: _white,
                    disabledBackgroundColor: _teal.withOpacity(0.5),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: _white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(
                          isEnglish ? 'Register Mother' : 'Andikisha Mama',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
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
//  SECTION CARD WRAPPER
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
          // Card header
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5F3),
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
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: _cardBorder, height: 1),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}
