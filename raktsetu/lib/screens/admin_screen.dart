import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:raktsetu/lib/database/dataset_helper.dart';
// ignore: unused_import
import 'package:raktsetu/lib/database/database_helper.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen>
    with SingleTickerProviderStateMixin {
  final db = DatabaseHelper.instance;
  late TabController _tabController;

  List<Map<String, dynamic>> donors = [];
  List<Map<String, dynamic>> requests = [];
  List<Map<String, dynamic>> inventory = [];
  List<Map<String, dynamic>> hospitals = [];
  Map<String, dynamic> stats = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    loadAll();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> loadAll() async {
    setState(() => isLoading = true);
    final d = await db.getAllDonors();
    final r = await db.getAllRequests();
    final i = await db.getAllInventory();
    final h = await db.getHospitals();
    final s = await db.getDashboardStats();
    setState(() {
      donors = d;
      requests = r;
      inventory = i;
      hospitals = h;
      stats = s;
      isLoading = false;
    });
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Urgent':
        return const Color(0xFFE53935);
      case 'Pending':
        return const Color(0xFFE65100);
      case 'Fulfilled':
        return const Color(0xFF2E7D32);
      default:
        return Colors.grey;
    }
  }

  Color _unitColor(int units) {
    if (units <= 3) return const Color(0xFFE53935);
    if (units <= 7) return const Color(0xFFE65100);
    return const Color(0xFF2E7D32);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Admin Panel'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: loadAll,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle:
              GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 12),
          tabs: const [
            Tab(icon: Icon(Icons.people, size: 18), text: 'Donors'),
            Tab(icon: Icon(Icons.emergency, size: 18), text: 'Requests'),
            Tab(icon: Icon(Icons.water_drop, size: 18), text: 'Inventory'),
          ],
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFE53935)))
          : Column(
              children: [
                // STATS SUMMARY BAR
                Container(
                  color: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _MiniStat(
                        label: 'Donors',
                        value: '${stats['totalDonors']}',
                        color: const Color(0xFF1565C0),
                      ),
                      _MiniStat(
                        label: 'Available',
                        value: '${stats['availableDonors']}',
                        color: const Color(0xFF2E7D32),
                      ),
                      _MiniStat(
                        label: 'Units',
                        value: '${stats['totalUnits']}',
                        color: const Color(0xFFE53935),
                      ),
                      _MiniStat(
                        label: 'Pending',
                        value: '${stats['pendingRequests']}',
                        color: const Color(0xFFE65100),
                      ),
                      _MiniStat(
                        label: 'Urgent',
                        value: '${stats['urgentRequests']}',
                        color: const Color(0xFFB71C1C),
                      ),
                    ],
                  ),
                ),

                // TABS
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // ===== DONORS TAB =====
                      RefreshIndicator(
                        onRefresh: loadAll,
                        color: const Color(0xFFE53935),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: donors.length,
                          itemBuilder: (context, index) {
                            final d = donors[index];
                            final isAvailable = d['is_available'] == 1;
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: isAvailable
                                      ? const Color(0xFFE53935)
                                      : Colors.grey[400],
                                  child: Text(
                                    d['blood_group'],
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                                title: Text(d['name'],
                                    style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14)),
                                subtitle: Text(
                                    '${d['city']} • Age ${d['age']} • ${d['phone']}',
                                    style: GoogleFonts.poppins(
                                        fontSize: 11, color: Colors.grey[600])),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isAvailable
                                        ? const Color(0xFFE8F5E9)
                                        : const Color(0xFFFFEBEE),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    isAvailable ? 'Available' : 'Unavailable',
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: isAvailable
                                          ? const Color(0xFF2E7D32)
                                          : const Color(0xFFE53935),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // ===== REQUESTS TAB =====
                      RefreshIndicator(
                        onRefresh: loadAll,
                        color: const Color(0xFFE53935),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: requests.length,
                          itemBuilder: (context, index) {
                            final r = requests[index];
                            final statusColor = _statusColor(r['status']);
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: const Color(0xFFE53935),
                                  child: Text(
                                    r['blood_group'],
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                                title: Text(r['hospital_name'] ?? 'Hospital',
                                    style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14)),
                                subtitle: Text(
                                    '${r['units_needed']} units • ${r['city']}',
                                    style: GoogleFonts.poppins(
                                        fontSize: 11, color: Colors.grey[600])),
                                trailing: PopupMenuButton<String>(
                                  onSelected: (value) async {
                                    await db.updateRequestStatus(
                                        r['id'], value);
                                    loadAll();
                                  },
                                  itemBuilder: (_) =>
                                      ['Pending', 'Urgent', 'Fulfilled']
                                          .map((s) => PopupMenuItem(
                                                value: s,
                                                child: Text(s,
                                                    style: GoogleFonts.poppins(
                                                        fontSize: 13)),
                                              ))
                                          .toList(),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: statusColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color: statusColor.withOpacity(0.4)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          r['status'],
                                          style: GoogleFonts.poppins(
                                            fontSize: 10,
                                            color: statusColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Icon(Icons.arrow_drop_down,
                                            size: 16, color: statusColor),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // ===== INVENTORY TAB =====
                      RefreshIndicator(
                        onRefresh: loadAll,
                        color: const Color(0xFFE53935),
                        child: ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            // LOW STOCK WARNING
                            ...inventory.where((i) {
                              final units = i['total_units'] is int
                                  ? i['total_units'] as int
                                  : (i['total_units'] as num).toInt();
                              return units <= 3;
                            }).map((i) => Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFEBEE),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: const Color(0xFFE53935)),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.warning_amber_rounded,
                                          color: Color(0xFFE53935), size: 18),
                                      const SizedBox(width: 8),
                                      Text(
                                        '⚠ Low Stock: ${i['blood_group']} in ${i['city']} — only ${i['total_units']} units left!',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: const Color(0xFFE53935),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                )),

                            const SizedBox(height: 8),

                            // INVENTORY BY CITY
                            ...[
                              'Ahmedabad',
                              'Surat',
                              'Vadodara',
                              'Gandhinagar',
                              'Rajkot'
                            ].map((city) {
                              final cityItems = inventory
                                  .where((i) => i['city'] == city)
                                  .toList();
                              if (cityItems.isEmpty) return const SizedBox();
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.location_on,
                                              color: Color(0xFFE53935),
                                              size: 16),
                                          const SizedBox(width: 4),
                                          Text(city,
                                              style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 15)),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      ...cityItems.map((item) {
                                        final units = item['total_units'] is int
                                            ? item['total_units'] as int
                                            : (item['total_units'] as num)
                                                .toInt();
                                        final color = _unitColor(units);
                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 8),
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 48,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: color.withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  item['blood_group'],
                                                  textAlign: TextAlign.center,
                                                  style: GoogleFonts.poppins(
                                                    fontWeight: FontWeight.w700,
                                                    color: color,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: LinearProgressIndicator(
                                                  value: units / 20,
                                                  backgroundColor:
                                                      Colors.grey[200],
                                                  color: color,
                                                  minHeight: 8,
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Text(
                                                '$units units',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: color,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ],
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

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MiniStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: GoogleFonts.poppins(
                fontSize: 20, fontWeight: FontWeight.w700, color: color)),
        Text(label,
            style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey[600])),
      ],
    );
  }
}
