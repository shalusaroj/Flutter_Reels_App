import 'package:flutter/material.dart';

class CoreSetupPage extends StatelessWidget {
  const CoreSetupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Core Setup Completed\n(Next: Reels Home Feature)',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
