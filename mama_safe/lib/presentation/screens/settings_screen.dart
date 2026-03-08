import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_strings.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import '../../providers/theme_provider.dart';
import 'auth/sign_in_screen.dart';

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

/// Settings Screen – MamaSafe clean design
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final languageProvider = context.watch<LanguageProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final isEnglish = languageProvider.isEnglish;
    final isDarkMode = themeProvider.isDarkMode;

    final userName = authProvider.currentUserName ?? 'User';
    final userEmail = authProvider.currentUserEmail ?? 'email@example.com';

    return Scaffold(
      backgroundColor: _bgPage,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Profile Header Card ─────────────────────────
              _ProfileHeader(
                userName: userName,
                userEmail: userEmail,
                roleLabel: authProvider.getRoleDisplayName(),
              ),
              const SizedBox(height: 28),

              // ── Section label ───────────────────────────────
              _SectionLabel(label: isEnglish ? 'Settings' : 'Igenamiterere'),
              const SizedBox(height: 14),

              // ── Language tile ───────────────────────────────
              _SettingsTile(
                icon: Icons.language_outlined,
                iconBg: _teal,
                title: isEnglish ? 'Language' : 'Ururimi',
                subtitle:
                    languageProvider.isEnglish ? 'English' : 'Kinyarwanda',
                trailing: _StyledSwitch(
                  value: !languageProvider.isEnglish,
                  onChanged: (v) => languageProvider.setLanguage(
                    v
                        ? AppStrings.languageKinyarwanda
                        : AppStrings.languageEnglish,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // ── Dark mode tile ──────────────────────────────
              _SettingsTile(
                icon: isDarkMode
                    ? Icons.dark_mode_outlined
                    : Icons.light_mode_outlined,
                iconBg: _teal,
                title: isEnglish ? 'Dark Mode' : 'Umucyo mweru',
                subtitle: isDarkMode
                    ? (isEnglish ? 'Enabled' : 'Akoresha')
                    : (isEnglish ? 'Disabled' : 'Hatakoresha'),
                trailing: _StyledSwitch(
                  value: isDarkMode,
                  onChanged: (_) => themeProvider.toggleTheme(),
                ),
              ),
              const SizedBox(height: 28),

              // ── Logout button ───────────────────────────────
              _LogoutButton(isEnglish: isEnglish, authProvider: authProvider),
              const SizedBox(height: 36),

              // ── App info ────────────────────────────────────
              Center(
                child: Column(
                  children: [
                    Text(
                      'MamaSafe v1.0.0',
                      style: TextStyle(
                        color: _gray.withOpacity(0.6),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isEnglish
                          ? 'Maternal Health Monitoring'
                          : 'Ikurikiranire ya Mama',
                      style: TextStyle(
                        color: _gray.withOpacity(0.5),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  PROFILE HEADER CARD
// ─────────────────────────────────────────────
class _ProfileHeader extends StatelessWidget {
  final String userName;
  final String userEmail;
  final String roleLabel;

  const _ProfileHeader({
    required this.userName,
    required this.userEmail,
    required this.roleLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A7A6E), Color(0xFF1D8C7F)],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: _teal.withOpacity(0.30),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            right: -24,
            top: -24,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _white.withOpacity(0.06),
              ),
            ),
          ),
          Positioned(
            left: -16,
            bottom: -30,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _white.withOpacity(0.04),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: Column(
              children: [
                // Avatar
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: _white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                      style: const TextStyle(
                        color: _teal,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  userName,
                  style: const TextStyle(
                    color: _white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  userEmail,
                  style: TextStyle(
                    color: _white.withOpacity(0.78),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 12),
                // Role badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                    color: _white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: _white.withOpacity(0.25), width: 1),
                  ),
                  child: Text(
                    roleLabel,
                    style: const TextStyle(
                      color: _white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
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
//  SETTINGS TILE
// ─────────────────────────────────────────────
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final String title;
  final String subtitle;
  final Widget? trailing;

  const _SettingsTile({
    required this.icon,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _cardBorder, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: _teal.withOpacity(0.06),
            blurRadius: 16,
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
          // Icon — clean teal style matching dashboard cards
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _tealLight,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: _teal, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: _navy,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: _gray,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  STYLED SWITCH
// ─────────────────────────────────────────────
class _StyledSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _StyledSwitch({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: value,
      onChanged: onChanged,
      activeColor: _teal,
      activeTrackColor: _teal.withOpacity(0.3),
      inactiveThumbColor: _gray.withOpacity(0.5),
      inactiveTrackColor: _gray.withOpacity(0.15),
    );
  }
}

// ─────────────────────────────────────────────
//  LOGOUT BUTTON
// ─────────────────────────────────────────────
class _LogoutButton extends StatelessWidget {
  final bool isEnglish;
  final AuthProvider authProvider;

  const _LogoutButton({required this.isEnglish, required this.authProvider});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFDC2626).withOpacity(0.18),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () async {
          await authProvider.signOut();
          if (context.mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const SignInScreen()),
              (route) => false,
            );
          }
        },
        icon: const Icon(Icons.logout_rounded, size: 18),
        label: Text(
          isEnglish ? 'Logout' : 'Sohoka',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFDC2626),
          foregroundColor: _white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}
