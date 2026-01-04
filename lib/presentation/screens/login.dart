import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  Future<void> _loginWithLINE(BuildContext context) async {
    try {
      await Amplify.Auth.signInWithWebUI(
        provider: AuthProvider.oidc('LINE', 'https://access.line.me'),
      );
      // Hub listener in main.dart will handle navigation
    } catch (e) {
      debugPrint('Login failed: $e');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login failed')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () => _loginWithLINE(context),
          child: const Text('Login with LINE'),
        ),
      ),
    );
  }
}
