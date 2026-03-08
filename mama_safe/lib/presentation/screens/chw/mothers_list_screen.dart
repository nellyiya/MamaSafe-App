import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/app_colors.dart';
import '../../../core/responsive.dart';
import '../../../models/mother_model.dart';
import '../../../providers/language_provider.dart';
import '../../../providers/mother_provider.dart';
import 'run_prediction_screen.dart';
import 'mother_detail_screen.dart';
import 'register_mother_screen.dart';

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

/// Mothers List Screen
class MothersListScreen extends StatefulWidget {
  const MothersListScreen({super.key});

  @override
  State<MothersListScreen> createState() => _MothersListScreenState();
}

class _MothersListScreenState extends State<MothersListScreen> {
  String _searchQuery = '';
  String _filterRisk = 'All';

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    final motherProvider = context.watch<MotherProvider>();
    final isEnglish = languageProvider.isEnglish;

    // ── Filter logic (unchanged) ─────────────────────────────────────────────
    final filteredMothers = motherProvider.mothers.where((mother) {
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        if (!mother.fullName.toLowerCase().contains(q) &&
            !mother.phoneNumber.contains(q)) return false;
      }
      if (_filterRisk == 'Appointments') {
        print('🔍 Filtering for appointments: ${mother.fullName} - hasScheduledAppointment: ${mother.hasScheduledAppointment}');
        return mother.hasScheduledAppointment;
      }
      if (_filterRisk != 'All') {
        if (_filterRisk == 'High' && mother.riskLevel != 'High') return false;
        if (_filterRisk == 'Mid' &&
            mother.riskLevel != 'Mid' &&
            mother.riskLevel != 'Medium') return false;
        if (_filterRisk == 'Low' && mother.riskLevel != 'Low') return false;
        if (_filterRisk == 'Not Predicted' &&
            mother.riskLevel != 'Not Predicted') return false;
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: _bgPage,
      body: Column(
        children: [
          // ── Search bar ─────────────────────────────────────────────────────
          Container(
            color: _white,
            padding: EdgeInsets.fromLTRB(
              Responsive.padding(context),
              12,
              Responsive.padding(context),
              0,
            ),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              style: const TextStyle(color: _navy, fontSize: 14),
              decoration: InputDecoration(
                hintText:
                    isEnglish ? 'Search mothers...' : 'Shakisha ababyeyi...',
                hintStyle: const TextStyle(color: _gray, fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: _gray, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close, color: _gray, size: 18),
                        onPressed: () => setState(() => _searchQuery = ''),
                      )
                    : null,
                filled: true,
                fillColor: _inputFill,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _cardBorder, width: 1.2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _teal, width: 1.8),
                ),
              ),
            ),
          ),

          // ── Filter chips ───────────────────────────────────────────────────
          Container(
            color: _white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _FilterChip(
                    label: isEnglish ? 'All' : 'Bose',
                    value: 'All',
                    selected: _filterRisk,
                    onTap: _setFilter),
                _FilterChip(
                    label: isEnglish ? 'High' : 'Hejuru',
                    value: 'High',
                    selected: _filterRisk,
                    onTap: _setFilter,
                    dotColor: const Color(0xFFDC2626)),
                _FilterChip(
                    label: isEnglish ? 'Mid' : 'Hagati',
                    value: 'Mid',
                    selected: _filterRisk,
                    onTap: _setFilter,
                    dotColor: const Color(0xFFD97706)),
                _FilterChip(
                    label: isEnglish ? 'Low' : 'Hasi',
                    value: 'Low',
                    selected: _filterRisk,
                    onTap: _setFilter,
                    dotColor: _teal),
                _FilterChip(
                    label: 'N/P',
                    value: 'Not Predicted',
                    selected: _filterRisk,
                    onTap: _setFilter,
                    dotColor: _gray),
                _FilterChip(
                    label: isEnglish ? 'Appointments' : 'Gahunda',
                    value: 'Appointments',
                    selected: _filterRisk,
                    onTap: _setFilter,
                    icon: Icons.calendar_today_outlined),
              ],
            ),
          ),

          // ── Thin divider ───────────────────────────────────────────────────
          const Divider(color: _cardBorder, height: 1),

          // ── Count label ────────────────────────────────────────────────────
          Container(
            color: _bgPage,
            padding: EdgeInsets.fromLTRB(
              Responsive.padding(context),
              14,
              Responsive.padding(context),
              6,
            ),
            child: Row(
              children: [
                Text(
                  isEnglish
                      ? '${filteredMothers.length} mother${filteredMothers.length == 1 ? '' : 's'}'
                      : 'Ababyeyi: ${filteredMothers.length}',
                  style: const TextStyle(
                    color: _gray,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // ── List / Grid / Empty ────────────────────────────────────────────
          Expanded(
            child: filteredMothers.isEmpty
                ? _EmptyState(isEnglish: isEnglish)
                : Responsive.isDesktop(context)
                    ? GridView.builder(
                        padding: EdgeInsets.symmetric(
                          horizontal: Responsive.padding(context),
                          vertical: 8,
                        ),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: 1.5,
                        ),
                        itemCount: filteredMothers.length,
                        itemBuilder: (context, index) => _MotherCard(
                          mother: filteredMothers[index],
                          isEnglish: isEnglish,
                          onViewDetails: () =>
                              _viewDetails(context, filteredMothers[index]),
                          onRunPrediction: () =>
                              _runPrediction(context, filteredMothers[index]),
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.symmetric(
                          horizontal: Responsive.padding(context),
                          vertical: 8,
                        ),
                        itemCount: filteredMothers.length,
                        itemBuilder: (context, index) => _MotherCard(
                          mother: filteredMothers[index],
                          isEnglish: isEnglish,
                          onViewDetails: () =>
                              _viewDetails(context, filteredMothers[index]),
                          onRunPrediction: () =>
                              _runPrediction(context, filteredMothers[index]),
                        ),
                      ),
          ),
        ],
      ),

      // ── FAB ───────────────────────────────────────────────────────────────
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RegisterMotherScreen()),
          );
          if (context.mounted) {
            await context.read<MotherProvider>().loadMothers();
          }
        },
        backgroundColor: _teal,
        elevation: 2,
        child: const Icon(Icons.add, color: _white),
      ),
    );
  }

  void _setFilter(String value) =>
      setState(() => _filterRisk = _filterRisk == value ? 'All' : value);

  void _viewDetails(BuildContext context, MotherModel mother) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => MotherDetailScreen(motherId: mother.id)),
    );
  }

  void _runPrediction(BuildContext context, MotherModel mother) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => RunPredictionScreen(motherId: mother.id)),
    );
  }
}

