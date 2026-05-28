import 'package:flutter/material.dart';

class PlaceholderScreen extends StatelessWidget {
  final String pathName;
  const PlaceholderScreen({super.key, required this.pathName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(pathName)),
      body: Center(
        child: Text('Placeholder for $pathName', style: Theme.of(context).textTheme.headlineMedium),
      ),
    );
  }
}

// Remaining placeholders for screens not yet implemented (Phase 5+)
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override Widget build(BuildContext context) => const PlaceholderScreen(pathName: 'HomeScreen');
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override Widget build(BuildContext context) => const PlaceholderScreen(pathName: 'SettingsScreen');
}
class AdminPanelScreen extends StatelessWidget {
  const AdminPanelScreen({super.key});
  @override Widget build(BuildContext context) => const PlaceholderScreen(pathName: 'AdminPanelScreen');
}
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});
  @override Widget build(BuildContext context) => const PlaceholderScreen(pathName: 'NotificationsScreen');
}
