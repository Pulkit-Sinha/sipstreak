class WaterIntakeEntry {
  final String id;
  final DateTime timestamp;
  final double volumeMl;
  final String presetId;

  WaterIntakeEntry({
    required this.id,
    required this.timestamp,
    required this.volumeMl,
    required this.presetId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'volumeMl': volumeMl,
      'presetId': presetId,
    };
  }

  factory WaterIntakeEntry.fromMap(Map<String, dynamic> map) {
    return WaterIntakeEntry(
      id: map['id'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
      volumeMl: map['volumeMl'],
      presetId: map['presetId'],
    );
  }
}