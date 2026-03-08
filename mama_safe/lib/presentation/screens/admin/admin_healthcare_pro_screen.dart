import 'package:flutter/material.dart';
import '../../../services/api_service.dart';
import 'admin_shared.dart';

class AdminHealthcareProScreen extends StatefulWidget {
  const AdminHealthcareProScreen({super.key});
  @override
  State<AdminHealthcareProScreen> createState() => _AdminHealthcareProScreenState();
}

class _AdminHealthcareProScreenState extends State<AdminHealthcareProScreen> {
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
      final data = await _api.getHealthcareProfessionals();
      setState(() { _all = data; _performance = data; _loading = false; });
    } catch (e) { 
      print('Error loading healthcare pros: $e');
      setState(() => _loading = false); 
    }
  }

  List<dynamic> get _filtered => _all.where((p) {
    final active = (p['status'] == 'Active' || p['is_approved'] == true);
    if (_filter == 'Active'   && !active) return false;
    if (_filter == 'Inactive' &&  active) return false;
    if (_search.isNotEmpty) {
      final q = _search.toLowerCase();
      return (p['name']     ?? '').toString().toLowerCase().contains(q) ||
             (p['facility'] ?? '').toString().toLowerCase().contains(q);
    }
    return true;
  }).toList();

  int _cnt(String f) {
    if (f == 'All')      return _all.length;
    if (f == 'Active')   return _all.where((p) => p['status'] == 'Active' || p['is_approved'] == true).length;
    return                      _all.where((p) => p['status'] != 'Active' && p['is_approved'] != true).length;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    return AdminPage(
      title: 'Healthcare Professionals',
      subtitle: 'Doctors, nurses & specialists',
      icon: Icons.medical_services_rounded,
      headerActions: [
        GhostBtn(icon: Icons.refresh_rounded, tooltip: 'Refresh', onTap: _load),
        const SizedBox(width: 8),
        GhostBtn(icon: Icons.person_add_outlined, tooltip: 'Add Professional', onTap: _showAdd),
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
                  child: AdminSearchBar(hint: 'Search professionals…', onChanged: (v) => setState(() => _search = v), query: _search),
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

                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: Text('${filtered.length} professional${filtered.length == 1 ? '' : 's'}',
                      style: const TextStyle(color: kGray, fontSize: 13, fontWeight: FontWeight.w500)),
                ),

                // ── List ──────────────────────────────────────
                Expanded(
                  child: filtered.isEmpty
                      ? const AdminEmpty(message: 'No professionals found', icon: Icons.medical_services_outlined)
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                          itemCount: filtered.length,
                          itemBuilder: (_, i) {
                            final p          = filtered[i];
                            final name       = p['name']             ?? 'Unknown';
                            final spec       = 'Healthcare Professional';
                            final facility   = p['facility']         ?? 'N/A';
                            final phone      = p['phone']            ?? 'N/A';
                            final refs       = p['referrals_count']  ?? 0;
                            final handled    = p['completed_count']  ?? 0;
                            final pending    = refs - handled;
                            final isActive   = (p['status'] == 'Active' || p['is_approved'] == true);
                            final ini        = initials(name);

                            return GestureDetector(
                              onTap: () => _showDetail(p),
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
                                    // Top row
                                    Row(children: [
                                      Container(
                                        width: 46, height: 46,
                                        decoration: BoxDecoration(color: kNavy.withOpacity(0.10), borderRadius: BorderRadius.circular(13)),
                                        child: Center(child: Text(ini, style: const TextStyle(color: kNavy, fontSize: 15, fontWeight: FontWeight.w800))),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                        Text(name, style: const TextStyle(color: kDarkText, fontSize: 14, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                                        const SizedBox(height: 2),
                                        Text(spec, style: const TextStyle(color: kTeal, fontSize: 12, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
                                        const SizedBox(height: 2),
                                        Row(children: [
                                          const Icon(Icons.local_hospital_outlined, size: 11, color: kGray),
                                          const SizedBox(width: 4),
                                          Expanded(child: Text(facility, style: const TextStyle(color: kGray, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis)),
                                        ]),
                                      ])),
                                      AdminBadge(label: isActive ? 'Active' : 'Inactive', color: isActive ? kGreen : kOrange),
                                    ]),

                                    const SizedBox(height: 10),
                                    const Divider(color: kBorder, height: 1),
                                    const SizedBox(height: 10),

                                    // Stats
                                    Row(children: [
                                      _ProMetric('Referrals',  '$refs',    kTeal),
                                      const SizedBox(width: 8),
                                      _ProMetric('Handled',    '$handled', kGreen),
                                      const SizedBox(width: 8),
                                      _ProMetric('Pending',    '$pending', kOrange),
                                      const SizedBox(width: 8),
                                      Row(children: [
                                        const Icon(Icons.phone_outlined, size: 12, color: kGray),
                                        const SizedBox(width: 4),
                                        Text(phone, style: const TextStyle(color: kGray, fontSize: 11)),
                                      ]),
                                    ]),
                                  ]),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ]),
            ),
    );
  }

  void _showDetail(Map<String, dynamic> pro) => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => _ProDetailSheet(pro: pro),
      );

  void _showAdd() => showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: kWhite,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Add Professional', style: TextStyle(color: kDarkText, fontSize: 17, fontWeight: FontWeight.w700)),
          content: const Text('Professional registration form coming soon.', style: TextStyle(color: kGray)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(foregroundColor: kGray),
                child: const Text('Close')),
          ],
        ),
      );
}

