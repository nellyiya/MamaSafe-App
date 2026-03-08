import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/responsive.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/language_provider.dart';

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
const _fieldBg = Color(0xFFF0F4F3);

class HospitalSignUpScreen extends StatefulWidget {
  const HospitalSignUpScreen({super.key});

  @override
  State<HospitalSignUpScreen> createState() => _HospitalSignUpScreenState();
}

class _HospitalSignUpScreenState extends State<HospitalSignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _selectedHospital;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedHospital == null) {
        _showSnack('Please select a hospital');
        return;
      }
      final authProvider = context.read<AuthProvider>();
      try {
        final success = await authProvider.signUp(
          fullName: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          role: AppUserRole.healthcareProfessional,
          password: _passwordController.text,
          facility: _selectedHospital,
        );
        if (success && mounted) _showSuccessDialog();
      } catch (e) {
        if (mounted) _showSnack('Error: ${e.toString()}');
      }
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: const Color(0xFFDC2626),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: _teal.withOpacity(0.10),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: _teal,
                  size: 42,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Account Created!',
                style: TextStyle(
                  color: _navy,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Your account is pending Admin approval. You will be notified once approved.',
                textAlign: TextAlign.center,
                style: TextStyle(color: _gray, fontSize: 13, height: 1.5),
              ),
              const SizedBox(height: 24),
              _PrimaryButton(
                label: 'OK',
                isLoading: false,
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    final isEnglish = languageProvider.isEnglish;
    final authProvider = context.watch<AuthProvider>();

    return SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: Responsive.isDesktop(context) ? 500 : double.infinity,
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.padding(context),
                vertical: 20,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Page headline ──────────────────────────
                    Text(
                      isEnglish ? 'Healthcare Professional' : 'Umuganga',
                      style: const TextStyle(
                        color: _navy,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isEnglish
                          ? 'Create your hospital account'
                          : 'Fungura konti y\'ibitaro',
                      style: const TextStyle(color: _gray, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 28),

                    // ── Form card ──────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: _white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: _border, width: 1.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // ── Facility ─────────────────────────
                          _SectionDivider(
                              label: isEnglish ? 'Facility' : 'Ibitaro'),
                          const SizedBox(height: 16),

                          _FieldLabel(
                              label: isEnglish
                                  ? 'Hospital Name'
                                  : 'Izina ry\'ibitaro'),
                          const SizedBox(height: 8),
                          _StyledDropdown<String>(
                            value: _selectedHospital,
                            hint: isEnglish
                                ? 'Select your hospital'
                                : 'Hitamo ibitaro',
                            icon: Icons.local_hospital_outlined,
                            items: const [
                              DropdownMenuItem(
                                value: 'King Faisal Hospital Rwanda',
                                child: Text('King Faisal Hospital Rwanda'),
                              ),
                              DropdownMenuItem(
                                value: 'Kibagabaga Level II Teaching Hospital',
                                child: Text(
                                    'Kibagabaga Level II Teaching Hospital'),
                              ),
                              DropdownMenuItem(
                                value: 'Kacyiru District Hospital',
                                child: Text('Kacyiru District Hospital'),
                              ),
                            ],
                            onChanged: (v) =>
                                setState(() => _selectedHospital = v),
                            validator: (v) => (v == null)
                                ? (isEnglish
                                    ? 'Please select a hospital'
                                    : 'Hitamo ibitaro')
                                : null,
                          ),

                          const SizedBox(height: 24),

                          // ── Personal Info ────────────────────
                          _SectionDivider(
                              label: isEnglish
                                  ? 'Representative Info'
                                  : 'Amakuru y\'uhagarariye'),
                          const SizedBox(height: 16),

                          _FieldLabel(
                              label: isEnglish
                                  ? 'Full Name'
                                  : 'Amazina y\'uhagarariye'),
                          const SizedBox(height: 8),
                          _InputField(
                            controller: _nameController,
                            hint: isEnglish
                                ? 'Enter full name'
                                : 'Amazina yuzuye',
                            icon: Icons.person_outline_rounded,
                            validator: (v) => (v == null || v.isEmpty)
                                ? (isEnglish
                                    ? 'Enter representative name'
                                    : 'Andika amazina')
                                : null,
                          ),
                          const SizedBox(height: 16),

                          _FieldLabel(
                              label: isEnglish
                                  ? 'Work Email'
                                  : 'Imeyili y\'akazi'),
                          const SizedBox(height: 8),
                          _InputField(
                            controller: _emailController,
                            hint: 'work@hospital.com',
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return isEnglish
                                    ? 'Enter work email'
                                    : 'Andika imeyili';
                              }
                              if (!v.contains('@')) {
                                return isEnglish
                                    ? 'Enter a valid email'
                                    : 'Imeyili siyo';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          _FieldLabel(
                              label: isEnglish
                                  ? 'Phone Number'
                                  : 'Nimero ya telefone'),
                          const SizedBox(height: 8),
                          _InputField(
                            controller: _phoneController,
                            hint: '+250 7XX XXX XXX',
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            validator: (v) => (v == null || v.isEmpty)
                                ? (isEnglish
                                    ? 'Enter phone number'
                                    : 'Andika numero')
                                : null,
                          ),

                          const SizedBox(height: 24),

                          // ── Security ─────────────────────────
                          _SectionDivider(
                              label: isEnglish ? 'Security' : 'Umutekano'),
                          const SizedBox(height: 16),

                          _FieldLabel(
                              label:
                                  isEnglish ? 'Password' : 'Ijambo ry\'ibanga'),
                          const SizedBox(height: 8),
                          _InputField(
                            controller: _passwordController,
                            hint: isEnglish
                                ? 'Min. 6 characters'
                                : 'Nibura inyuguti 6',
                            icon: Icons.lock_outline_rounded,
                            obscureText: _obscurePassword,
                            suffixIcon: GestureDetector(
                              onTap: () => setState(
                                  () => _obscurePassword = !_obscurePassword),
                              child: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: _gray,
                                size: 20,
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return isEnglish
                                    ? 'Enter a password'
                                    : 'Andika ijambo ry\'ibanga';
                              }
                              if (v.length < 6) {
                                return isEnglish
                                    ? 'At least 6 characters'
                                    : 'Nibura inyuguti 6';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          _FieldLabel(
                              label: isEnglish
                                  ? 'Confirm Password'
                                  : 'Emeza ijambo ry\'ibanga'),
                          const SizedBox(height: 8),
                          _InputField(
                            controller: _confirmPasswordController,
                            hint: isEnglish
                                ? 'Re-enter password'
                                : 'Ongera ijambo ry\'ibanga',
                            icon: Icons.lock_outline_rounded,
                            obscureText: _obscureConfirmPassword,
                            suffixIcon: GestureDetector(
                              onTap: () => setState(() =>
                                  _obscureConfirmPassword =
                                      !_obscureConfirmPassword),
                              child: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: _gray,
                                size: 20,
                              ),
                            ),
                            validator: (v) => (v != _passwordController.text)
                                ? (isEnglish
                                    ? 'Passwords do not match'
                                    : 'Amagambo atagaranye')
                                : null,
                          ),

                          const SizedBox(height: 28),

                          // ── Submit button ─────────────────────
                          _PrimaryButton(
                            label: isEnglish
                                ? 'Create Hospital Account'
                                : 'Fungura Konti y\'ibitaro',
                            isLoading: authProvider.isLoading,
                            onPressed: _signUp,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Sign in row ────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isEnglish
                              ? 'Already have an account?'
                              : 'Ufite konti?',
                          style: const TextStyle(color: _gray, fontSize: 13),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: TextButton.styleFrom(
                            foregroundColor: _teal,
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            isEnglish ? 'Sign In' : 'Injira',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        'MamaSafe · Maternal Health Monitoring',
                        style: TextStyle(
                          color: _gray.withOpacity(0.50),
                          fontSize: 11,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
  }
}

// ─────────────────────────────────────────────
//  SECTION DIVIDER
// ─────────────────────────────────────────────
class _SectionDivider extends StatelessWidget {
  final String label;
  const _SectionDivider({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
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
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Container(height: 1, color: _border)),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  FIELD LABEL
// ─────────────────────────────────────────────
class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) => Text(
        label,
        style: const TextStyle(
          color: _navy,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
      );
}

// ─────────────────────────────────────────────
//  INPUT FIELD
// ─────────────────────────────────────────────
class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final bool readOnly;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;

  const _InputField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.readOnly = false,
    this.keyboardType,
    this.suffixIcon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      readOnly: readOnly,
      validator: validator,
      style: const TextStyle(
        color: _navy,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: _gray.withOpacity(0.55), fontSize: 14),
        filled: true,
        fillColor: _fieldBg,
        prefixIcon: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Icon(icon, color: _teal, size: 20),
        ),
        suffixIcon: suffixIcon != null
            ? Padding(
                padding: const EdgeInsets.only(right: 14),
                child: suffixIcon,
              )
            : null,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _border, width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _border, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _teal, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFDC2626), width: 2.0),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  STYLED DROPDOWN
// ─────────────────────────────────────────────
class _StyledDropdown<T> extends StatelessWidget {
  final T? value;
  final String hint;
  final IconData icon;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final String? Function(T?)? validator;

  const _StyledDropdown({
    required this.value,
    required this.hint,
    required this.icon,
    required this.items,
    required this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: onChanged,
      validator: validator,
      style: const TextStyle(
        color: _navy,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      dropdownColor: _white,
      icon:
          const Icon(Icons.keyboard_arrow_down_rounded, color: _gray, size: 20),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: _gray.withOpacity(0.55), fontSize: 14),
        filled: true,
        fillColor: _fieldBg,
        prefixIcon: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Icon(icon, color: _teal, size: 20),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _border, width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _border, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _teal, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFDC2626), width: 2.0),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  PRIMARY BUTTON
// ─────────────────────────────────────────────
class _PrimaryButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback onPressed;

  const _PrimaryButton({
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_teal, _tealDark],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: _teal.withOpacity(0.30),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: _white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: isLoading
            ? const SizedBox(
                height: 22,
                width: 22,
                child:
                    CircularProgressIndicator(color: _white, strokeWidth: 2.5),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
      ),
    );
  }
}
