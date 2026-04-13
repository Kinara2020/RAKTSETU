import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:raktsetu/lib/database/dataset_helper.dart';
import 'package:raktsetu/lib/database/lib/models/lib/models/request.dart';
// ignore: unused_import
import 'package:raktsetu/lib/database/database_helper.dart';
// ignore: unused_import
import 'package:raktsetu/lib/models/request.dart';

class RequestScreen extends StatefulWidget {
  const RequestScreen({super.key});

  @override
  State<RequestScreen> createState() => _RequestScreenState();
}

class _RequestScreenState extends State<RequestScreen> {
  final db = DatabaseHelper.instance;
  List<Map<String, dynamic>> requests = [];
  bool isLoading = true;
  String selectedStatus = 'All';

  final statuses = ['All', 'Urgent', 'Pending', 'Fulfilled'];
  final bloodGroups = ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];
  final cities = ['Ahmedabad', 'Surat', 'Vadodara', 'Gandhinagar', 'Rajkot'];

  @override
  void initState() {
    super.initState();
    loadRequests();
  }

  Future<void> loadRequests() async {
    setState(() => isLoading = true);
    final data = await db.getAllRequests();
    setState(() {
      requests = data;
      isLoading = false;
    });
  }

  List<Map<String, dynamic>> get filteredRequests {
    if (selectedStatus == 'All') return requests;
    return requests.where((r) => r['status'] == selectedStatus).toList();
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

  IconData _statusIcon(String status) {
    switch (status) {
      case 'Urgent':
        return Icons.emergency;
      case 'Pending':
        return Icons.hourglass_empty;
      case 'Fulfilled':
        return Icons.check_circle;
      default:
        return Icons.info;
    }
  }

  void _showAddRequestSheet() async {
    final hospitals = await db.getHospitals();
    if (!mounted) return;

    int? selectedHospitalId = hospitals.first['id'];
    String bloodGroup = 'A+';
    String city = 'Ahmedabad';
    String status = 'Pending';
    final unitsController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text('New Blood Request',
                    style: GoogleFonts.poppins(
                        fontSize: 20, fontWeight: FontWeight.w700)),
                const SizedBox(height: 16),

                // HOSPITAL DROPDOWN
                DropdownButtonFormField<int>(
                  initialValue: selectedHospitalId,
                  decoration: const InputDecoration(
                    labelText: 'Hospital',
                    prefixIcon: Icon(Icons.local_hospital),
                  ),
                  items: hospitals
                      .map((h) => DropdownMenuItem<int>(
                            value: h['id'] as int,
                            child: Text(h['name'],
                                style: GoogleFonts.poppins(fontSize: 13)),
                          ))
                      .toList(),
                  onChanged: (v) => setSheetState(() => selectedHospitalId = v),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: bloodGroup,
                        decoration:
                            const InputDecoration(labelText: 'Blood Group'),
                        items: bloodGroups
                            .map((b) =>
                                DropdownMenuItem(value: b, child: Text(b)))
                            .toList(),
                        onChanged: (v) => setSheetState(() => bloodGroup = v!),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: city,
                        decoration: const InputDecoration(labelText: 'City'),
                        items: cities
                            .map((c) =>
                                DropdownMenuItem(value: c, child: Text(c)))
                            .toList(),
                        onChanged: (v) => setSheetState(() => city = v!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: unitsController,
                        decoration: const InputDecoration(
                          labelText: 'Units Needed',
                          prefixIcon: Icon(Icons.water_drop),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: status,
                        decoration:
                            const InputDecoration(labelText: 'Priority'),
                        items: ['Pending', 'Urgent']
                            .map((s) =>
                                DropdownMenuItem(value: s, child: Text(s)))
                            .toList(),
                        onChanged: (v) => setSheetState(() => status = v!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        final request = BloodRequest(
                          hospitalId: selectedHospitalId!,
                          bloodGroup: bloodGroup,
                          unitsNeeded: int.parse(unitsController.text),
                          city: city,
                          status: status,
                        );
                        await db.insertRequest(request.toMap());
                        if (context.mounted) Navigator.pop(context);
                        loadRequests();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Request submitted successfully!'),
                              backgroundColor: Color(0xFFE53935),
                            ),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.send),
                    label: Text('Submit Request',
                        style:
                            GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Blood Requests'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('${filteredRequests.length} requests',
                    style:
                        GoogleFonts.poppins(color: Colors.white, fontSize: 12)),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddRequestSheet,
        backgroundColor: const Color(0xFFE53935),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('New Request',
            style: GoogleFonts.poppins(
                color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFE53935)))
          : Column(
              children: [
                // STATUS FILTER
                Container(
                  color: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: statuses.map((s) {
                        final isSelected = selectedStatus == s;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(s,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.grey[700],
                                )),
                            selected: isSelected,
                            onSelected: (_) {
                              setState(() => selectedStatus = s);
                            },
                            backgroundColor: Colors.grey[100],
                            selectedColor: const Color(0xFFE53935),
                            checkmarkColor: Colors.white,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                // REQUESTS LIST
                Expanded(
                  child: filteredRequests.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.inbox,
                                  size: 64, color: Colors.grey),
                              const SizedBox(height: 12),
                              Text('No requests found',
                                  style: GoogleFonts.poppins(
                                      color: Colors.grey, fontSize: 16)),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: loadRequests,
                          color: const Color(0xFFE53935),
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: filteredRequests.length,
                            itemBuilder: (context, index) {
                              final r = filteredRequests[index];
                              final statusColor = _statusColor(r['status']);
                              return Card(
                                margin: const EdgeInsets.only(bottom: 10),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              CircleAvatar(
                                                backgroundColor:
                                                    const Color(0xFFE53935),
                                                radius: 22,
                                                child: Text(
                                                  r['blood_group'],
                                                  style: GoogleFonts.poppins(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 11,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    r['hospital_name'] ?? '',
                                                    style: GoogleFonts.poppins(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                  Text(
                                                    '${r['units_needed']} units • ${r['city']}',
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 12,
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 5),
                                            decoration: BoxDecoration(
                                              color:
                                                  statusColor.withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              border: Border.all(
                                                  color: statusColor
                                                      .withOpacity(0.4)),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(_statusIcon(r['status']),
                                                    size: 12,
                                                    color: statusColor),
                                                const SizedBox(width: 4),
                                                Text(
                                                  r['status'],
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 11,
                                                    color: statusColor,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (r['status'] != 'Fulfilled') ...[
                                        const SizedBox(height: 12),
                                        const Divider(height: 1),
                                        const SizedBox(height: 12),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: OutlinedButton(
                                                onPressed: () async {
                                                  await db.updateRequestStatus(
                                                      r['id'], 'Fulfilled');
                                                  loadRequests();
                                                },
                                                style: OutlinedButton.styleFrom(
                                                  foregroundColor:
                                                      const Color(0xFF2E7D32),
                                                  side: const BorderSide(
                                                      color: Color(0xFF2E7D32)),
                                                ),
                                                child: Text('Mark Fulfilled',
                                                    style: GoogleFonts.poppins(
                                                        fontSize: 12)),
                                              ),
                                            ),
                                            if (r['status'] == 'Pending') ...[
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: OutlinedButton(
                                                  onPressed: () async {
                                                    await db
                                                        .updateRequestStatus(
                                                            r['id'], 'Urgent');
                                                    loadRequests();
                                                  },
                                                  style:
                                                      OutlinedButton.styleFrom(
                                                    foregroundColor:
                                                        const Color(0xFFE53935),
                                                    side: const BorderSide(
                                                        color:
                                                            Color(0xFFE53935)),
                                                  ),
                                                  child: Text('Mark Urgent',
                                                      style:
                                                          GoogleFonts.poppins(
                                                              fontSize: 12)),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
    );
  }
}
