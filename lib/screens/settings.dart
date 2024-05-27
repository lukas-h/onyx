import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: ListTile(
            title: Text(
              'Settings',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
          ),
        ),
        Expanded(
          child: ListView(
            children: const [],
          ),
        ),
      ],
    );
  }
}
