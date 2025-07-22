import 'package:flutter/material.dart';
import '../models/water_preset.dart';
import '../models/water_intake_entry.dart';
import '../services/water_tracking_service.dart';

class WaterIntakeWidget extends StatefulWidget {
  final double dailyTargetMl;
  final VoidCallback? onIntakeAdded;

  const WaterIntakeWidget({
    super.key,
    required this.dailyTargetMl,
    this.onIntakeAdded,
  });

  @override
  State<WaterIntakeWidget> createState() => _WaterIntakeWidgetState();
}

class _WaterIntakeWidgetState extends State<WaterIntakeWidget> {
  List<WaterPreset> presets = [];
  List<WaterIntakeEntry> todaysIntake = [];
  double todaysTotal = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    
    final [presetsResult, intakeResult, totalResult] = await Future.wait([
      WaterTrackingService.getPresets(),
      WaterTrackingService.getTodaysIntake(),
      WaterTrackingService.getTodaysTotal(),
    ]);
    
    setState(() {
      presets = presetsResult as List<WaterPreset>;
      todaysIntake = intakeResult as List<WaterIntakeEntry>;
      todaysTotal = totalResult as double;
      isLoading = false;
    });
  }

  Future<void> _addWater(WaterPreset preset) async {
    await WaterTrackingService.addWaterIntake(preset.volumeMl, preset.id);
    await _loadData();
    widget.onIntakeAdded?.call();
  }

  Future<void> _removeIntake(WaterIntakeEntry entry) async {
    await WaterTrackingService.removeIntakeEntry(entry.id);
    await _loadData();
    widget.onIntakeAdded?.call();
  }

  Future<void> _shareYesterday() async {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final yesterdayEntries = await WaterTrackingService.getEntriesForDate(yesterday);
    final yesterdayTotal = yesterdayEntries.fold<double>(0.0, (sum, entry) => sum + entry.volumeMl);
    
    // Calculate percentage based on user's actual daily goal
    final percentage = widget.dailyTargetMl > 0 
        ? ((yesterdayTotal / widget.dailyTargetMl) * 100).clamp(0, 100).toInt()
        : 0;
    
    // Get emojis based on percentage
    String getEmojisForPercentage(int percent) {
      if (percent >= 100) return '🏆🎉💪✨🌟'; // Achievement emojis
      else if (percent >= 80) return '🔥💧👏😊'; // Great job emojis
      else if (percent >= 60) return '💪💧👍'; // Good progress emojis
      else if (percent >= 40) return '💧🌱'; // Keep going emojis
      else if (percent >= 20) return '💧😅'; // Needs improvement emojis
      else return '😴💧'; // Wake up call emojis
    }
    
    final shareText = '''${yesterday.day}/${yesterday.month}/${yesterday.year}
${(yesterdayTotal / 1000).toStringAsFixed(1)}L
$percentage%
${getEmojisForPercentage(percentage)}''';

    try {
      _showShareDialog(shareText);
    } catch (e) {
      _showShareDialog(shareText);
    }
  }

  void _showShareDialog(String text) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.share, color: Colors.lightBlue),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Share Yesterday\'s Progress',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: SelectableText(
            text,
            style: const TextStyle(fontSize: 14),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              // Copy to clipboard would go here
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Text copied to clipboard!'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Copy'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Add Water Section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Add Water',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.lightBlue.shade800,
              ),
            ),
            InkWell(
              onTap: _shareYesterday,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.lightBlue.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.lightBlue.shade200,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.share,
                      size: 14,
                      color: Colors.lightBlue.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Share',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.lightBlue.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
          
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.8,
            ),
            itemCount: presets.length,
            itemBuilder: (context, index) {
              final preset = presets[index];
              return InkWell(
                onTap: () => _addWater(preset),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.lightBlue.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.lightBlue.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        preset.volumeMl >= 500 ? Icons.sports_bar : Icons.local_drink,
                        size: 24,
                        color: Colors.lightBlue.shade600,
                      ),
                      const SizedBox(width: 8),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            preset.name,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.lightBlue.shade800,
                            ),
                          ),
                          Text(
                            '${preset.volumeMl.toInt()}ml',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.lightBlue.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          
          if (todaysIntake.isNotEmpty) ...[
            const SizedBox(height: 24),
            
            // Today's History Section
            Text(
              'Today\'s History',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.lightBlue.shade800,
              ),
            ),
            const SizedBox(height: 12),
            
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: todaysIntake.length > 3 ? 3 : todaysIntake.length,
              itemBuilder: (context, index) {
                final entry = todaysIntake[index];
                final preset = presets.firstWhere(
                  (p) => p.id == entry.presetId,
                  orElse: () => WaterPreset(
                    id: 'unknown',
                    name: 'Unknown',
                    volumeMl: entry.volumeMl,
                  ),
                );
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Icon(
                      preset.volumeMl >= 500 ? Icons.sports_bar : Icons.local_drink,
                      color: Colors.lightBlue.shade600,
                    ),
                    title: Text(
                      '${preset.name} - ${entry.volumeMl.toInt()}ml',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      '${entry.timestamp.hour.toString().padLeft(2, '0')}:${entry.timestamp.minute.toString().padLeft(2, '0')}',
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        Icons.delete_outline,
                        color: Colors.red.shade400,
                      ),
                      onPressed: () => _removeIntake(entry),
                    ),
                  ),
                );
              },
            ),
            
            if (todaysIntake.length > 3)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Center(
                  child: Text(
                    '... and ${todaysIntake.length - 3} more entries',
                    style: TextStyle(
                      color: Colors.lightBlue.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
          ],
        ],
      );
  }
}