import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/google_sign_in_provider.dart';
import 'auth_page.dart';
import 'navigation_wrapper.dart';

class StartPage extends StatelessWidget {
  const StartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final googleProvider = Provider.of<GoogleSignInProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Welcome'),
        backgroundColor: Colors.cyan.shade700,
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _LoginButton(
                label: 'Login by Email',
                icon: Icons.email,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AuthPage()),
                  );
                },
              ),
              const SizedBox(height: 16),
              _LoginButton(
                label: 'Login with Google',
                icon: Icons.g_mobiledata,
                onPressed: () async {
                  try {
                    debugPrint('🟢 Google Sign-In button clicked');
                    await googleProvider.signInWithGoogle();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Google Sign-In failed: $e')),
                    );
                  }
                },
              ),
              const SizedBox(height: 16),
              _LoginButton(
                label: 'Continue as Guest',
                icon: Icons.person_outline,
                backgroundColor: Colors.orange,
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => const NavigationWrapper(isGuest: true),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoginButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final Color backgroundColor;

  const _LoginButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.backgroundColor = Colors.cyan,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: Icon(icon, size: 24),
        label: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Text(label, style: const TextStyle(fontSize: 16)),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: onPressed,
      ),
    );
  }
}
