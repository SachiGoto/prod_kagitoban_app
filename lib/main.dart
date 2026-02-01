import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:prod_kagitoban_app/view_models/calendarViewModel.dart';
import 'package:provider/provider.dart';

import 'package:prod_kagitoban_app/amplify_outputs.dart';

import 'package:prod_kagitoban_app/presentation/screens/calendar.dart';
import 'package:prod_kagitoban_app/presentation/screens/login.dart';
import 'package:prod_kagitoban_app/presentation/screens/members.dart';
import 'package:prod_kagitoban_app/services/line_user_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await _configureAmplify();
    runApp(MultiProvider(
        providers: [ChangeNotifierProvider(create: (_) => CalendarViewModel())],
        child: const MyApp()));
  } on AmplifyException catch (e) {
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Error configuring Amplify: ${e.message}'),
          ),
        ),
      ),
    );
  }
}

Future<void> _configureAmplify() async {
  try {
    await Amplify.addPlugins([
      AmplifyAuthCognito(),
      AmplifyAPI(),
    ]);
    await Amplify.configure(amplifyConfig);
  } on AmplifyAlreadyConfiguredException {
    debugPrint('Amplify already configured');
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isCheckingAuth = true;
  bool _isSignedIn = false;

  @override
  void initState() {
    super.initState();
    _listenToAuthEvents();
    _checkAuth();
  }

  /// 🔐 Check current auth state (NO side effects)
  Future<void> _checkAuth() async {
    try {
      final session =
          await Amplify.Auth.fetchAuthSession() as CognitoAuthSession;

      debugPrint('Auth session: signedIn=${session.isSignedIn}');

      if (session.isSignedIn) {
        await _ensureLineUserExists();
      }

      setState(() {
        _isSignedIn = session.isSignedIn;
        _isCheckingAuth = false;
      });
    } catch (e) {
      debugPrint('Auth check error: $e');
      setState(() {
        _isSignedIn = false;
        _isCheckingAuth = false;
      });
    }
  }

  /// 🔁 Listen for Hosted UI / Auth changes
  void _listenToAuthEvents() {
    Amplify.Hub.listen(HubChannel.Auth, (event) async {
      debugPrint('🔥 Auth Hub event: ${event.eventName}');

      if (event.eventName == 'signedIn') {
        await _ensureLineUserExists();
        setState(() => _isSignedIn = true);
      }

      if (event.eventName == 'signedOut') {
        setState(() => _isSignedIn = false);
      }
    });
  }

  /// 👤 Create LineUser ONCE (idempotent)
  Future<void> _ensureLineUserExists() async {
    try {
      final session =
          await Amplify.Auth.fetchAuthSession() as CognitoAuthSession;

      final tokens = session.userPoolTokensResult.value;
      if (tokens == null) {
        debugPrint('⚠️ No user pool tokens');
        return;
      }

      final claims = tokens.idToken.claims.toJson();

      // final userId = claims['sub'] as String?;
      final identities = claims['identities'] as List<dynamic>?;
      final userId = identities?.cast<Map<String, dynamic>>().firstWhere(
            (i) => i['providerName'] == 'LINE',
            orElse: () => {},
          )['userId'] as String?;

      if (userId == null) {
        debugPrint('⚠️ No sub claim');
        return;
      }

      await LineUserService.createLineUserIfNotExists(
        id: userId as String,
        name: claims['preferred_username'] as String?,
        email: claims['email'] as String?,
        avatar: claims['picture'] as String?,
      );

      debugPrint('✅ LineUser ensured in DynamoDB');
    } catch (e, st) {
      debugPrint('❌ Failed to ensure LineUser: $e');
      debugPrint(st.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingAuth) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return MaterialApp(
      home: _isSignedIn ? const CalendarScreen() : const LoginPage(),
      routes: {
        CalendarScreen.routeName: (_) => const CalendarScreen(),
        MembersScreen.routeName: (_) => MembersScreen(),
      },
    );
  }
}
