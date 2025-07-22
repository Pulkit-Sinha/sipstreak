import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  static const String _apiKey = 'e4f4c9a9e0b9ff28a1482070371b9677';
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';

  static Future<WeatherData?> getWeatherByCoordinates({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/forecast?lat=$latitude&lon=$longitude&appid=$_apiKey&units=metric&cnt=8'
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return WeatherData.fromDailyForecast(data);
      } else {
        print('Weather API error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching weather data: $e');
      return null;
    }
  }

  static Future<WeatherData?> getWeatherByLocation(String location) async {
    if (location.contains(',')) {
      final coords = location.split(',');
      if (coords.length == 2) {
        try {
          final lat = double.parse(coords[0].trim());
          final lng = double.parse(coords[1].trim());
          return getWeatherByCoordinates(latitude: lat, longitude: lng);
        } catch (e) {
          print('Error parsing coordinates: $e');
        }
      }
    }
    return null;
  }
}

class WeatherData {
  final double temperature;
  final double humidity;
  final String description;
  final String cityName;

  WeatherData({
    required this.temperature,
    required this.humidity,
    required this.description,
    required this.cityName,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      temperature: json['main']['temp']?.toDouble() ?? 0.0,
      humidity: json['main']['humidity']?.toDouble() ?? 0.0,
      description: json['weather'][0]['description'] ?? '',
      cityName: json['name'] ?? 'Unknown',
    );
  }

  factory WeatherData.fromDailyForecast(Map<String, dynamic> json) {
    final List<dynamic> forecasts = json['list'] ?? [];
    if (forecasts.isEmpty) {
      return WeatherData(
        temperature: 0.0,
        humidity: 0.0,
        description: '',
        cityName: json['city']['name'] ?? 'Unknown',
      );
    }

    double totalTemp = 0;
    double totalHumidity = 0;
    int count = 0;

    for (var forecast in forecasts) {
      totalTemp += forecast['main']['temp']?.toDouble() ?? 0.0;
      totalHumidity += forecast['main']['humidity']?.toDouble() ?? 0.0;
      count++;
    }

    return WeatherData(
      temperature: totalTemp / count,
      humidity: totalHumidity / count,
      description: forecasts[0]['weather'][0]['description'] ?? '',
      cityName: json['city']['name'] ?? 'Unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'temperature': temperature,
      'humidity': humidity,
      'description': description,
      'cityName': cityName,
    };
  }
}