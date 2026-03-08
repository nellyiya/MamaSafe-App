import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../services/api_service.dart';
import 'admin_shared.dart';

class AdminAppointmentsScreen extends StatefulWidget {
  const AdminAppointmentsScreen({super.key});
  @override
  State<AdminAppointmentsScreen> createState() =>
      _AdminAppointmentsScreenState();
}

class _AdminAppointmentsScreenState extends State<AdminAppointmentsScreen> {
  final _api = ApiService();
  List<dynamic> _all = [];
  bool _loading = true;
  String _filter = 'All';
  String _search = '';

  static const _filters = ['All', 'Scheduled', 'Completed', 'Cancelled'];

  // ── LOGIC: 100% unchanged ────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final a = await _api.getAppointments();
      setState(() {
        _all = a;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }
  // ── END LOGIC ────────────────────────────────────────────────────

  // Fix raw timestamp → clean readable date
  String _fmt(String? raw) {
    if (raw == null || raw == 'N/A') return 'N/A';
    try {
      return DateFormat('MMM dd, yyyy').format(DateTime.parse(raw));
    } catch (_) {
      return raw.length > 10 ? raw.substring(0, 10) : raw;
    }
  }

  String _fmtDay(String? raw) {
    if (raw == null) return '--';
    try {
      return DateFormat('dd').format(DateTime.parse(raw));
    } catch (_) {
      return '--';
    }
  }

  String _fmtMonth(String? raw) {
    if (raw == null) return '---';
    try {
      return DateFormat('MMM').format(DateTime.parse(raw)).toUpperCase();
    } catch (_) {
      return '---';
    }
  }

  List<dynamic> get _filtered => _all.where((a) {
        final status = (a['status'] ?? 'Scheduled').toString().toLowerCase();
        if (_filter != 'All' && !status.contains(_filter.toLowerCase()))
          return false;
        if (_search.isNotEmpty) {
          final q = _search.toLowerCase();
          return (a['mother']?['name'] ?? '')
                  .toString()
                  .toLowerCase()
                  .contains(q) ||
              (a['hospital'] ?? '').toString().toLowerCase().contains(q);
        }
        return true;
      }).toList();

  int _cnt(String f) {
    if (f == 'All') return _all.length;
    return _all
        .where((a) => (a['status'] ?? 'Scheduled')
            .toString()
            .toLowerCase()
            .contains(f.toLowerCase()))
        .length;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final scheduled = _cnt('Scheduled');
    final completed = _cnt('Completed');
    final cancelled = _cnt('Cancelled');

    return AdminPage(
      title: 'Appointments',
      subtitle: '${_all.length} total appointments',
      icon: Icons.calendar_today_rounded,
      headerActions: [
        GhostBtn(icon: Icons.refresh_rounded, tooltip: 'Refresh', onTap: _load),
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
                  child: AdminSearchBar(
                    hint: 'Search by name or hospital…',
                    onChanged: (v) => setState(() => _search = v),
                    query: _search,
                  ),
                ),
                const SizedBox(height: 10),

                // ── Filter chips ──────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: AdminFilterChips(
                    labels: _filters,
                    selected: _filter,
                    onChanged: (v) => setState(() => _filter = v),
                    counts: {for (final f in _filters) f: _cnt(f)},
                    dotColors: {
                      'Scheduled': kTealDark,
                      'Completed': kGreen,
                      'Cancelled': kRed,
                    },
                  ),
                ),
                const SizedBox(height: 8),
                const Divider(color: kBorder, height: 1),

                // ── Count + clear row ─────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: Row(children: [
                    Text(
                        '${filtered.length} appointment${filtered.length == 1 ? '' : 's'}',
                        style: const TextStyle(
                            color: kGray,
                            fontSize: 12,
                            fontWeight: FontWeight.w500)),
                    const Spacer(),
                    if (_filter != 'All')
                      GestureDetector(
                        onTap: () => setState(() => _filter = 'All'),
                        child: const Row(children: [
                          Icon(Icons.close_rounded, size: 12, color: kGray),
                          SizedBox(width: 3),
                          Text('Clear filter',
                              style: TextStyle(
                                  color: kGray,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500)),
                        ]),
                      ),
                  ]),
                ),

                // ── List ──────────────────────────────────────
                Expanded(
                  child: filtered.isEmpty
                      ? const AdminEmpty(
                          message: 'No appointments found',
                          icon: Icons.calendar_today_outlined)
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                          itemCount: filtered.length,
                          itemBuilder: (_, i) {
                            final a = filtered[i];
                            final name = a['mother']?['name'] ?? 'Unknown';
                            final hospital = a['hospital'] ?? 'N/A';
                            final rawDate = a['appointment_date'];
                            final status = a['status'] ?? 'Scheduled';
                            final sColor = statusColor(status);
                            final ini = initials(name);

                            return _AppointmentCard(
                              ini: ini,
                              name: name,
                              hospital: hospital,
                              day: _fmtDay(rawDate),
                              month: _fmtMonth(rawDate),
                              formattedDate: _fmt(rawDate),
                              status: status,
                              sColor: sColor,
                            );
                          },
                        ),
                ),
              ]),
            ),
    );
  }
}

