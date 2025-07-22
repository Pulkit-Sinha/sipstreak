class WaterPreset {
  final String id;
  final String name;
  final double volumeMl;
  final bool isDefault;

  WaterPreset({
    required this.id,
    required this.name,
    required this.volumeMl,
    this.isDefault = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'volumeMl': volumeMl,
      'isDefault': isDefault,
    };
  }

  factory WaterPreset.fromMap(Map<String, dynamic> map) {
    return WaterPreset(
      id: map['id'],
      name: map['name'],
      volumeMl: map['volumeMl'],
      isDefault: map['isDefault'] ?? false,
    );
  }

  static List<WaterPreset> getDefaultPresets() {
    return [
      WaterPreset(
        id: 'glass_200ml',
        name: 'Glass',
        volumeMl: 200,
        isDefault: true,
      ),
      WaterPreset(
        id: 'bottle_1000ml',
        name: 'Bottle',
        volumeMl: 1000,
        isDefault: true,
      ),
    ];
  }

  WaterPreset copyWith({
    String? id,
    String? name,
    double? volumeMl,
    bool? isDefault,
  }) {
    return WaterPreset(
      id: id ?? this.id,
      name: name ?? this.name,
      volumeMl: volumeMl ?? this.volumeMl,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}