// ─────────────────────────────────────────────
//  FILTER CHIP
// ─────────────────────────────────────────────
class _FilterChip extends StatelessWidget {
  final String label;
  final String value;
  final String selected;
  final void Function(String) onTap;
  final Color? dotColor;
  final IconData? icon;

  const _FilterChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
    this.dotColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selected == value;

    return GestureDetector(
      onTap: () => onTap(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? _teal : _white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? _teal : _cardBorder,
            width: 1.3,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null && !isSelected) ...[
              Icon(icon, size: 13, color: _navy),
              const SizedBox(width: 5),
            ],
            if (dotColor != null && !isSelected) ...[
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected ? _white : _navy,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  MOTHER CARD
// ─────────────────────────────────────────────
class _MotherCard extends StatelessWidget {
  final MotherModel mother;
  final bool isEnglish;
  final VoidCallback onViewDetails;
  final VoidCallback onRunPrediction;

  const _MotherCard({
    required this.mother,
    required this.isEnglish,
    required this.onViewDetails,
    required this.onRunPrediction,
  });

  @override
  Widget build(BuildContext context) {
    // Initials from name
    final initials = mother.fullName
        .trim()
        .split(' ')
        .map((w) => w.isNotEmpty ? w[0] : '')
        .take(2)
        .join()
        .toUpperCase();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top row: avatar + name + risk badge ─────────────────────────
            Row(
              children: [
                // Initials avatar
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _tealLight,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Center(
                    child: Text(
                      initials,
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
                        mother.fullName,
                        style: const TextStyle(
                          color: _navy,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(Icons.phone_outlined,
                              size: 12, color: _gray),
                          const SizedBox(width: 4),
                          Text(
                            mother.phoneNumber,
                            style: const TextStyle(color: _gray, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                _RiskBadge(risk: mother.riskLevel),
              ],
            ),

            const SizedBox(height: 12),

            // ── Info chips row ──────────────────────────────────────────────
            Row(
              children: [
                _InfoChip(
                  icon: Icons.cake_outlined,
                  label:
                      isEnglish ? '${mother.age} yrs' : '${mother.age} imyaka',
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _InfoChip(
                    icon: Icons.location_on_outlined,
                    label: mother.address.length > 16
                        ? '${mother.address.substring(0, 16)}…'
                        : mother.address,
                  ),
                ),
                const SizedBox(width: 8),
                _StatusBadge(status: mother.status),
              ],
            ),

            const SizedBox(height: 14),

            // ── Action buttons ──────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 36,
                    child: OutlinedButton.icon(
                      onPressed: onViewDetails,
                      icon: const Icon(Icons.visibility_outlined, size: 15),
                      label: Text(
                        isEnglish ? 'Details' : 'Ibyifashisho',
                        style: const TextStyle(fontSize: 12),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _navy,
                        side: const BorderSide(color: _cardBorder, width: 1.2),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9)),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: 36,
                    child: ElevatedButton.icon(
                      onPressed: onRunPrediction,
                      icon: const Icon(Icons.auto_graph, size: 15),
                      label: Text(
                        isEnglish ? 'Predict' : 'Igenzura',
                        style: const TextStyle(fontSize: 12),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _teal,
                        foregroundColor: _white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9)),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
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
    String label;

    switch (risk) {
      case 'High':
        color = const Color(0xFFDC2626);
        label = 'High';
        break;
      case 'Mid':
      case 'Medium':
        color = const Color(0xFFD97706);
        label = 'Mid';
        break;
      case 'Low':
        color = _teal;
        label = 'Low';
        break;
      default:
        color = _gray;
        label = 'N/P';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.35), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  INFO CHIP
// ─────────────────────────────────────────────
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: _bgPage,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _cardBorder, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: _gray),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(
                  fontSize: 11, color: _gray, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  STATUS BADGE
// ─────────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (status) {
      case 'referred':
        color = const Color(0xFFD97706);
        label = 'Referred';
        break;
      case 'completed':
        color = _teal;
        label = 'Done';
        break;
      default:
        color = _navy;
        label = 'Active';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  EMPTY STATE
// ─────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final bool isEnglish;

  const _EmptyState({required this.isEnglish});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: _tealLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.pregnant_woman, color: _teal, size: 36),
          ),
          const SizedBox(height: 16),
          Text(
            isEnglish ? 'No mothers found' : 'Nta babyeyi babonetse',
            style: const TextStyle(
              color: _navy,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isEnglish
                ? 'Register a new mother to get started'
                : 'Andikisha mama mushya uyu musoza',
            style: const TextStyle(color: _gray, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
