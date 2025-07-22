import '../services/water_intake_calculator.dart';
import '../services/weather_service.dart';

class UserData {
  final String name;
  final String gender;
  final double weightKg;
  final double heightCm;
  final String activityLevel;
  final String? location;
  final double? dailyWaterTargetMl;

  UserData({
    required this.name,
    required this.gender,
    required this.weightKg,
    required this.heightCm,
    required this.activityLevel,
    this.location,
    this.dailyWaterTargetMl,
  });

  Future<UserData> calculateWaterTarget() async {
    WeatherData? weatherData;
    
    if (location != null && location!.isNotEmpty) {
      weatherData = await WeatherService.getWeatherByLocation(location!);
    }
    
    final targetMl = WaterIntakeCalculator.calculateDailyWaterIntake(
      gender: gender,
      weightKg: weightKg,
      heightCm: heightCm,
      activityLevel: activityLevel,
      temperatureCelsius: weatherData?.temperature,
      humidity: weatherData?.humidity,
    );

    return UserData(
      name: name,
      gender: gender,
      weightKg: weightKg,
      heightCm: heightCm,
      activityLevel: activityLevel,
      location: location,
      dailyWaterTargetMl: targetMl,
    );
  }

  String get waterIntakeRecommendation {
    if (dailyWaterTargetMl == null) return 'Calculate target first';
    return WaterIntakeCalculator.getIntakeRecommendation(dailyWaterTargetMl!);
  }

  // Convert to map for storing in shared preferences
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'gender': gender,
      'weightKg': weightKg,
      'heightCm': heightCm,
      'activityLevel': activityLevel,
      'location': location,
      'dailyWaterTargetMl': dailyWaterTargetMl,
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
      dailyWaterTargetMl: map['dailyWaterTargetMl'],
    );
  }
} 