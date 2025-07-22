class WaterIntakeCalculator {
  static double calculateDailyWaterIntake({
    required String gender,
    required double weightKg,
    required double heightCm,
    required String activityLevel,
    double? temperatureCelsius,
    double? humidity,
  }) {
    double baseIntake = _calculateBaseIntake(gender, weightKg, heightCm);
    double activityMultiplier = _getActivityMultiplier(activityLevel);
    double climateAdjustment = _calculateClimateAdjustment(
      temperatureCelsius, 
      humidity,
    );
    
    double totalIntake = baseIntake * activityMultiplier + climateAdjustment;
    
    return (totalIntake * 100).round() / 100;
  }

  static double _calculateBaseIntake(String gender, double weightKg, double heightCm) {
    if (gender.toLowerCase() == 'male') {
      return (weightKg * 35) + (heightCm * 0.5);
    } else {
      return (weightKg * 31) + (heightCm * 0.4);
    }
  }

  static double _getActivityMultiplier(String activityLevel) {
    switch (activityLevel.toLowerCase()) {
      case 'sedentary':
        return 1.0;
      case 'light':
        return 1.2;
      case 'moderate':
        return 1.4;
      case 'intense':
        return 1.6;
      default:
        return 1.0;
    }
  }

  static double _calculateClimateAdjustment(
    double? temperatureCelsius,
    double? humidity,
  ) {
    if (temperatureCelsius == null) return 0;
    
    double tempAdjustment = 0;
    double humidityAdjustment = 0;
    
    if (temperatureCelsius > 25) {
      tempAdjustment = (temperatureCelsius - 25) * 50;
    }
    
    if (humidity != null && humidity > 60) {
      humidityAdjustment = (humidity - 60) * 5;
    }
    
    return tempAdjustment + humidityAdjustment;
  }

  static String getIntakeRecommendation(double dailyIntakeMl) {
    int glasses = (dailyIntakeMl / 250).round();
    
    if (dailyIntakeMl < 1500) {
      return "Low hydration needs - aim for $glasses glasses (250ml each) daily";
    } else if (dailyIntakeMl < 2500) {
      return "Moderate hydration needs - aim for $glasses glasses (250ml each) daily";
    } else if (dailyIntakeMl < 3500) {
      return "High hydration needs - aim for $glasses glasses (250ml each) daily";
    } else {
      return "Very high hydration needs - aim for $glasses glasses (250ml each) daily";
    }
  }
}