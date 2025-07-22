import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_data.dart';

class UserDataProvider {
  static const String _userDataKey = 'user_data';
  static const String _onboardingKey = 'onboarding_completed';

  // Save user data
  static Future<void> saveUserData(UserData userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userDataKey, jsonEncode(userData.toMap()));
    await prefs.setBool(_onboardingKey, true);
  }

  // Save user data with calculated water target
  static Future<void> saveUserDataWithTarget(UserData userData) async {
    final userDataWithTarget = await userData.calculateWaterTarget();
    await saveUserData(userDataWithTarget);
  }

  // Get user data
  static Future<UserData?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString(_userDataKey);
    
    if (userDataString == null) {
      return null;
    }
    
    final userDataMap = jsonDecode(userDataString) as Map<String, dynamic>;
    return UserData.fromMap(userDataMap);
  }

  // Check if onboarding is completed
  static Future<bool> isOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingKey) ?? false;
  }
} 