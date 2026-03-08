import 'package:flutter/material.dart';

// ─── COLOUR CONSTANTS ────────────────────────────────────────────────────────
const Color kTeal      = Color(0xFF1A7A6E);
const Color kTealDark  = Color(0xFF145F56);
const Color kTealLight = Color(0xFFE6F4F2);
const Color kNavy      = Color(0xFF1E2D4E);
const Color kWhite     = Color(0xFFFFFFFF);
const Color kBgPage    = Color(0xFFF0F4F3);
const Color kBorder    = Color(0xFFE5E7EB);
const Color kGray      = Color(0xFF6B7280);
const Color kDarkText  = Color(0xFF111827);
const Color kRed       = Color(0xFFEF4444);
const Color kOrange    = Color(0xFFF59E0B);
const Color kGreen     = Color(0xFF10B981);

// ─── HELPERS ─────────────────────────────────────────────────────────────────
Color riskColor(String risk) {
  final r = risk.toLowerCase();
  if (r.contains('high'))   return kRed;
  if (r.contains('medium') || r.contains('mid')) return kOrange;
  return kGreen;
}

String riskLabel(String risk) {
  final r = risk.toLowerCase();
  if (r.contains('high'))   return 'High';
  if (r.contains('medium') || r.contains('mid')) return 'Medium';
  return 'Low';
}

Color statusColor(String status) {
  final s = status.toLowerCase();
  if (s.contains('approved') || s.contains('completed')) return kGreen;
  if (s.contains('pending')  || s.contains('upcoming'))  return kOrange;
  if (s.contains('emergency'))                           return kRed;
  if (s.contains('cancel')   || s.contains('reject'))    return kRed;
  if (s.contains('schedule'))                            return kTeal;
  return kGray;
}

String initials(String name) {
  final parts = name.trim().split(' ');
  if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  return name.isNotEmpty ? name[0].toUpperCase() : '?';
}

// ─── ADMIN PAGE SCAFFOLD ─────────────────────────────────────────────────────
class AdminPage extends StatelessWidget {
  final String title, subtitle;
  final IconData icon;
  final List<Widget> headerActions;
  final Widget body;

  const AdminPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.body,
    this.headerActions = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgPage,
      body: SafeArea(
        child: Column(children: [
          // ── Header (only show if title is not empty) ──────────────────────────────────────
          if (title.isNotEmpty)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              decoration: const BoxDecoration(
                color: kTeal,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(children: [
                Row(children: [
                  // Back button (only show if can pop)
                  if (Navigator.of(context).canPop()) ...[
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: kWhite.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded, color: kWhite, size: 16),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  // Icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: kWhite.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                    child: Icon(icon, color: kWhite, size: 18),
                  ),
                  const SizedBox(width: 10),
                  // Title + subtitle
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(title, style: const TextStyle(color: kWhite, fontSize: 17, fontWeight: FontWeight.w700, letterSpacing: -0.2)),
                    Text(subtitle, style: TextStyle(color: kWhite.withOpacity(0.70), fontSize: 11.5)),
                  ])),
                  // Actions
                  ...headerActions,
                ]),
              ]),
            ),
          // ── Floating refresh button (only show if title is empty and has actions) ──────────
          if (title.isEmpty && headerActions.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: headerActions,
              ),
            ),

          // ── Body ────────────────────────────────────────
          Expanded(child: body),
        ]),
      ),
    );
  }
}

// ─── PANEL ───────────────────────────────────────────────────────────────────
class Panel extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final Widget? action;

  const Panel({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
    this.action,
  });

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 0),
        decoration: BoxDecoration(
          color: kWhite,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: kBorder, width: 1.2),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 3))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(children: [
              Container(width: 36, height: 36,
                  decoration: BoxDecoration(color: kTealLight, borderRadius: BorderRadius.circular(10)),
                  child: Icon(icon, color: kTeal, size: 18)),
              const SizedBox(width: 10),
              Expanded(child: Text(title, style: const TextStyle(color: kDarkText, fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: -0.1))),
              if (action != null) action!,
            ]),
          ),
          const SizedBox(height: 12),
          const Divider(color: kBorder, height: 1),
          const SizedBox(height: 4),
          Padding(padding: const EdgeInsets.fromLTRB(16, 4, 16, 16), child: child),
        ]),
      );
}

