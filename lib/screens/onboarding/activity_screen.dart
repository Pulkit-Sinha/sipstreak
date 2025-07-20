import 'package:flutter/material.dart';

class ActivityScreen extends StatelessWidget {
  final Function(String) onNext;
  
  const ActivityScreen({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              const Text(
                "Activity level",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              const Text(
                "Your activity level helps determine your daily water requirements",
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 40),
              _ActivityOption(
                title: "Sedentary",
                description: "Office worker, minimal physical activity",
                onTap: () => onNext("sedentary"),
                icon: Icons.weekend,
              ),
              _ActivityOption(
                title: "Light",
                description: "Walking, light housework",
                onTap: () => onNext("light"),
                icon: Icons.directions_walk,
              ),
              _ActivityOption(
                title: "Moderate",
                description: "Regular exercise, active job",
                onTap: () => onNext("moderate"),
                icon: Icons.directions_run,
              ),
              _ActivityOption(
                title: "Intense",
                description: "Daily exercise, athlete",
                onTap: () => onNext("intense"),
                icon: Icons.fitness_center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActivityOption extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  const _ActivityOption({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                radius: 25,
                child: Icon(icon, color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
} 