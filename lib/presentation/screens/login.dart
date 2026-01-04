import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:prod_kagitoban_app/presentation/screens/calendar.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  Future<void> _loginWithLINE(BuildContext context) async {
    try {
      await Amplify.Auth.signInWithWebUI(
        provider: AuthProvider.oidc('LINE', 'https://access.line.me'),
      );

      // ✅ If we reach here, login succeeded
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const CalendarScreen()),
        );
      }
    } catch (e) {
      debugPrint('Login failed: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login failed')),
      );
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
