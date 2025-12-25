import 'package:flutter/material.dart';

/// Training Ground Detail Screen
///
/// Screen for training ground with background image only
class CenterHubDetailScreen extends StatelessWidget {
  const CenterHubDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/training_ground.png'),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
