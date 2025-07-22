import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/water_preset.dart';
import '../models/water_intake_entry.dart';

class WaterTrackingService {
  static const String _presetsKey = 'water_presets';
  static const String _intakeEntriesKey = 'water_intake_entries';

  // Preset management
  static Future<List<WaterPreset>> getPresets() async {
    final prefs = await SharedPreferences.getInstance();
    final presetsString = prefs.getString(_presetsKey);
    
    if (presetsString == null) {
      final defaultPresets = WaterPreset.getDefaultPresets();
      await savePresets(defaultPresets);
      return defaultPresets;
    }
    
    final presetsData = jsonDecode(presetsString) as List;
    return presetsData.map((data) => WaterPreset.fromMap(data)).toList();
  }

  static Future<void> savePresets(List<WaterPreset> presets) async {
    final prefs = await SharedPreferences.getInstance();
    final presetsData = presets.map((preset) => preset.toMap()).toList();
    await prefs.setString(_presetsKey, jsonEncode(presetsData));
  }

  static Future<void> addPreset(WaterPreset preset) async {
    final presets = await getPresets();
    
    // Limit to 4 presets maximum
    if (presets.length >= 4) {
      throw Exception('Maximum of 4 presets allowed');
    }
    
    presets.add(preset);
    await savePresets(presets);
  }

  static Future<void> updatePreset(WaterPreset preset) async {
    final presets = await getPresets();
    final index = presets.indexWhere((p) => p.id == preset.id);
    
    if (index != -1) {
      presets[index] = preset;
      await savePresets(presets);
    }
  }

  static Future<void> deletePreset(String presetId) async {
    final presets = await getPresets();
    final preset = presets.firstWhere((p) => p.id == presetId);
    
    // Don't allow deletion of default presets
    if (preset.isDefault) {
      throw Exception('Cannot delete default presets');
    }
    
    presets.removeWhere((p) => p.id == presetId);
    await savePresets(presets);
  }

  // Water intake tracking
  static Future<List<WaterIntakeEntry>> getTodaysIntake() async {
    final prefs = await SharedPreferences.getInstance();
    final entriesString = prefs.getString(_intakeEntriesKey);
    
    if (entriesString == null) return [];
    
    final entriesData = jsonDecode(entriesString) as List;
    final allEntries = entriesData.map((data) => WaterIntakeEntry.fromMap(data)).toList();
    
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    return allEntries.where((entry) => 
      entry.timestamp.isAfter(startOfDay) && entry.timestamp.isBefore(endOfDay)
    ).toList()..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  static Future<void> addWaterIntake(double volumeMl, String presetId) async {
    final prefs = await SharedPreferences.getInstance();
    final entriesString = prefs.getString(_intakeEntriesKey);
    
    List<WaterIntakeEntry> allEntries = [];
    if (entriesString != null) {
      final entriesData = jsonDecode(entriesString) as List;
      allEntries = entriesData.map((data) => WaterIntakeEntry.fromMap(data)).toList();
    }
    
    final newEntry = WaterIntakeEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
      volumeMl: volumeMl,
      presetId: presetId,
    );
    
    allEntries.add(newEntry);
    
    // Keep only last 30 days of entries to avoid storage bloat
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    allEntries = allEntries.where((entry) => entry.timestamp.isAfter(thirtyDaysAgo)).toList();
    
    final entriesData = allEntries.map((entry) => entry.toMap()).toList();
    await prefs.setString(_intakeEntriesKey, jsonEncode(entriesData));
  }

  static Future<double> getTodaysTotal() async {
    final todaysIntake = await getTodaysIntake();
    return todaysIntake.fold<double>(0.0, (sum, entry) => sum + entry.volumeMl);
  }

  static Future<void> removeIntakeEntry(String entryId) async {
    final prefs = await SharedPreferences.getInstance();
    final entriesString = prefs.getString(_intakeEntriesKey);
    
    if (entriesString == null) return;
    
    final entriesData = jsonDecode(entriesString) as List;
    final allEntries = entriesData.map((data) => WaterIntakeEntry.fromMap(data)).toList();
    
    allEntries.removeWhere((entry) => entry.id == entryId);
    
    final updatedEntriesData = allEntries.map((entry) => entry.toMap()).toList();
    await prefs.setString(_intakeEntriesKey, jsonEncode(updatedEntriesData));
  }

  // History data methods
  static Future<Map<DateTime, double>> getHistoryData(int days) async {
    final prefs = await SharedPreferences.getInstance();
    final entriesString = prefs.getString(_intakeEntriesKey);
    
    if (entriesString == null) return {};
    
    final entriesData = jsonDecode(entriesString) as List;
    final allEntries = entriesData.map((data) => WaterIntakeEntry.fromMap(data)).toList();
    
    final now = DateTime.now();
    final historyData = <DateTime, double>{};
    
    // Initialize last 'days' days with 0
    for (int i = days - 1; i >= 0; i--) {
      final date = DateTime(now.year, now.month, now.day - i);
      historyData[date] = 0.0;
    }
    
    // Calculate daily totals
    for (final entry in allEntries) {
      final entryDate = DateTime(entry.timestamp.year, entry.timestamp.month, entry.timestamp.day);
      if (historyData.containsKey(entryDate)) {
        historyData[entryDate] = (historyData[entryDate] ?? 0.0) + entry.volumeMl;
      }
    }
    
    return historyData;
  }

  static Future<List<WaterIntakeEntry>> getEntriesForDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final entriesString = prefs.getString(_intakeEntriesKey);
    
    if (entriesString == null) return [];
    
    final entriesData = jsonDecode(entriesString) as List;
    final allEntries = entriesData.map((data) => WaterIntakeEntry.fromMap(data)).toList();
    
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    return allEntries.where((entry) => 
      entry.timestamp.isAfter(startOfDay) && entry.timestamp.isBefore(endOfDay)
    ).toList()..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  static Future<double> getWeeklyAverage() async {
    final historyData = await getHistoryData(7);
    final totalIntake = historyData.values.fold<double>(0.0, (sum, daily) => sum + daily);
    return totalIntake / 7;
  }

  static Future<double> getMonthlyAverage() async {
    final historyData = await getHistoryData(30);
    final totalIntake = historyData.values.fold<double>(0.0, (sum, daily) => sum + daily);
    return totalIntake / 30;
  }
}