import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:raktsetu/lib/database/dataset_helper.dart';
// ignore: unused_import
import 'package:raktsetu/lib/database/database_helper.dart';
import 'package:raktsetu/lib/database/lib/models/donor.dart';
// ignore: unused_import
import 'package:raktsetu/lib/models/donor.dart';

class DonorScreen extends StatefulWidget {
  const DonorScreen({super.key});

  @override
  State<DonorScreen> createState() => _DonorScreenState();
}

class _DonorScreenState extends State<DonorScreen> {
  final db = DatabaseHelper.instance;
  List<Map<String, dynamic>> donors = [];
  List<Map<String, dynamic>> filteredDonors = [];
  bool isLoading = true;
  String selectedBloodGroup = 'All';
  String selectedCity = 'All';

  final bloodGroups = ['All', 'A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];
  final cities = [
    'All',
    'Ahmedabad',
    'Surat',
    'Vadodara',
    'Gandhinagar',
    'Rajkot'
  ];

  @override
  void initState() {
    super.initState();
    loadDonors();
  }

  Future<void> loadDonors() async {
    setState(() => isLoading = true);
    final data = await db.getAllDonors();
    setState(() {
      donors = data;
      filteredDonors = data;
      isLoading = false;
    });
  }

  void filterDonors() {
    setState(() {
      filteredDonors = donors.where((d) {
        final bgMatch = selectedBloodGroup == 'All' ||
            d['blood_group'] == selectedBloodGroup;
        final cityMatch = selectedCity == 'All' || d['city'] == selectedCity;
        return bgMatch && cityMatch;
      }).toList();
    });
  }

  void _showAddDonorSheet() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final ageController = TextEditingController();
    String bloodGroup = 'A+';
    String city = 'Ahmedabad';
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
                Text('Register New Donor',
                    style: GoogleFonts.poppins(
                        fontSize: 20, fontWeight: FontWeight.w700)),
                const SizedBox(height: 16),
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: ageController,
                  decoration: const InputDecoration(
                    labelText: 'Age',
                    prefixIcon: Icon(Icons.cake),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? 'Required' : null,
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
                            .where((b) => b != 'All')
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
                            .where((c) => c != 'All')
                            .map((c) =>
                                DropdownMenuItem(value: c, child: Text(c)))
                            .toList(),
                        onChanged: (v) => setSheetState(() => city = v!),
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
                        final donor = Donor(
                          name: nameController.text,
                          bloodGroup: bloodGroup,
                          city: city,
                          phone: phoneController.text,
                          age: int.parse(ageController.text),
                        );
                        await db.insertDonor(donor.toMap());
                        if (context.mounted) Navigator.pop(context);
                        loadDonors();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('Donor registered successfully! 🩸'),
                              backgroundColor: Color(0xFFE53935),
                            ),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.favorite),
                    label: Text('Register Donor',
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
        title: const Text('Blood Donors'),
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
                child: Text('${filteredDonors.length} donors',
                    style:
                        GoogleFonts.poppins(color: Colors.white, fontSize: 12)),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDonorSheet,
        backgroundColor: const Color(0xFFE53935),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('Add Donor',
            style: GoogleFonts.poppins(
                color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFE53935)))
          : Column(
              children: [
                // FILTER BAR
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: selectedBloodGroup,
                              decoration: const InputDecoration(
                                labelText: 'Blood Group',
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                              ),
                              items: bloodGroups
                                  .map((b) => DropdownMenuItem(
                                      value: b, child: Text(b)))
                                  .toList(),
                              onChanged: (v) {
                                selectedBloodGroup = v!;
                                filterDonors();
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: selectedCity,
                              decoration: const InputDecoration(
                                labelText: 'City',
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                              ),
                              items: cities
                                  .map((c) => DropdownMenuItem(
                                      value: c, child: Text(c)))
                                  .toList(),
                              onChanged: (v) {
                                selectedCity = v!;
                                filterDonors();
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // DONOR LIST
                Expanded(
                  child: filteredDonors.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.search_off,
                                  size: 64, color: Colors.grey),
                              const SizedBox(height: 12),
                              Text('No donors found',
                                  style: GoogleFonts.poppins(
                                      color: Colors.grey, fontSize: 16)),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: loadDonors,
                          color: const Color(0xFFE53935),
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: filteredDonors.length,
                            itemBuilder: (context, index) {
                              final donor = filteredDonors[index];
                              final isAvailable = donor['is_available'] == 1;
                              return Card(
                                margin: const EdgeInsets.only(bottom: 10),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(12),
                                  leading: CircleAvatar(
                                    backgroundColor: isAvailable
                                        ? const Color(0xFFE53935)
                                        : Colors.grey,
                                    radius: 26,
                                    child: Text(
                                      donor['blood_group'],
                                      style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 12),
                                    ),
                                  ),
                                  title: Text(donor['name'],
                                      style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600)),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.location_on,
                                              size: 12, color: Colors.grey),
                                          Text(' ${donor['city']}',
                                              style: GoogleFonts.poppins(
                                                  fontSize: 12,
                                                  color: Colors.grey[600])),
                                          const SizedBox(width: 8),
                                          const Icon(Icons.phone,
                                              size: 12, color: Colors.grey),
                                          Text(' ${donor['phone']}',
                                              style: GoogleFonts.poppins(
                                                  fontSize: 12,
                                                  color: Colors.grey[600])),
                                        ],
                                      ),
                                      if (donor['last_donated'] != null)
                                        Text(
                                            'Last donated: ${donor['last_donated']}',
                                            style: GoogleFonts.poppins(
                                                fontSize: 11,
                                                color: Colors.grey[500])),
                                    ],
                                  ),
                                  trailing: Switch(
                                    value: isAvailable,
                                    activeThumbColor: const Color(0xFFE53935),
                                    onChanged: (val) async {
                                      await db.updateDonorAvailability(
                                          donor['id'], val ? 1 : 0);
                                      loadDonors();
                                    },
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
