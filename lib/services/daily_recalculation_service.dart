import 'dart:async';
import 'package:flutter/foundation.dart';
import '../providers/user_data_provider.dart';

class DailyRecalculationService {
  static Timer? _timer;
  static bool _isRunning = false;

  static void startDailyRecalculation() {
    if (_isRunning) return;
    
    _isRunning = true;
    _scheduleNextRecalculation();
  }

  static void stopDailyRecalculation() {
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
  }

  static void _scheduleNextRecalculation() {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final duration = tomorrow.difference(now);

    if (kDebugMode) {
      print('Scheduling next water target recalculation in ${duration.inHours}h ${duration.inMinutes % 60}m');
    }

    _timer = Timer(duration, () async {
      await _recalculateWaterTarget();
      _scheduleNextRecalculation();
    });
  }

  static Future<void> _recalculateWaterTarget() async {
    try {
      final userData = await UserDataProvider.getUserData();
      
      if (userData != null) {
        final updatedUserData = await userData.calculateWaterTarget();
        await UserDataProvider.saveUserData(updatedUserData);
        
        if (kDebugMode) {
          print('Daily water target recalculated: ${updatedUserData.dailyWaterTargetMl}ml');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error during daily recalculation: $e');
      }
    }
  }

  static Future<void> forceRecalculation() async {
    await _recalculateWaterTarget();
  }

  static bool get isRunning => _isRunning;
}