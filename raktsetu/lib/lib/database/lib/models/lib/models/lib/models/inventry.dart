class BloodInventory {
  final int? id;
  final String bloodGroup;
  final int units;
  final String city;
  final String? lastUpdated;

  BloodInventory({
    this.id,
    required this.bloodGroup,
    required this.units,
    required this.city,
    this.lastUpdated,
  });

  factory BloodInventory.fromMap(Map<String, dynamic> map) {
    return BloodInventory(
      id: map['id'],
      bloodGroup: map['blood_group'],
      units: map['units'] is int ? map['units'] : (map['total_units'] ?? 0),
      city: map['city'],
      lastUpdated: map['last_updated'],
    );
  }
}