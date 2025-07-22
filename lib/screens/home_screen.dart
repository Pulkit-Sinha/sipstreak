import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sipstreak/models/user_data.dart';
import 'package:sipstreak/providers/user_data_provider.dart';
import 'package:sipstreak/widgets/water_intake_widget.dart';
import 'package:sipstreak/widgets/confetti_effect.dart';
import 'package:sipstreak/services/water_tracking_service.dart';
import 'profile_screen.dart';
import 'preset_management_screen.dart';
import 'history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  UserData? userData;
  bool isLoading = true;
  double todaysProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final data = await UserDataProvider.getUserData();
    final progress = await WaterTrackingService.getTodaysTotal();
    setState(() {
      userData = data;
      todaysProgress = progress;
      isLoading = false;
    });
  }

  Future<void> _navigateToProfile() async {
    if (userData != null) {
      final result = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ProfileScreen(userData: userData!),
        ),
      );
      
      if (result == true) {
        _loadUserData();
      }
    }
  }

  Future<void> _refreshProgress() async {
    final progress = await WaterTrackingService.getTodaysTotal();
    setState(() {
      todaysProgress = progress;
    });
  }


  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              Icons.water_drop,
              color: Colors.lightBlue.shade600,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'SipStreak',
              style: TextStyle(
                color: Colors.lightBlue.shade600,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.lightBlue.shade600),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.lightBlue.shade400,
                    Colors.lightBlue.shade600,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.water_drop,
                    color: Colors.white,
                    size: 48,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'SipStreak',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (userData != null)
                    Text(
                      'Hello, ${userData!.name}!',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.person,
                color: Colors.lightBlue.shade600,
              ),
              title: const Text('Edit Profile'),
              onTap: () {
                Navigator.pop(context);
                _navigateToProfile();
              },
            ),
            ListTile(
              leading: Icon(
                Icons.water_drop_outlined,
                color: Colors.lightBlue.shade600,
              ),
              title: const Text('Manage Presets'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const PresetManagementScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(
                Icons.history,
                color: Colors.lightBlue.shade600,
              ),
              title: const Text('History'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const HistoryScreen(),
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: Icon(
                Icons.info_outline,
                color: Colors.lightBlue.shade600,
              ),
              title: const Text('About'),
              onTap: () async {
                Navigator.pop(context);
                String version = '1.0.0'; // Fallback version
                try {
                  final packageInfo = await PackageInfo.fromPlatform();
                  version = packageInfo.version;
                } catch (e) {
                  // Use fallback version if plugin fails
                  print('Failed to get package info: $e');
                }
                
                if (context.mounted) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Row(
                        children: [
                          Icon(
                            Icons.water_drop,
                            color: Colors.lightBlue,
                            size: 24,
                          ),
                          SizedBox(width: 8),
                          Text('About SipStreak'),
                        ],
                      ),
                      content: Text(
                        'Version $version\n\nYour personal hydration tracking companion. Stay healthy, stay hydrated!',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Hello, ${userData!.name}! 👋",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.lightBlue.shade800,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (userData!.dailyWaterTargetMl != null)
                        Builder(
                          builder: (context) {
                            final progress = todaysProgress / userData!.dailyWaterTargetMl!;
                            final progressClamped = progress.clamp(0.0, 1.0);
                            final percentComplete = (progressClamped * 100).toInt();
                            
                            return Stack(
                              children: [
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: progress >= 1.0 
                                      ? Colors.green.shade50 
                                      : Colors.lightBlue.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: progress >= 1.0 
                                        ? Colors.green.shade200 
                                        : Colors.lightBlue.shade200,
                                      width: 1,
                                    ),
                                  ),
                              child: Row(
                                children: [
                                  // Glass visualization
                                  Container(
                                    width: 70,
                                    height: 110,
                                    child: Stack(
                                      children: [
                                        // Glass outline
                                        Container(
                                          width: 70,
                                          height: 110,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.white.withOpacity(0.2),
                                                Colors.grey.shade100.withOpacity(0.3),
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            borderRadius: const BorderRadius.only(
                                              topLeft: Radius.circular(5),
                                              topRight: Radius.circular(5),
                                              bottomLeft: Radius.circular(15),
                                              bottomRight: Radius.circular(15),
                                            ),
                                            border: Border.all(
                                              color: Colors.grey.shade300,
                                              width: 2.5,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.1),
                                                spreadRadius: 1,
                                                blurRadius: 4,
                                                offset: const Offset(2, 2),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Water fill
                                        Positioned(
                                          bottom: 2.5,
                                          left: 2.5,
                                          right: 2.5,
                                          child: Container(
                                            height: (110 - 5) * progressClamped,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: progress >= 1.0 
                                                  ? [
                                                      Colors.green.shade200,
                                                      Colors.green.shade400,
                                                      Colors.green.shade600,
                                                    ]
                                                  : [
                                                      Colors.lightBlue.shade200,
                                                      Colors.lightBlue.shade400,
                                                      Colors.lightBlue.shade600,
                                                    ],
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                                stops: const [0.0, 0.5, 1.0],
                                              ),
                                              borderRadius: const BorderRadius.only(
                                                bottomLeft: Radius.circular(12),
                                                bottomRight: Radius.circular(12),
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: progress >= 1.0 
                                                    ? Colors.green.withOpacity(0.3)
                                                    : Colors.lightBlue.withOpacity(0.3),
                                                  spreadRadius: 1,
                                                  blurRadius: 3,
                                                  offset: const Offset(0, 1),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        // Highlight effect on glass
                                        Positioned(
                                          top: 10,
                                          left: 8,
                                          child: Container(
                                            width: 6,
                                            height: 30,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  Colors.white.withOpacity(0.6),
                                                  Colors.white.withOpacity(0.1),
                                                ],
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                              ),
                                              borderRadius: BorderRadius.circular(3),
                                            ),
                                          ),
                                        ),
                                        // Water surface shimmer (when there's water)
                                        if (progressClamped > 0.1)
                                          Positioned(
                                            bottom: 2.5 + (110 - 5) * progressClamped - 8,
                                            left: 6,
                                            right: 6,
                                            child: Container(
                                              height: 3,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Colors.white.withOpacity(0.0),
                                                    Colors.white.withOpacity(0.8),
                                                    Colors.white.withOpacity(0.0),
                                                  ],
                                                ),
                                                borderRadius: BorderRadius.circular(2),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  // Progress info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Today's Progress",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.lightBlue.shade800,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          "$percentComplete% Complete",
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: progress >= 1.0 ? Colors.green.shade700 : Colors.lightBlue.shade700,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "${(todaysProgress / 1000).toStringAsFixed(1)}L / ${(userData!.dailyWaterTargetMl! / 1000).toStringAsFixed(1)}L",
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.lightBlue.shade600,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          progress >= 1.0 
                                            ? "🎉 Goal achieved! Great job!"
                                            : "${((userData!.dailyWaterTargetMl! - todaysProgress) / 1000).toStringAsFixed(1)}L remaining",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: progress >= 1.0 ? Colors.green.shade700 : Colors.lightBlue.shade700,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                                ),
                                // Confetti effect when goal is reached
                                if (progress >= 1.0)
                                  Positioned.fill(
                                    child: IgnorePointer(
                                      child: ConfettiEffect(),
                                    ),
                                  ),
                              ],
                            );
                          },
                        )
                      else
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.lightBlue.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.lightBlue.shade200,
                              width: 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.local_drink,
                                size: 40,
                                color: Colors.lightBlue.shade600,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                "Setting up your water goal...",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.lightBlue.shade800,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (userData!.dailyWaterTargetMl != null)
                WaterIntakeWidget(
                  dailyTargetMl: userData!.dailyWaterTargetMl!,
                  onIntakeAdded: _refreshProgress,
                )
              else
                const Center(
                  child: Text(
                    "Please complete your profile to start tracking water intake",
                    style: TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
} 