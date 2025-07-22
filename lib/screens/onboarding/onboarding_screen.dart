import 'package:flutter/material.dart';
import 'package:sipstreak/models/user_data.dart';
import 'package:sipstreak/providers/user_data_provider.dart';
import 'package:sipstreak/screens/home_screen.dart';
import 'package:sipstreak/services/daily_recalculation_service.dart';
import 'name_screen.dart';
import 'gender_screen.dart';
import 'body_stats_screen.dart';
import 'activity_screen.dart';
import 'location_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  String? name;
  String? gender;
  double? weightKg;
  double? heightCm;
  String? activityLevel;
  String? location;
  
  void _goToNextPage() {
    if (_pageController.page! < 4) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }
  
  void _saveName(String value) {
    setState(() {
      name = value;
    });
    _goToNextPage();
  }
  
  void _saveGender(String value) {
    setState(() {
      gender = value;
    });
    _goToNextPage();
  }
  
  void _saveBodyStats(double weight, double height) {
    setState(() {
      weightKg = weight;
      heightCm = height;
    });
    _goToNextPage();
  }
  
  void _saveActivityLevel(String value) {
    setState(() {
      activityLevel = value;
    });
    _goToNextPage();
  }
  
  void _saveLocation(String? value) {
    setState(() {
      location = value;
    });
    _completeOnboarding();
  }
  
  void _completeOnboarding() async {
    final userData = UserData(
      name: name!,
      gender: gender!,
      weightKg: weightKg!,
      heightCm: heightCm!,
      activityLevel: activityLevel!,
      location: location,
    );
    
    await UserDataProvider.saveUserDataWithTarget(userData);
    DailyRecalculationService.startDailyRecalculation();
    
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          NameScreen(onNext: _saveName),
          GenderScreen(onNext: _saveGender),
          BodyStatsScreen(onNext: _saveBodyStats),
          ActivityScreen(onNext: _saveActivityLevel),
          LocationScreen(onNext: _saveLocation),
        ],
      ),
    );
  }
} 