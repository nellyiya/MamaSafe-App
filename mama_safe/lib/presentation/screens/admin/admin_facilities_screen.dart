import 'package:flutter/material.dart';
import '../../../services/api_service.dart';
import 'admin_shared.dart';

class AdminFacilitiesScreen extends StatefulWidget {
  const AdminFacilitiesScreen({super.key});
  @override
  State<AdminFacilitiesScreen> createState() => _AdminFacilitiesScreenState();
}

class _AdminFacilitiesScreenState extends State<AdminFacilitiesScreen> {
  final _api = ApiService();
  List<dynamic> _all = [];
  bool _loading      = true;
  String _search     = '';

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await _api.getFacilities();
      setState(() { _all = data; _loading = false; });
    } catch (e) { setState(() => _loading = false); }
  }

  List<dynamic> get _filtered => _all.where((f) {
    if (_search.isEmpty) return true;
    final q = _search.toLowerCase();
    return (f['name']     ?? '').toString().toLowerCase().contains(q) ||
           (f['location'] ?? '').toString().toLowerCase().contains(q) ||
           (f['cell']     ?? '').toString().toLowerCase().contains(q);
  }).toList();

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    return AdminPage(
      title: 'Health Facilities',
      subtitle: 'Facilities connected to MamaSafe',
      icon: Icons.local_hospital_rounded,
      headerActions: [
        GhostBtn(icon: Icons.refresh_rounded, tooltip: 'Refresh', onTap: _load),
        const SizedBox(width: 8),
        GhostBtn(icon: Icons.add_rounded, tooltip: 'Add Facility', onTap: () => _showForm(null)),
      ],
      body: _loading
          ? const AdminLoading()
          : RefreshIndicator(
              color: kTeal,
              onRefresh: _load,
              child: Column(children: [
                const SizedBox(height: 8),
                const Divider(color: kBorder, height: 1),

                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: Text('${filtered.length} facilit${filtered.length == 1 ? 'y' : 'ies'}',
                      style: const TextStyle(color: kGray, fontSize: 13, fontWeight: FontWeight.w500)),
                ),

                // ── List ──────────────────────────────────────
                Expanded(
                  child: filtered.isEmpty
                      ? const AdminEmpty(message: 'No facilities found', icon: Icons.local_hospital_outlined)
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                          itemCount: filtered.length,
                          itemBuilder: (_, i) => _FacilityCard(
                            facility: filtered[i],
                            onEdit:   () => _showForm(filtered[i]),
                            onDelete: () => _confirmDelete(filtered[i]),
                          ),
                        ),
                ),
              ]),
            ),
    );
  }

  void _showForm(Map<String, dynamic>? facility) {
    final isEdit = facility != null;
    final nameCtrl = TextEditingController(text: facility?['name'] ?? '');
    final locCtrl  = TextEditingController(text: facility?['location'] ?? '');
    final cellCtrl = TextEditingController(text: facility?['cell'] ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: kWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(isEdit ? 'Edit Facility' : 'Add Facility',
            style: const TextStyle(color: kDarkText, fontSize: 17, fontWeight: FontWeight.w700)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          _Field(ctrl: nameCtrl, label: 'Facility Name', icon: Icons.local_hospital_outlined),
          const SizedBox(height: 12),
          _Field(ctrl: locCtrl,  label: 'Location',      icon: Icons.location_on_outlined),
          const SizedBox(height: 12),
          _Field(ctrl: cellCtrl, label: 'Cell / Zone',   icon: Icons.map_outlined),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(foregroundColor: kGray),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(isEdit ? 'Facility updated' : 'Facility added'), backgroundColor: kTeal));
            },
            style: ElevatedButton.styleFrom(backgroundColor: kTeal, foregroundColor: kWhite,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: Text(isEdit ? 'Save Changes' : 'Add Facility'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(Map<String, dynamic> facility) => showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: kWhite,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Delete Facility', style: TextStyle(color: kDarkText, fontSize: 17, fontWeight: FontWeight.w700)),
          content: Text('Remove "${facility['name'] ?? 'this facility'}" from MamaSafe?', style: const TextStyle(color: kGray)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(foregroundColor: kGray),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Facility deleted'), backgroundColor: kRed));
              },
              style: ElevatedButton.styleFrom(backgroundColor: kRed, foregroundColor: kWhite,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              child: const Text('Delete'),
            ),
          ],
        ),
      );
}

