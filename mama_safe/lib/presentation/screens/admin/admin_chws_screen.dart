import 'package:flutter/material.dart';
import '../../../services/api_service.dart';
import 'admin_shared.dart';

class AdminCHWsScreen extends StatefulWidget {
  const AdminCHWsScreen({super.key});
  @override
  State<AdminCHWsScreen> createState() => _AdminCHWsScreenState();
}

class _AdminCHWsScreenState extends State<AdminCHWsScreen> {
  final _api = ApiService();
  List<dynamic> _all = [];
  List<dynamic> _performance = [];
  bool _loading      = true;
  String _filter     = 'All';
  String _search     = '';

  static const _filters = ['All', 'Active', 'Inactive'];

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await _api.getCHWs();
      setState(() { _all = data; _performance = data; _loading = false; });
    } catch (e) { 
      print('Error loading CHWs: $e');
      setState(() => _loading = false); 
    }
  }

  List<dynamic> get _filtered => _all.where((c) {
    final active = (c['status'] == 'Active' || c['is_approved'] == true);
    if (_filter == 'Active'   && !active)  return false;
    if (_filter == 'Inactive' &&  active)  return false;
    if (_search.isNotEmpty) {
      final q = _search.toLowerCase();
      return (c['name']     ?? '').toString().toLowerCase().contains(q) ||
             (c['phone']    ?? '').toString().toLowerCase().contains(q) ||
             (c['cell']     ?? '').toString().toLowerCase().contains(q) ||
             (c['village']  ?? '').toString().toLowerCase().contains(q);
    }
    return true;
  }).toList();

  int _cnt(String f) {
    if (f == 'All')      return _all.length;
    if (f == 'Active')   return _all.where((c) => c['status'] == 'Active' || c['is_approved'] == true).length;
    return                      _all.where((c) => c['status'] != 'Active' && c['is_approved'] != true).length;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    return AdminPage(
      title: 'CHW Activity',
      subtitle: 'Community Health Workers',
      icon: Icons.people_alt_rounded,
      headerActions: [
        GhostBtn(icon: Icons.refresh_rounded, tooltip: 'Refresh', onTap: _load),
        const SizedBox(width: 8),
        GhostBtn(icon: Icons.person_add_outlined, tooltip: 'Add CHW', onTap: _showAddCHW),
      ],
      body: _loading
          ? const AdminLoading()
          : RefreshIndicator(
              color: kTeal,
              onRefresh: _load,
              child: Column(children: [
                // ── Search ────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                  child: AdminSearchBar(hint: 'Search CHWs…', onChanged: (v) => setState(() => _search = v), query: _search),
                ),

                // ── Filter chips ──────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                  child: AdminFilterChips(
                    labels: _filters,
                    selected: _filter,
                    onChanged: (v) => setState(() => _filter = v),
                    counts: {for (final f in _filters) f: _cnt(f)},
                    dotColors: {'Active': kGreen, 'Inactive': kOrange},
                  ),
                ),
                const SizedBox(height: 8),
                const Divider(color: kBorder, height: 1),

                // ── Count label ───────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: Text('${filtered.length} CHW${filtered.length == 1 ? '' : 's'}',
                      style: const TextStyle(color: kGray, fontSize: 13, fontWeight: FontWeight.w500)),
                ),

                // ── List ──────────────────────────────────────
                Expanded(
                  child: filtered.isEmpty
                      ? const AdminEmpty(message: 'No CHWs found', icon: Icons.people_outlined)
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                          itemCount: filtered.length,
                          itemBuilder: (_, i) => _CHWCard(chw: filtered[i], onTap: () => _showDetail(filtered[i])),
                        ),
                ),
              ]),
            ),
    );
  }

  void _showDetail(Map<String, dynamic> chw) => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => _CHWDetailSheet(chw: chw),
      );

  void _showAddCHW() => showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: kWhite,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Add New CHW', style: TextStyle(color: kDarkText, fontSize: 17, fontWeight: FontWeight.w700)),
          content: const Text('CHW registration form coming soon.', style: TextStyle(color: kGray)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(foregroundColor: kGray),
                child: const Text('Close')),
          ],
        ),
      );
}