// ─── GHOST BUTTON ────────────────────────────────────────────────────────────
class GhostBtn extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool isDark;

  const GhostBtn({super.key, required this.icon, required this.tooltip, required this.onTap, this.isDark = false});

  @override
  Widget build(BuildContext context) => Tooltip(
        message: tooltip,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? kTeal : kWhite.withOpacity(0.15), 
              borderRadius: BorderRadius.circular(10),
              boxShadow: isDark ? [
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))
              ] : null,
            ),
            child: Icon(icon, color: isDark ? kWhite : kWhite, size: 18),
          ),
        ),
      );
}

// ─── ADMIN BADGE ─────────────────────────────────────────────────────────────
class AdminBadge extends StatelessWidget {
  final String label;
  final Color color;

  const AdminBadge({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
      );
}

// ─── SEARCH BAR ──────────────────────────────────────────────────────────────
class AdminSearchBar extends StatelessWidget {
  final String hint, query;
  final ValueChanged<String> onChanged;

  const AdminSearchBar({super.key, required this.hint, required this.onChanged, required this.query});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: kWhite,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: kBorder, width: 1.2),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: TextField(
          onChanged: onChanged,
          style: const TextStyle(color: kDarkText, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: kGray, fontSize: 14),
            prefixIcon: const Icon(Icons.search_rounded, color: kGray, size: 20),
            suffixIcon: query.isNotEmpty
                ? GestureDetector(
                    onTap: () => onChanged(''),
                    child: const Icon(Icons.close_rounded, color: kGray, size: 18))
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          ),
        ),
      );
}

// ─── FILTER CHIPS ────────────────────────────────────────────────────────────
class AdminFilterChips extends StatelessWidget {
  final List<String> labels;
  final String selected;
  final ValueChanged<String> onChanged;
  final Map<String, int> counts;
  final Map<String, Color> dotColors;

  const AdminFilterChips({
    super.key,
    required this.labels,
    required this.selected,
    required this.onChanged,
    this.counts = const {},
    this.dotColors = const {},
  });

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: labels.map((l) {
            final sel   = selected == l;
            final count = counts[l];
            final dot   = dotColors[l];
            return GestureDetector(
              onTap: () => onChanged(l),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 140),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
                decoration: BoxDecoration(
                  color: sel ? kTeal : kWhite,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: sel ? kTeal : kBorder, width: 1.2),
                  boxShadow: sel
                      ? [BoxShadow(color: kTeal.withOpacity(0.20), blurRadius: 5, offset: const Offset(0, 2))]
                      : [],
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  if (dot != null && !sel) ...[
                    Container(width: 7, height: 7, decoration: BoxDecoration(color: dot, shape: BoxShape.circle)),
                    const SizedBox(width: 5),
                  ],
                  Text(l, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: sel ? kWhite : kGray)),
                  if (count != null) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: sel ? kWhite.withOpacity(0.25) : kBgPage,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('$count', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: sel ? kWhite : kGray)),
                    ),
                  ],
                ]),
              ),
            );
          }).toList(),
        ),
      );
}

// ─── TABLE HEAD ──────────────────────────────────────────────────────────────
class AdminTableHead extends StatelessWidget {
  final List<String> cols;
  const AdminTableHead({super.key, required this.cols});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(color: kTealLight, borderRadius: BorderRadius.circular(8)),
        child: Row(
          children: cols.asMap().entries.map((e) => Expanded(
            child: Text(e.value,
                textAlign: e.key == 0 ? TextAlign.left : TextAlign.center,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: kTeal)),
          )).toList(),
        ),
      );
}

