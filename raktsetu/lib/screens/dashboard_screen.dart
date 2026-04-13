import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:raktsetu/lib/database/dataset_helper.dart';
// ignore: unused_import
import '../../lib/database/database_helper.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final db = DatabaseHelper.instance;
  Map<String, dynamic> stats = {};
  List<Map<String, dynamic>> inventory = [];
  List<Map<String, dynamic>> urgentRequests = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() => isLoading = true);
    final s = await db.getDashboardStats();
    final inv = await db.getAllInventory();
    final req = await db.getAllRequests();
    setState(() {
      stats = s;
      inventory = inv;
      urgentRequests = req.where((r) => r['status'] == 'Urgent').toList();
      isLoading = false;
    });
  }

  Color _getUnitColor(int units) {
    if (units <= 3) return Colors.red;
    if (units <= 7) return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFE53935)))
          : RefreshIndicator(
              onRefresh: loadData,
              color: const Color(0xFFE53935),
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: 120,
                    floating: false,
                    pinned: true,
                    backgroundColor: const Color(0xFFE53935),
                    flexibleSpace: FlexibleSpaceBar(
                      title: Text(
                        'RaktSetu 🩸',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 22,
                        ),
                      ),
                      background: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFFE53935), Color(0xFFB71C1C)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                    ),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.refresh, color: Colors.white),
                        onPressed: loadData,
                      ),
                    ],
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // URGENT ALERT BANNER
                          if (urgentRequests.isNotEmpty)
                            Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFEBEE),
                                borderRadius: BorderRadius.circular(12),
                                border:
                                    Border.all(color: const Color(0xFFE53935)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.warning_amber_rounded,
                                      color: Color(0xFFE53935)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '${urgentRequests.length} Urgent blood request(s) need attention!',
                                      style: GoogleFonts.poppins(
                                        color: const Color(0xFFE53935),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // STATS CARDS
                          Text('Overview',
                              style: GoogleFonts.poppins(
                                  fontSize: 18, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 12),
                          GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.5,
                            children: [
                              _StatCard(
                                title: 'Total Donors',
                                value: '${stats['totalDonors']}',
                                icon: Icons.people,
                                color: const Color(0xFF1565C0),
                              ),
                              _StatCard(
                                title: 'Available Now',
                                value: '${stats['availableDonors']}',
                                icon: Icons.volunteer_activism,
                                color: const Color(0xFF2E7D32),
                              ),
                              _StatCard(
                                title: 'Blood Units',
                                value: '${stats['totalUnits']}',
                                icon: Icons.water_drop,
                                color: const Color(0xFFE53935),
                              ),
                              _StatCard(
                                title: 'Urgent Requests',
                                value: '${stats['urgentRequests']}',
                                icon: Icons.emergency,
                                color: const Color(0xFFE65100),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // BLOOD INVENTORY
                          Text('Blood Availability by City',
                              style: GoogleFonts.poppins(
                                  fontSize: 18, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 12),

                          ...[
                            'Ahmedabad',
                            'Surat',
                            'Vadodara',
                            'Gandhinagar',
                            'Rajkot'
                          ].map((city) {
                            final cityInventory = inventory
                                .where((i) => i['city'] == city)
                                .toList();
                            if (cityInventory.isEmpty) {
                              return const SizedBox();
                            }
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.location_on,
                                            color: Color(0xFFE53935), size: 18),
                                        const SizedBox(width: 4),
                                        Text(city,
                                            style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 16)),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: cityInventory.map((item) {
                                        final units = item['total_units'] is int
                                            ? item['total_units'] as int
                                            : (item['total_units'] as num)
                                                .toInt();
                                        return _BloodGroupChip(
                                          bloodGroup: item['blood_group'],
                                          units: units,
                                          color: _getUnitColor(units),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),

                          const SizedBox(height: 24),

                          // URGENT REQUESTS
                          if (urgentRequests.isNotEmpty) ...[
                            Text('Urgent Requests',
                                style: GoogleFonts.poppins(
                                    fontSize: 18, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 12),
                            ...urgentRequests.map((r) => Card(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  color: const Color(0xFFFFEBEE),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: const Color(0xFFE53935),
                                      child: Text(
                                        r['blood_group'],
                                        style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 11),
                                      ),
                                    ),
                                    title: Text(r['hospital_name'] ?? '',
                                        style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w600)),
                                    subtitle: Text(
                                        '${r['units_needed']} units needed • ${r['city']}',
                                        style:
                                            GoogleFonts.poppins(fontSize: 12)),
                                    trailing: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE53935),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text('URGENT',
                                          style: GoogleFonts.poppins(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700)),
                                    ),
                                  ),
                                )),
                          ],
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color, size: 28),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: color)),
                Text(title,
                    style: GoogleFonts.poppins(
                        fontSize: 11, color: Colors.grey[600])),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BloodGroupChip extends StatelessWidget {
  final String bloodGroup;
  final int units;
  final Color color;

  const _BloodGroupChip({
    required this.bloodGroup,
    required this.units,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Column(
        children: [
          Text(bloodGroup,
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700, color: color, fontSize: 13)),
          Text('$units units',
              style:
                  GoogleFonts.poppins(fontSize: 10, color: Colors.grey[600])),
        ],
      ),
    );
  }
}
