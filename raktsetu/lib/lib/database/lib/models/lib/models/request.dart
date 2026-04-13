class BloodRequest {
  final int? id;
  final int hospitalId;
  final String bloodGroup;
  final int unitsNeeded;
  final String city;
  final String status;
  final String? createdAt;
  final String? hospitalName;

  BloodRequest({
    this.id,
    required this.hospitalId,
    required this.bloodGroup,
    required this.unitsNeeded,
    required this.city,
    this.status = 'Pending',
    this.createdAt,
    this.hospitalName,
  });

  factory BloodRequest.fromMap(Map<String, dynamic> map) {
    return BloodRequest(
      id: map['id'],
      hospitalId: map['hospital_id'],
      bloodGroup: map['blood_group'],
      unitsNeeded: map['units_needed'],
      city: map['city'],
      status: map['status'] ?? 'Pending',
      createdAt: map['created_at'],
      hospitalName: map['hospital_name'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'hospital_id': hospitalId,
      'blood_group': bloodGroup,
      'units_needed': unitsNeeded,
      'city': city,
      'status': status,
    };
  }
}