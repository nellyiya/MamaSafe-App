import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../services/api_service.dart';
import 'admin_shared.dart';

class AdminReferralsScreen extends StatefulWidget {
  const AdminReferralsScreen({super.key});
  @override
  State<AdminReferralsScreen> createState() => _AdminReferralsScreenState();
}

class _AdminReferralsScreenState extends State<AdminReferralsScreen> {
  final _api = ApiService();
  List<dynamic> _all = [];
  bool _loading      = true;
  String _filter     = 'All';
  String _search     = '';

  static const _filters = ['All', 'Pending', 'Approved', 'Emergency', 'Rejected'];

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await _api.getReferrals();
      setState(() { _all = data; _loading = false; });
    } catch (e) { setState(() => _loading = false); }
  }

  List<dynamic> get _filtered => _all.where((r) {
    final status = (r['status'] ?? '').toString().toLowerCase();
    if (_filter != 'All' && !status.contains(_filter.toLowerCase())) return false;
    if (_search.isNotEmpty) {
      final q = _search.toLowerCase();
      return (r['mother_name']       ?? '').toString().toLowerCase().contains(q) ||
             (r['chw_name']          ?? '').toString().toLowerCase().contains(q) ||
             (r['professional_name'] ?? r['hospital_name'] ?? '').toString().toLowerCase().contains(q);
    }
    return true;
  }).toList();

  int _cnt(String f) {
    if (f == 'All') return _all.length;
    return _all.where((r) => (r['status'] ?? '').toString().toLowerCase().contains(f.toLowerCase())).length;
  }

  String _fmt(String? raw) {
    if (raw == null) return 'N/A';
    try { return DateFormat('MMM dd, yyyy • hh:mm a').format(DateTime.parse(raw)); } catch (_) { return raw; }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    return AdminPage(
      title: 'Referrals',
      subtitle: 'CHW to healthcare professional referrals',
      icon: Icons.share_outlined,
      headerActions: [
        GhostBtn(icon: Icons.refresh_rounded, tooltip: 'Refresh', onTap: _load),
        const SizedBox(width: 8),
        GhostBtn(icon: Icons.file_download_outlined, tooltip: 'Export', onTap: _showExport),
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
                  child: AdminSearchBar(hint: 'Search referrals…', onChanged: (v) => setState(() => _search = v), query: _search),
                ),

                // ── Filter chips ──────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                  child: AdminFilterChips(
                    labels: _filters,
                    selected: _filter,
                    onChanged: (v) => setState(() => _filter = v),
                    counts: {for (final f in _filters) f: _cnt(f)},
                    dotColors: {'Pending': kOrange, 'Approved': kGreen, 'Emergency': kRed, 'Rejected': kGray},
                  ),
                ),
                const SizedBox(height: 8),
                const Divider(color: kBorder, height: 1),

                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: Text('${filtered.length} referral${filtered.length == 1 ? '' : 's'}',
                      style: const TextStyle(color: kGray, fontSize: 13, fontWeight: FontWeight.w500)),
                ),

                // ── List ──────────────────────────────────────
                Expanded(
                  child: filtered.isEmpty
                      ? const AdminEmpty(message: 'No referrals found', icon: Icons.share_outlined)
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                          itemCount: filtered.length,
                          itemBuilder: (_, i) {
                            final r        = filtered[i];
                            final mother   = r['mother_name']       ?? 'Unknown';
                            final chw      = r['chw_name']          ?? 'N/A';
                            final pro      = r['professional_name'] ?? r['hospital_name'] ?? 'N/A';
                            final risk     = r['risk_level']        ?? 'Low';
                            final status   = r['status']            ?? 'Pending';
                            final notes    = r['notes']             ?? '';
                            final date     = _fmt(r['created_at']   ?? r['referral_date']);
                            final rColor   = riskColor(risk);
                            final sColor   = statusColor(status);
                            final ini      = initials(mother);

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: kWhite,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: status.toLowerCase() == 'emergency' ? kRed.withOpacity(0.4) : kBorder,
                                  width: status.toLowerCase() == 'emergency' ? 1.8 : 1.2,
                                ),
                                boxShadow: [BoxShadow(
                                  color: status.toLowerCase() == 'emergency'
                                      ? kRed.withOpacity(0.08)
                                      : Colors.black.withOpacity(0.03),
                                  blurRadius: 8, offset: const Offset(0, 2),
                                )],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  // Top row
                                  Row(children: [
                                    Container(
                                      width: 46, height: 46,
                                      decoration: BoxDecoration(color: rColor.withOpacity(0.12), borderRadius: BorderRadius.circular(13)),
                                      child: Center(child: Text(ini, style: TextStyle(color: rColor, fontSize: 15, fontWeight: FontWeight.w800))),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      Text(mother, style: const TextStyle(color: kDarkText, fontSize: 14, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                                      const SizedBox(height: 3),
                                      Row(children: [
                                        AdminBadge(label: '${riskLabel(risk)} Risk', color: rColor),
                                        const SizedBox(width: 6),
                                        AdminBadge(label: status, color: sColor),
                                      ]),
                                    ])),
                                  ]),

                                  const SizedBox(height: 10),
                                  const Divider(color: kBorder, height: 1),
                                  const SizedBox(height: 10),

                                  // Flow: CHW → Professional
                                  Row(children: [
                                    const Icon(Icons.person_pin_outlined, size: 13, color: kGray),
                                    const SizedBox(width: 5),
                                    Expanded(child: Text(chw, style: const TextStyle(color: kGray, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis)),
                                    const Icon(Icons.arrow_forward_rounded, size: 13, color: kGray),
                                    const SizedBox(width: 5),
                                    const Icon(Icons.medical_services_outlined, size: 13, color: kTeal),
                                    const SizedBox(width: 5),
                                    Expanded(child: Text(pro, style: const TextStyle(color: kTeal, fontSize: 12, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis)),
                                  ]),

                                  if (notes.isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      const Icon(Icons.notes_rounded, size: 12, color: kGray),
                                      const SizedBox(width: 5),
                                      Expanded(child: Text(notes, style: const TextStyle(color: kGray, fontSize: 11), maxLines: 2, overflow: TextOverflow.ellipsis)),
                                    ]),
                                  ],

                                  const SizedBox(height: 6),
                                  Row(children: [
                                    const Icon(Icons.access_time_rounded, size: 12, color: kGray),
                                    const SizedBox(width: 4),
                                    Text(date, style: const TextStyle(color: kGray, fontSize: 11)),
                                  ]),
                                ]),
                              ),
                            );
                          },
                        ),
                ),
              ]),
            ),
    );
  }

  void _showExport() => showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: kWhite,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Export Referrals', style: TextStyle(color: kDarkText, fontSize: 17, fontWeight: FontWeight.w700)),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            for (final f in ['CSV', 'Excel', 'PDF'])
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: kTealLight, borderRadius: BorderRadius.circular(10)),
                  child: Icon(f == 'CSV' ? Icons.table_chart_rounded : f == 'Excel' ? Icons.description_rounded : Icons.picture_as_pdf_rounded,
                      color: kTeal, size: 20),
                ),
                title: Text(f, style: const TextStyle(color: kDarkText, fontSize: 14, fontWeight: FontWeight.w500)),
                trailing: const Icon(Icons.chevron_right_rounded, color: kGray, size: 20),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Exporting referrals as $f...'), backgroundColor: kTeal));
                },
              ),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(foregroundColor: kGray),
                child: const Text('Cancel')),
          ],
        ),
      );
}

// ── Referral Stat ─────────────────────────────────────────────────────────────
class _RefStat extends StatelessWidget {
  final String label, value;
  final Color color;
  const _RefStat(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: color.withOpacity(0.20), width: 1.2),
          ),
          child: Column(children: [
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 10, color: kGray)),
          ]),
        ),
      );
}
