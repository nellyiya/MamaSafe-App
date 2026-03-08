import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import 'chw/chw_dashboard_screen.dart';
import 'chw/mothers_list_screen.dart';
import 'health_professional/hospital_home_screen.dart';
import 'health_professional/referrals_list_screen.dart';
import 'health_professional/hospital_reports_screen.dart';
import 'health_professional/hospital_profile_screen.dart';
import 'admin/admin_dashboard_screen.dart';
import 'admin/admin_mothers_screen.dart';
import 'admin/admin_referrals_screen.dart';
import 'admin/admin_appointments_screen.dart';
import 'admin/admin_chws_screen.dart';
import 'admin/admin_healthcare_pro_screen.dart';
import 'admin/admin_facilities_screen.dart';
import 'admin/admin_reports_screen.dart';
import 'settings_screen.dart';

/// Main Navigation Screen - Role-based bottom navigation
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  VoidCallback? _chwRefreshCallback;
  VoidCallback? _hospitalRefreshCallback;
  VoidCallback? _adminRefreshCallback;

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final languageProvider = context.watch<LanguageProvider>();
    final isEnglish = languageProvider.isEnglish;
    final userRole = authProvider.currentUserRole;

    if (userRole == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final screens = _getScreens(userRole, isEnglish);
    final navItems = _getNavItems(userRole, isEnglish);

    // Use sidebar for admin, bottom nav for others
    if (userRole == AppUserRole.admin) {
      return Scaffold(
        body: Row(
          children: [
            _buildSidebar(navItems, userRole),
            Expanded(
              child: screens[_currentIndex],
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          if (index == 0) {
            _refreshDashboard(userRole);
          }
        },
        items: navItems,
        selectedItemColor: const Color(0xFF1A7A6E),
        unselectedItemColor: const Color(0xFF6B7280),
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  Widget _buildSidebar(List<BottomNavigationBarItem> navItems, AppUserRole role) {
    return Container(
      width: 250,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6F4F2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.health_and_safety, color: Color(0xFF1A7A6E), size: 24),
                ),
                const SizedBox(width: 12),
                const Text(
                  'MamaSafe',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: navItems.length,
              itemBuilder: (context, index) {
                final item = navItems[index];
                final isSelected = _currentIndex == index;
                return InkWell(
                  onTap: () {
                    setState(() => _currentIndex = index);
                    if (index == 0) _refreshDashboard(role);
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFE6F4F2) : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelected ? (item.activeIcon as Icon).icon : (item.icon as Icon).icon,
                          color: isSelected ? const Color(0xFF1A7A6E) : const Color(0xFF6B7280),
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          item.label!,
                          style: TextStyle(
                            color: isSelected ? const Color(0xFF1A7A6E) : const Color(0xFF6B7280),
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          InkWell(
            onTap: () => _showLogoutDialog(context),
            child: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.logout_rounded, color: Color(0xFFEF4444), size: 22),
                  const SizedBox(width: 12),
                  const Text(
                    'Logout',
                    style: TextStyle(
                      color: Color(0xFFEF4444),
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Logout', style: TextStyle(color: Color(0xFF111827), fontSize: 17, fontWeight: FontWeight.w700)),
        content: const Text('Are you sure you want to logout?', style: TextStyle(color: Color(0xFF6B7280))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: const Color(0xFF6B7280)),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/login');
            },
            style: TextButton.styleFrom(foregroundColor: const Color(0xFFEF4444)),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _refreshDashboard(AppUserRole role) {
    switch (role) {
      case AppUserRole.chw:
        _chwRefreshCallback?.call();
        break;
      case AppUserRole.healthcareProfessional:
        _hospitalRefreshCallback?.call();
        break;
      case AppUserRole.admin:
        _adminRefreshCallback?.call();
        break;
    }
  }

  List<Widget> _getScreens(AppUserRole role, bool isEnglish) {
    switch (role) {
      case AppUserRole.chw:
        return [
          ChwDashboardScreen(onRefreshCallback: (callback) => _chwRefreshCallback = callback),
          const MothersListScreen(),
          const SettingsScreen(),
        ];
      case AppUserRole.healthcareProfessional:
        return [
          HospitalHomeScreen(onRefreshCallback: (callback) => _hospitalRefreshCallback = callback),
          const ReferralsScreen(),
          const HospitalReportsScreen(),
          const HospitalProfileScreen(),
        ];
      case AppUserRole.admin:
        return [
          new AdminDashboardScreen(),
          new AdminMothersScreen(),
          new AdminReferralsScreen(),
          new AdminAppointmentsScreen(),
          new AdminCHWsScreen(),
          new AdminHealthcareProScreen(),
          new AdminFacilitiesScreen(),
          new AdminReportsScreen(),
        ];
    }
  }

  List<BottomNavigationBarItem> _getNavItems(AppUserRole role, bool isEnglish) {
    switch (role) {
      case AppUserRole.chw:
        return [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home),
            label: isEnglish ? 'Home' : 'Ahabanza',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.people_outline),
            activeIcon: const Icon(Icons.people),
            label: isEnglish ? 'Mothers' : 'Ababyeyi',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings_outlined),
            activeIcon: const Icon(Icons.settings),
            label: isEnglish ? 'Settings' : 'Igenamiterwe',
          ),
        ];
      case AppUserRole.healthcareProfessional:
        return [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home),
            label: isEnglish ? 'Home' : 'Ahabanza',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.inbox_outlined),
            activeIcon: const Icon(Icons.inbox),
            label: isEnglish ? 'Referrals' : 'Referrals',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.assessment_outlined),
            activeIcon: const Icon(Icons.assessment),
            label: isEnglish ? 'Reports' : 'Raporo',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings_outlined),
            activeIcon: const Icon(Icons.settings),
            label: isEnglish ? 'Profile' : 'Profili',
          ),
        ];
      case AppUserRole.admin:
        return [
          BottomNavigationBarItem(
            icon: const Icon(Icons.dashboard_outlined),
            activeIcon: const Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.pregnant_woman_outlined),
            activeIcon: const Icon(Icons.pregnant_woman),
            label: 'Mothers',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.local_hospital_outlined),
            activeIcon: const Icon(Icons.local_hospital),
            label: 'Referrals',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.calendar_today_outlined),
            activeIcon: const Icon(Icons.calendar_today),
            label: 'Appointments',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.health_and_safety_outlined),
            activeIcon: const Icon(Icons.health_and_safety),
            label: 'CHWs',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.medical_services_outlined),
            activeIcon: const Icon(Icons.medical_services),
            label: 'Healthcare Pro',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.business_outlined),
            activeIcon: const Icon(Icons.business),
            label: 'Facilities',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.assessment_outlined),
            activeIcon: const Icon(Icons.assessment),
            label: 'Reports',
          ),
        ];
    }
  }
}