// ── CHW Card ──────────────────────────────────────────────────────────────────
class _CHWCard extends StatelessWidget {
  final Map<String, dynamic> chw;
  final VoidCallback onTap;
  const _CHWCard({required this.chw, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final name      = chw['name']                    ?? 'Unknown';
    final location  = chw['cell']                    ?? chw['village'] ?? 'N/A';
    final phone     = chw['phone']                   ?? 'N/A';
    final mothers   = chw['mothers_count']           ?? 0;
    final assess    = chw['assessments_count']       ?? 0;
    final refs      = chw['referrals_count']         ?? 0;
    final highRisk  = 0;
    final isActive  = (chw['status'] == 'Active' || chw['is_approved'] == true);
    final ini       = initials(name);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: kWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kBorder, width: 1.2),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // ── Top row ───────────────────────────────────────
            Row(children: [
              Container(
                width: 46, height: 46,
                decoration: BoxDecoration(color: kTealLight, borderRadius: BorderRadius.circular(13)),
                child: Center(child: Text(ini, style: const TextStyle(color: kTeal, fontSize: 15, fontWeight: FontWeight.w800))),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(name, style: const TextStyle(color: kDarkText, fontSize: 14, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 3),
                Row(children: [
                  const Icon(Icons.location_on_outlined, size: 12, color: kGray),
                  const SizedBox(width: 4),
                  Expanded(child: Text(location, style: const TextStyle(color: kGray, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis)),
                ]),
                const SizedBox(height: 2),
                Row(children: [
                  const Icon(Icons.phone_outlined, size: 12, color: kGray),
                  const SizedBox(width: 4),
                  Text(phone, style: const TextStyle(color: kGray, fontSize: 11)),
                ]),
              ])),
              AdminBadge(label: isActive ? 'Active' : 'Inactive', color: isActive ? kGreen : kOrange),
            ]),

            const SizedBox(height: 12),
            const Divider(color: kBorder, height: 1),
            const SizedBox(height: 10),

            // ── Stats row ─────────────────────────────────────
            Row(children: [
              _StatChip(label: 'Mothers',     value: '$mothers', color: kTeal),
              const SizedBox(width: 8),
              _StatChip(label: 'Assessments', value: '$assess',  color: kTealDark),
              const SizedBox(width: 8),
              _StatChip(label: 'Referrals',   value: '$refs',    color: kOrange),
              const SizedBox(width: 8),
              _StatChip(label: '⚠ High Risk', value: '$highRisk', color: highRisk > 0 ? kRed : kGray),
            ]),
          ]),
        ),
      ),
    );
  }
}

// ── Stat chip inside card ─────────────────────────────────────────────────────
class _StatChip extends StatelessWidget {
  final String label, value;
  final Color color;
  const _StatChip({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(color: color.withOpacity(0.07), borderRadius: BorderRadius.circular(10)),
          child: Column(children: [
            Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: color)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 9.5, color: kGray), textAlign: TextAlign.center),
          ]),
        ),
      );
}

// ── Summary chip (top strip) ──────────────────────────────────────────────────
class _SummaryChip extends StatelessWidget {
  final String label, value;
  final Color color;
  final IconData icon;
  const _SummaryChip({required this.label, required this.value, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          decoration: BoxDecoration(
            color: kWhite,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: kBorder, width: 1.2),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Row(children: [
            Container(padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(color: color.withOpacity(0.10), borderRadius: BorderRadius.circular(9)),
                child: Icon(icon, size: 14, color: color)),
            const SizedBox(width: 8),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: color)),
              Text(label, style: const TextStyle(fontSize: 10, color: kGray)),
            ])),
          ]),
        ),
      );
}

// ── CHW Detail Bottom Sheet ───────────────────────────────────────────────────
class _CHWDetailSheet extends StatelessWidget {
  final Map<String, dynamic> chw;
  const _CHWDetailSheet({required this.chw});

  @override
  Widget build(BuildContext context) {
    final name     = chw['name']                  ?? 'Unknown';
    final location = chw['cell']                  ?? chw['village'] ?? 'N/A';
    final phone    = chw['phone']                 ?? 'N/A';
    final email    = chw['email']                 ?? 'N/A';
    final mothers  = chw['mothers_count']         ?? 0;
    final assess   = chw['assessments_count']     ?? 0;
    final refs     = chw['referrals_count']       ?? 0;
    final highRisk = 0;
    final isActive = (chw['status'] == 'Active' || chw['is_approved'] == true);
    final ini      = initials(name);

    return Container(
      decoration: const BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        // Handle
        Container(width: 36, height: 4, decoration: BoxDecoration(color: kBorder, borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 20),

        // Avatar + name
        Container(width: 60, height: 60,
            decoration: BoxDecoration(color: kTealLight, borderRadius: BorderRadius.circular(18)),
            child: Center(child: Text(ini, style: const TextStyle(color: kTeal, fontSize: 20, fontWeight: FontWeight.w800)))),
        const SizedBox(height: 12),
        Text(name, style: const TextStyle(color: kDarkText, fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        AdminBadge(label: isActive ? 'Active' : 'Inactive', color: isActive ? kGreen : kOrange),
        const SizedBox(height: 20),

        // Stats grid
        Row(children: [
          _SheetStat('Mothers',     '$mothers',  kTeal),
          const SizedBox(width: 10),
          _SheetStat('Assessments', '$assess',   kTealDark),
          const SizedBox(width: 10),
          _SheetStat('Referrals',   '$refs',     kOrange),
          const SizedBox(width: 10),
          _SheetStat('High Risk',   '$highRisk', highRisk > 0 ? kRed : kGray),
        ]),
        const SizedBox(height: 16),
        const Divider(color: kBorder),
        const SizedBox(height: 8),

        // Info rows
        _SheetRow(Icons.location_on_outlined,  'Location', location),
        _SheetRow(Icons.phone_outlined,         'Phone',    phone),
        _SheetRow(Icons.email_outlined,         'Email',    email),
        const SizedBox(height: 12),
      ]),
    );
  }
}

class _SheetStat extends StatelessWidget {
  final String label, value;
  final Color color;
  const _SheetStat(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
          child: Column(children: [
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 10, color: kGray), textAlign: TextAlign.center),
          ]),
        ),
      );
}

