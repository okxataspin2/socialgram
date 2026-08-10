import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// {@template app_boot_gate}
/// Wraps the app after bootstrap. If any startup step failed, the errors are
/// shown on a clear diagnosis screen instead of leaving the user stuck on the
/// splash screen forever.
/// {@endtemplate}
class AppBootGate extends StatelessWidget {
  /// {@macro app_boot_gate}
  const AppBootGate({required this.bootErrors, required this.child, super.key});

  /// Messages collected from failed startup steps.
  final List<String> bootErrors;

  /// The fully built application widget.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (bootErrors.isEmpty) {
      return child;
    }
    return Material(
      color: const Color(0xFF121212),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SocialGram could not start',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Some startup components failed. Reinstall the app or retry in a few minutes on a working connection. Details for support:',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    bootErrors.join('\n'),
                    style: const TextStyle(
                      color: Color(0xFFFF8A80),
                      fontSize: 12,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      // Best-effort retry by relaunching the app entry.
                      SystemNavigator.pop();
                    },
                    child: const Text('Close app'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}