class Donor {
  final int? id;
  final String name;
  final String bloodGroup;
  final String city;
  final String phone;
  final int age;
  final String? lastDonated;
  final int isAvailable;
  final String? createdAt;

  Donor({
    this.id,
    required this.name,
    required this.bloodGroup,
    required this.city,
    required this.phone,
    required this.age,
    this.lastDonated,
    this.isAvailable = 1,
    this.createdAt,
  });

  factory Donor.fromMap(Map<String, dynamic> map) {
    return Donor(
      id: map['id'],
      name: map['name'],
      bloodGroup: map['blood_group'],
      city: map['city'],
      phone: map['phone'],
      age: map['age'],
      lastDonated: map['last_donated'],
      isAvailable: map['is_available'] ?? 1,
      createdAt: map['created_at'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'blood_group': bloodGroup,
      'city': city,
      'phone': phone,
      'age': age,
      'last_donated': lastDonated,
      'is_available': isAvailable,
    };
  }
}