class _ProStat extends StatelessWidget {
  final String label, value;
  final Color color;
  final IconData icon;
  const _ProStat(this.label, this.value, this.color, this.icon);

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
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: color)),
              Text(label, style: const TextStyle(fontSize: 10, color: kGray)),
            ]),
          ]),
        ),
      );
}

class _ProMetric extends StatelessWidget {
  final String label, value;
  final Color color;
  const _ProMetric(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(color: color.withOpacity(0.07), borderRadius: BorderRadius.circular(9)),
          child: Column(children: [
            Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: color)),
            Text(label, style: const TextStyle(fontSize: 9.5, color: kGray), textAlign: TextAlign.center),
          ]),
        ),
      );
}

class _ProDetailSheet extends StatelessWidget {
  final Map<String, dynamic> pro;
  const _ProDetailSheet({required this.pro});

  @override
  Widget build(BuildContext context) {
    final name     = pro['name']               ?? 'Unknown';
    final spec     = 'Healthcare Professional';
    final facility = pro['facility']           ?? 'N/A';
    final phone    = pro['phone']              ?? 'N/A';
    final email    = pro['email']              ?? 'N/A';
    final refs     = pro['referrals_count']    ?? 0;
    final handled  = pro['completed_count']    ?? 0;
    final pending  = refs - handled;
    final isActive = (pro['status'] == 'Active' || pro['is_approved'] == true);
    final ini      = initials(name);

    return Container(
      decoration: const BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 36, height: 4, decoration: BoxDecoration(color: kBorder, borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 20),
        Container(width: 60, height: 60,
            decoration: BoxDecoration(color: kNavy.withOpacity(0.10), borderRadius: BorderRadius.circular(18)),
            child: Center(child: Text(ini, style: const TextStyle(color: kNavy, fontSize: 20, fontWeight: FontWeight.w800)))),
        const SizedBox(height: 10),
        Text(name, style: const TextStyle(color: kDarkText, fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(height: 2),
        Text(spec, style: const TextStyle(color: kTeal, fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        AdminBadge(label: isActive ? 'Active' : 'Inactive', color: isActive ? kGreen : kOrange),
        const SizedBox(height: 18),
        Row(children: [
          _SheetMetric('Referrals', '$refs',    kTeal),
          const SizedBox(width: 10),
          _SheetMetric('Handled',   '$handled', kGreen),
          const SizedBox(width: 10),
          _SheetMetric('Pending',   '$pending', kOrange),
        ]),
        const SizedBox(height: 16),
        const Divider(color: kBorder),
        const SizedBox(height: 8),
        _Row(Icons.local_hospital_outlined, 'Facility', facility),
        _Row(Icons.phone_outlined,          'Phone',    phone),
        _Row(Icons.email_outlined,          'Email',    email),
        const SizedBox(height: 12),
      ]),
    );
  }
}

class _SheetMetric extends StatelessWidget {
  final String label, value;
  final Color color;
  const _SheetMetric(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
          child: Column(children: [
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color)),
            Text(label, style: const TextStyle(fontSize: 10, color: kGray)),
          ]),
        ),
      );
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _Row(this.icon, this.label, this.value);

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
            Text(value, style: const TextStyle(color: kDarkText, fontSize: 13, fontWeight: FontWeight.w600)),
          ]),
        ]),
      );
}

// ── Performance Table ─────────────────────────────────────────────────────────
class _PerformanceTable extends StatelessWidget {
  final List<dynamic> pros;
  const _PerformanceTable({required this.pros});

  @override
  Widget build(BuildContext context) {
    if (pros.isEmpty) {
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

    final sorted = List<dynamic>.from(pros)..sort((a, b) => 
      ((b['total_referrals'] ?? b['referrals_count'] ?? 0) as int).compareTo((a['total_referrals'] ?? a['referrals_count'] ?? 0) as int));
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
            const Expanded(flex: 3, child: Text('Professional', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: kTeal))),
            const Expanded(child: Text('Referrals', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: kTeal))),
            const Expanded(child: Text('Handled', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: kTeal))),
            const Expanded(child: Text('Pending', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: kTeal))),
          ]),
        ),
        ...top.asMap().entries.map((e) {
          final i = e.key;
          final p = e.value;
          final pending = (p['pending_cases'] ?? p['pending_referrals'] ?? 0) as int;
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: i.isEven ? kBgPage.withOpacity(0.3) : kWhite,
              borderRadius: i == top.length - 1 ? const BorderRadius.vertical(bottom: Radius.circular(13)) : null,
            ),
            child: Row(children: [
              SizedBox(width: 32, child: Center(child: _RankBadge(i + 1))),
              Expanded(flex: 3, child: Text(p['facility'] ?? p['name'] ?? 'Unknown', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: kDarkText), maxLines: 1, overflow: TextOverflow.ellipsis)),
              Expanded(child: Text('${p['total_referrals'] ?? p['referrals_count'] ?? 0}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: kGray))),
              Expanded(child: Text('${p['completed_cases'] ?? p['completed_count'] ?? 0}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: kGreen))),
              Expanded(child: Text('$pending', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: pending > 0 ? kOrange : kGray))),
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
