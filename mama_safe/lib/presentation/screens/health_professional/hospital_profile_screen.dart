import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/app_colors.dart';
import '../../../core/responsive.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/language_provider.dart';
import '../auth/sign_in_screen.dart';

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

class HospitalProfileScreen extends StatefulWidget {
  const HospitalProfileScreen({super.key});

  @override
  State<HospitalProfileScreen> createState() => _HospitalProfileScreenState();
}

class _HospitalProfileScreenState extends State<HospitalProfileScreen> {
  String _getDoctorInfo(String hospitalName) {
    switch (hospitalName) {
      case 'King Faisal Hospital Rwanda':
        return 'Dr. Aurore Isimbi';
      case 'Kibagabaga Level II Teaching Hospital':
        return 'Dr. Keza Diana';
      case 'Kacyiru District Hospital':
        return 'Dr. Sonia Uwera';
      default:
        return 'Doctor';
    }
  }

  String _getDoctorEmail(String hospitalName) {
    switch (hospitalName) {
      case 'King Faisal Hospital Rwanda':
        return 'aurore.ismbi@kfh.rw';
      case 'Kibagabaga Level II Teaching Hospital':
        return 'keza.diana@kibagabagahospital.rw';
      case 'Kacyiru District Hospital':
        return 'sonia.uwera@kacyiruhospital.rw';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final languageProvider = context.watch<LanguageProvider>();
    final isEnglish = languageProvider.isEnglish;

    final hospitalName = authProvider.currentUser?['facility'] ?? 'Hospital';
    final userName = authProvider.currentUserName ?? 'User';
    final userEmail = authProvider.currentUser?['email'] ?? '';
    final userPhone = authProvider.currentUser?['phone'] ?? '';

    return Scaffold(
      backgroundColor: _bgPage,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.padding(context),
            vertical: 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Page title ──────────────────────────────────
              Text(
                isEnglish ? 'Hospital Info' : 'Amakuru y\'ibitaro',
                style: const TextStyle(
                  color: _navy,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 20),

              // ── Hospital Info Card ───────────────────────────
              _Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hospital name row
                    Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: _navy,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.local_hospital_rounded,
                            color: _white,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                hospitalName,
                                style: const TextStyle(
                                  color: _navy,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                isEnglish
                                    ? 'Hospital Name (locked)'
                                    : 'Izina ry\'ibitaro',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: _gray,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.lock_outline_rounded,
                            color: _gray.withOpacity(0.5), size: 18),
                      ],
                    ),

                    const SizedBox(height: 16),
                    Container(height: 1, color: _border),
                    const SizedBox(height: 16),

                    _buildInfoRow(
                      icon: Icons.person_outline_rounded,
                      label: isEnglish ? 'Department' : 'Ishami',
                      value: userName,
                    ),
                    const SizedBox(height: 14),
                    _buildInfoRow(
                      icon: Icons.phone_outlined,
                      label: isEnglish ? 'Contact Phone' : 'Telefoni',
                      value: userPhone,
                    ),
                    const SizedBox(height: 14),
                    _buildInfoRow(
                      icon: Icons.email_outlined,
                      label: isEnglish ? 'Email' : 'Imeri',
                      value: userEmail,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── Assigned Doctor Card ─────────────────────────
              _Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: _teal,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.medical_services_rounded,
                            color: _white,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          isEnglish ? 'Assigned Doctor' : 'Muganga',
                          style: const TextStyle(
                            color: _navy,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(height: 1, color: _border),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      icon: Icons.local_hospital_rounded,
                      label: isEnglish ? 'Hospital' : 'Ibitaro',
                      value: hospitalName,
                    ),
                    const SizedBox(height: 14),
                    _buildInfoRow(
                      icon: Icons.person_rounded,
                      label: isEnglish ? 'Doctor Name' : 'Izina',
                      value: _getDoctorInfo(hospitalName),
                    ),
                    const SizedBox(height: 14),
                    _buildInfoRow(
                      icon: Icons.email_outlined,
                      label: isEnglish ? 'Email' : 'Imeri',
                      value: _getDoctorEmail(hospitalName),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Security Section ─────────────────────────────
              const Text(
                'Security',
                style: TextStyle(
                  color: _navy,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.1,
                ),
              ),
              const SizedBox(height: 12),

              _buildActionButton(
                icon: Icons.lock_reset_rounded,
                label:
                    isEnglish ? 'Change Password' : 'Hindura ijambo ry\'ibanga',
                color: _teal,
                onPressed: _changePassword,
              ),

              const SizedBox(height: 10),

              _buildActionButton(
                icon: Icons.logout_rounded,
                label: isEnglish ? 'Logout' : 'Sohoka',
                color: const Color(0xFFDC2626),
                onPressed: () => _logout(context),
              ),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  // ── Helpers ─────────────────────────────────────────────────

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: _teal.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: _teal),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: _gray),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: _navy,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: _white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 15),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // ── Logic (unchanged) ────────────────────────────────────────

  void _changePassword() {
    final languageProvider = context.read<LanguageProvider>();
    final isEnglish = languageProvider.isEnglish;
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          isEnglish ? 'Change Password' : 'Hindura ijambo ry\'ibanga',
          style: const TextStyle(
            color: _navy,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _dialogTextField(
              controller: currentPasswordController,
              label:
                  isEnglish ? 'Current Password' : 'Ijambo ry\'ibanga rya none',
              obscure: true,
            ),
            const SizedBox(height: 12),
            _dialogTextField(
              controller: newPasswordController,
              label: isEnglish ? 'New Password' : 'Ijambo ry\'ibanga rishya',
              obscure: true,
            ),
            const SizedBox(height: 12),
            _dialogTextField(
              controller: confirmPasswordController,
              label: isEnglish ? 'Confirm Password' : 'Emeza ijambo ry\'ibanga',
              obscure: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: _gray),
            child: Text(isEnglish ? 'Cancel' : 'Hagarika'),
          ),
          ElevatedButton(
            onPressed: () {
              if (newPasswordController.text !=
                  confirmPasswordController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isEnglish
                          ? 'Passwords do not match'
                          : 'Amagambo y\'ibanga ntabwo ahura',
                    ),
                    backgroundColor: AppColors.error,
                  ),
                );
                return;
              }
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isEnglish
                        ? 'Password changed successfully'
                        : 'Ijambo ry\'ibanga ryahinduwe',
                  ),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _teal,
              foregroundColor: _white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(isEnglish ? 'Change' : 'Hindura'),
          ),
        ],
      ),
    );
  }

  void _logout(BuildContext context) {
    final languageProvider = context.read<LanguageProvider>();
    final isEnglish = languageProvider.isEnglish;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          isEnglish ? 'Logout' : 'Sohoka',
          style: const TextStyle(
            color: _navy,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          isEnglish
              ? 'Are you sure you want to logout?'
              : 'Uzi neza ko ushaka gusohoka?',
          style: const TextStyle(color: _gray, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: _gray),
            child: Text(isEnglish ? 'Cancel' : 'Hagarika'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<AuthProvider>().signOut();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => SignInScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: _white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(isEnglish ? 'Logout' : 'Sohoka'),
          ),
        ],
      ),
    );
  }

  Widget _dialogTextField({
    required TextEditingController controller,
    required String label,
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: _navy, fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: _gray, fontSize: 13),
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
    );
  }
}

// ─────────────────────────────────────────────
//  REUSABLE CARD
// ─────────────────────────────────────────────
class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

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
      child: child,
    );
  }
}