// ── APPOINTMENT CARD ──────────────────────────────────────────────────────────
class _AppointmentCard extends StatelessWidget {
  final String ini, name, hospital, day, month, formattedDate, status;
  final Color sColor;

  const _AppointmentCard({
    required this.ini,
    required this.name,
    required this.hospital,
    required this.day,
    required this.month,
    required this.formattedDate,
    required this.status,
    required this.sColor,
  });

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: kWhite,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: kBorder, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            // ── Date block ─────────────────────────────────
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: kTeal.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kTeal.withOpacity(0.18), width: 1.2),
              ),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(day,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: kTeal,
                            height: 1.1)),
                    Text(month,
                        style: const TextStyle(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w700,
                            color: kTeal,
                            letterSpacing: 0.5)),
                  ]),
            ),
            const SizedBox(width: 12),

            // ── Avatar ─────────────────────────────────────
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                  color: kTealLight, borderRadius: BorderRadius.circular(10)),
              child: Center(
                  child: Text(ini,
                      style: const TextStyle(
                          color: kTeal,
                          fontSize: 13,
                          fontWeight: FontWeight.w800))),
            ),
            const SizedBox(width: 10),

            // ── Name + hospital + date ──────────────────────
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Expanded(
                        child: Text(name,
                            style: const TextStyle(
                                color: kDarkText,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ),
                      const SizedBox(width: 8),
                      AdminBadge(label: status, color: sColor),
                    ]),
                    const SizedBox(height: 4),
                    Row(children: [
                      const Icon(Icons.local_hospital_outlined,
                          size: 11, color: kGray),
                      const SizedBox(width: 3),
                      Expanded(
                          child: Text(hospital,
                              style:
                                  const TextStyle(color: kGray, fontSize: 11),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis)),
                    ]),
                    const SizedBox(height: 3),
                    Row(children: [
                      const Icon(Icons.access_time_rounded,
                          size: 11, color: kGray),
                      const SizedBox(width: 3),
                      Text(formattedDate,
                          style: const TextStyle(color: kGray, fontSize: 11)),
                    ]),
                  ]),
            ),

            const SizedBox(width: 6),
            Icon(Icons.chevron_right_rounded,
                size: 18, color: kGray.withOpacity(0.4)),
          ]),
        ),
      );
}

// ── SUMMARY TILE ─────────────────────────────────────────────────────────────
class _SummaryTile extends StatelessWidget {
  final String label, value;
  final Color color;
  final IconData icon;
  const _SummaryTile(this.label, this.value, this.color, this.icon);

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.07),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.18), width: 1.2),
          ),
          child: Column(children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(7)),
              child: Icon(icon, size: 13, color: color),
            ),
            const SizedBox(height: 5),
            Text(value,
                style: TextStyle(
                    fontSize: 17, fontWeight: FontWeight.w800, color: color)),
            Text(label,
                style: const TextStyle(fontSize: 9.5, color: kGray),
                textAlign: TextAlign.center),
          ]),
        ),
      );
}