// ── Facility Card ─────────────────────────────────────────────────────────────
class _FacilityCard extends StatelessWidget {
  final Map<String, dynamic> facility;
  final VoidCallback onEdit, onDelete;
  const _FacilityCard({required this.facility, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final name  = facility['name']                    ?? 'Unknown';
    final loc   = facility['location']                ?? 'N/A';
    final cell  = facility['cell']                    ?? '';
    final pros  = facility['assigned_professionals']  ?? 0;
    final active = (facility['is_active']             ?? true) as bool;

    return Container(
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
          Row(children: [
            Container(
              width: 46, height: 46,
              decoration: BoxDecoration(color: kTealLight, borderRadius: BorderRadius.circular(13)),
              child: const Icon(Icons.local_hospital_rounded, color: kTeal, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name, style: const TextStyle(color: kDarkText, fontSize: 14, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 3),
              Row(children: [
                const Icon(Icons.location_on_outlined, size: 12, color: kGray),
                const SizedBox(width: 4),
                Expanded(child: Text(cell.isNotEmpty ? '$loc · $cell' : loc,
                    style: const TextStyle(color: kGray, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis)),
              ]),
            ])),
            Row(children: [
              AdminBadge(label: active ? 'Active' : 'Inactive', color: active ? kGreen : kOrange),
              const SizedBox(width: 8),
              GestureDetector(onTap: onEdit,
                  child: Container(padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(color: kTealLight, borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.edit_outlined, size: 14, color: kTeal))),
              const SizedBox(width: 6),
              GestureDetector(onTap: onDelete,
                  child: Container(padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(color: kRed.withOpacity(0.09), borderRadius: BorderRadius.circular(8)),
                      child: Icon(Icons.delete_outline, size: 14, color: kRed))),
            ]),
          ]),
          const SizedBox(height: 10),
          const Divider(color: kBorder, height: 1),
          const SizedBox(height: 10),
          Row(children: [
            const Icon(Icons.medical_services_outlined, size: 13, color: kGray),
            const SizedBox(width: 6),
            Text('$pros assigned professional${pros == 1 ? '' : 's'}',
                style: const TextStyle(color: kGray, fontSize: 12, fontWeight: FontWeight.w500)),
          ]),
        ]),
      ),
    );
  }
}

class _FacStat extends StatelessWidget {
  final String label;
  final int count, pros;
  final Color color;
  const _FacStat(this.label, this.count, this.pros, this.color);

  // ignore: unused_element
  String get _countStr => '$count';

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withOpacity(0.20), width: 1.2),
          ),
          child: Row(children: [
            Container(padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                child: Icon(Icons.local_hospital_rounded, size: 16, color: color)),
            const SizedBox(width: 10),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('$count', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: color)),
              Text(label, style: const TextStyle(fontSize: 10.5, color: kGray)),
              Text('$pros total professionals', style: const TextStyle(fontSize: 10, color: kGray)),
            ]),
          ]),
        ),
      );
}

class _ActivePanel extends StatelessWidget {
  final List<dynamic> all;
  const _ActivePanel(this.all);

  @override
  Widget build(BuildContext context) {
    final active = all.where((f) => (f['is_active'] ?? true) as bool).length;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        decoration: BoxDecoration(
          color: kWhite,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: kBorder, width: 1.2),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(children: [
          Container(padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: kGreen.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.check_circle_outline, size: 16, color: kGreen)),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('$active', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: kGreen)),
            const Text('Active', style: TextStyle(fontSize: 10.5, color: kGray)),
            const Text('Currently operating', style: TextStyle(fontSize: 10, color: kGray)),
          ]),
        ]),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final IconData icon;
  const _Field({required this.ctrl, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) => TextField(
        controller: ctrl,
        style: const TextStyle(color: kDarkText, fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: kGray, fontSize: 13),
          prefixIcon: Icon(icon, size: 18, color: kGray),
          filled: true,
          fillColor: kBgPage,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kBorder)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kBorder, width: 1.2)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kTeal, width: 1.5)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      );
}
