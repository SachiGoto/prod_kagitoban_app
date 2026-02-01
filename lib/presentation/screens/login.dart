import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:prod_kagitoban_app/services/line_user_service.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  Future<void> _loginWithLINE(BuildContext context) async {
    try {
      await Amplify.Auth.signInWithWebUI(
        // provider: AuthProvider.oidc('LINE', 'https://access.line.me'),
        provider: AuthProvider.custom('LINE'),
      );
      // Get LINE user info from token
      // final session =
      //     await Amplify.Auth.fetchAuthSession() as CognitoAuthSession;

      // final claims = session.userPoolTokensResult.value.idToken.claims.toJson();

      // final userId = claims['sub'] as String?;
      // final name = claims['name'] as String?;
      // final email = claims['email'] as String?;
      // final avatar = claims['picture'] as String?;

      // if (userId == null) {
      //   throw Exception('User ID (sub) not found in token');
      // }

      // await LineUserService.createLineUser(
      //   id: userId,
      //   name: name,
      //   email: email,
      //   avatar: avatar,
      // );
      // debugPrint(claims.toString());

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