class _SheetRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _SheetRow(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(children: [
          Container(width: 34, height: 34,
              decoration: BoxDecoration(color: kBgPage, borderRadius: BorderRadius.circular(9)),
              child: Icon(icon, size: 16, color: kGray)),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: const TextStyle(color: kGray, fontSize: 11)),
            const SizedBox(height: 1),
            Text(value, style: const TextStyle(color: kDarkText, fontSize: 13, fontWeight: FontWeight.w600)),
          ]),
        ]),
      );
}

// ── Performance Table ─────────────────────────────────────────────────────────
class _PerformanceTable extends StatelessWidget {
  final List<dynamic> chws;
  const _PerformanceTable({required this.chws});

  @override
  Widget build(BuildContext context) {
    if (chws.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: kWhite,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: kBorder, width: 1.2),
        ),
        child: const Center(
          child: Text('No performance data available', style: TextStyle(color: kGray, fontSize: 12)),
        ),
      );
    }

    final sorted = List<dynamic>.from(chws)..sort((a, b) => 
      ((b['total_mothers'] ?? b['mothers_count'] ?? 0) as int).compareTo((a['total_mothers'] ?? a['mothers_count'] ?? 0) as int));
    final top = sorted.take(10).toList();

    return Container(
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorder, width: 1.2),
      ),
      child: Column(children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: kTealLight,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(13)),
          ),
          child: Row(children: [
            const SizedBox(width: 32),
            const Expanded(flex: 3, child: Text('CHW', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: kTeal))),
            const Expanded(child: Text('Mothers', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: kTeal))),
            const Expanded(child: Text('Assess.', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: kTeal))),
            const Expanded(child: Text('Refs', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: kTeal))),
            const Expanded(child: Text('High Risk', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: kTeal))),
          ]),
        ),
        ...top.asMap().entries.map((e) {
          final i = e.key;
          final c = e.value;
          final hr = (c['high_risk_mothers'] ?? c['high_risk_cases'] ?? 0) as int;
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: i.isEven ? kBgPage.withOpacity(0.3) : kWhite,
              borderRadius: i == top.length - 1 ? const BorderRadius.vertical(bottom: Radius.circular(13)) : null,
            ),
            child: Row(children: [
              SizedBox(width: 32, child: Center(child: _RankBadge(i + 1))),
              Expanded(flex: 3, child: Text(c['chw_name'] ?? c['name'] ?? 'Unknown', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: kDarkText), maxLines: 1, overflow: TextOverflow.ellipsis)),
              Expanded(child: Text('${c['total_mothers'] ?? c['mothers_count'] ?? 0}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: kGray))),
              Expanded(child: Text('${c['total_assessments'] ?? c['assessments_count'] ?? 0}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: kGray))),
              Expanded(child: Text('${c['total_referrals'] ?? c['referrals_count'] ?? 0}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: kGray))),
              Expanded(child: Text('$hr', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: hr > 0 ? kRed : kGray))),
            ]),
          );
        }),
      ]),
    );
  }
}

class _RankBadge extends StatelessWidget {
  final int rank;
  const _RankBadge(this.rank);
  @override
  Widget build(BuildContext context) {
    if (rank == 1) return const Text('🥇', style: TextStyle(fontSize: 16));
    if (rank == 2) return const Text('🥈', style: TextStyle(fontSize: 16));
    if (rank == 3) return const Text('🥉', style: TextStyle(fontSize: 16));
    return Text('$rank', style: const TextStyle(fontSize: 12, color: kGray, fontWeight: FontWeight.w600));
  }
}
