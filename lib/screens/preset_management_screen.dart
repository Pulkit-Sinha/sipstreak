import 'package:flutter/material.dart';
import '../models/water_preset.dart';
import '../services/water_tracking_service.dart';

class PresetManagementScreen extends StatefulWidget {
  const PresetManagementScreen({super.key});

  @override
  State<PresetManagementScreen> createState() => _PresetManagementScreenState();
}

class _PresetManagementScreenState extends State<PresetManagementScreen> {
  List<WaterPreset> presets = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPresets();
  }

  Future<void> _loadPresets() async {
    setState(() => isLoading = true);
    final loadedPresets = await WaterTrackingService.getPresets();
    setState(() {
      presets = loadedPresets;
      isLoading = false;
    });
  }

  Future<void> _showPresetDialog({WaterPreset? preset}) async {
    final nameController = TextEditingController(text: preset?.name ?? '');
    final volumeController = TextEditingController(
      text: preset?.volumeMl.toInt().toString() ?? '',
    );
    
    final result = await showDialog<WaterPreset>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(preset == null ? 'Add Preset' : 'Edit Preset'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'e.g., Small Glass',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: volumeController,
              decoration: const InputDecoration(
                labelText: 'Volume (ml)',
                hintText: 'e.g., 250',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final name = nameController.text.trim();
              final volumeText = volumeController.text.trim();
              
              if (name.isEmpty || volumeText.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill in all fields')),
                );
                return;
              }
              
              final volume = double.tryParse(volumeText);
              if (volume == null || volume <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a valid volume')),
                );
                return;
              }
              
              final newPreset = WaterPreset(
                id: preset?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                name: name,
                volumeMl: volume,
                isDefault: preset?.isDefault ?? false,
              );
              
              Navigator.of(context).pop(newPreset);
            },
            child: Text(preset == null ? 'Add' : 'Save'),
          ),
        ],
      ),
    );

    if (result != null) {
      try {
        if (preset == null) {
          await WaterTrackingService.addPreset(result);
        } else {
          await WaterTrackingService.updatePreset(result);
        }
        _loadPresets();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString())),
          );
        }
      }
    }
  }

  Future<void> _deletePreset(WaterPreset preset) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Preset'),
        content: Text('Are you sure you want to delete "${preset.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await WaterTrackingService.deletePreset(preset.id);
        _loadPresets();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString())),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Presets'),
        backgroundColor: Colors.lightBlue.shade600,
        foregroundColor: Colors.white,
        actions: [
          if (presets.length < 4)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showPresetDialog(),
            ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : presets.isEmpty
              ? const Center(
                  child: Text(
                    'No presets found',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: presets.length,
                  itemBuilder: (context, index) {
                    final preset = presets[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Icon(
                          preset.volumeMl >= 500 
                              ? Icons.sports_bar 
                              : Icons.local_drink,
                          color: Colors.lightBlue.shade600,
                        ),
                        title: Text(
                          preset.name,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text('${preset.volumeMl.toInt()}ml'),
                        trailing: preset.isDefault 
                            ? Chip(
                                label: const Text(
                                  'Default',
                                  style: TextStyle(fontSize: 12),
                                ),
                                backgroundColor: Colors.lightBlue.shade100,
                              )
                            : IconButton(
                                icon: Icon(
                                  Icons.delete,
                                  color: Colors.red.shade400,
                                ),
                                onPressed: () => _deletePreset(preset),
                              ),
                        onTap: () => _showPresetDialog(preset: preset),
                      ),
                    );
                  },
                ),
      floatingActionButton: presets.length < 4
          ? FloatingActionButton(
              onPressed: () => _showPresetDialog(),
              backgroundColor: Colors.lightBlue.shade600,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }
}