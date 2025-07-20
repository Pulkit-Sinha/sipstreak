class UserData {
  final String name;
  final String gender;
  final double weightKg;
  final double heightCm;
  final String activityLevel;
  final String? location;

  UserData({
    required this.name,
    required this.gender,
    required this.weightKg,
    required this.heightCm,
    required this.activityLevel,
    this.location,
  });

  // Convert to map for storing in shared preferences
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'gender': gender,
      'weightKg': weightKg,
      'heightCm': heightCm,
      'activityLevel': activityLevel,
      'location': location,
    };
  }

  // Create from map when retrieving from shared preferences
  factory UserData.fromMap(Map<String, dynamic> map) {
    return UserData(
      name: map['name'],
      gender: map['gender'],
      weightKg: map['weightKg'],
      heightCm: map['heightCm'],
      activityLevel: map['activityLevel'],
      location: map['location'],
    );
  }
} 