// ─── TABLE ROW ───────────────────────────────────────────────────────────────
class AdminTableRow extends StatelessWidget {
  final List<String> cells;
  final bool isEven;
  final List<Color>? cellColors;

  const AdminTableRow({super.key, required this.cells, this.isEven = false, this.cellColors});

  @override
  Widget build(BuildContext context) => Container(
        color: isEven ? kBgPage.withOpacity(0.6) : kWhite,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        child: Row(
          children: cells.asMap().entries.map((e) {
            final color = (cellColors != null && e.key < cellColors!.length) ? cellColors![e.key] : kGray;
            return Expanded(
              child: Text(e.value,
                  textAlign: e.key == 0 ? TextAlign.left : TextAlign.center,
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: color,
                      fontWeight: e.key == 0 ? FontWeight.w600 : FontWeight.w500)),
            );
          }).toList(),
        ),
      );
}

// ─── LOADING ─────────────────────────────────────────────────────────────────
class AdminLoading extends StatelessWidget {
  const AdminLoading({super.key});

  @override
  Widget build(BuildContext context) => const Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          CircularProgressIndicator(color: kTeal, strokeWidth: 2.5),
          SizedBox(height: 16),
          Text('Loading…', style: TextStyle(color: kGray, fontSize: 14)),
        ]),
      );
}

// ─── EMPTY STATE ─────────────────────────────────────────────────────────────
class AdminEmpty extends StatelessWidget {
  final String message;
  final IconData icon;
  const AdminEmpty({super.key, required this.message, required this.icon});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: kTealLight, borderRadius: BorderRadius.circular(20)),
              child: Icon(icon, size: 36, color: kTeal),
            ),
            const SizedBox(height: 16),
            Text(message, style: const TextStyle(color: kGray, fontSize: 14, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
          ]),
        ),
      );
}

// ─── STAT CARD ───────────────────────────────────────────────────────────────
class StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;

  const StatCard({super.key, required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: kWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kBorder, width: 1.2),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 20),
          ),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: kDarkText)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 12, color: kGray)),
        ]),
      );
}

// ─── AVATAR TILE ─────────────────────────────────────────────────────────────
class AvatarTile extends StatelessWidget {
  final String name, subtitle;
  final String? badge;
  final Color? badgeColor;
  final List<InfoChipData> chips;

  const AvatarTile({super.key, required this.name, required this.subtitle, this.badge, this.badgeColor, this.chips = const []});

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: kWhite,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: kBorder, width: 1.2),
        ),
        child: Row(children: [
          CircleAvatar(backgroundColor: kTealLight, radius: 22, child: Text(initials(name), style: const TextStyle(color: kTeal, fontWeight: FontWeight.w700, fontSize: 14))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: kDarkText)),
            const SizedBox(height: 2),
            Text(subtitle, style: const TextStyle(fontSize: 12, color: kGray)),
            if (chips.isNotEmpty) ...[
              const SizedBox(height: 6),
              Wrap(spacing: 6, runSpacing: 4, children: chips.map((c) => InfoChip(data: c)).toList()),
            ],
          ])),
          if (badge != null) AdminBadge(label: badge!, color: badgeColor ?? kGray),
        ]),
      );
}

// ─── INFO CHIP DATA ──────────────────────────────────────────────────────────
class InfoChipData {
  final IconData icon;
  final String label;
  const InfoChipData(this.icon, this.label);
}

class InfoChip extends StatelessWidget {
  final InfoChipData data;
  const InfoChip({super.key, required this.data});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: kBgPage, borderRadius: BorderRadius.circular(8)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(data.icon, size: 12, color: kGray),
          const SizedBox(width: 4),
          Text(data.label, style: const TextStyle(fontSize: 11, color: kGray)),
        ]),
      );
}
