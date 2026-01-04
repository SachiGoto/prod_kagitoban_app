import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:prod_kagitoban_app/amplifyconfigration.dart';
import 'package:prod_kagitoban_app/presentation/screens/calendar.dart';
import 'package:prod_kagitoban_app/presentation/screens/login.dart';
import 'package:prod_kagitoban_app/presentation/screens/members.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _configureAmplify();
  runApp(const MyApp());
}

Future<void> _configureAmplify() async {
  try {
    await Amplify.addPlugin(AmplifyAuthCognito());
    await Amplify.configure(amplifyconfig);
  } on AmplifyAlreadyConfiguredException {
    // Safe to ignore
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
    _checkAuth();
    _listenToAuthEvents();
  }

  void _listenToAuthEvents() {
    Amplify.Hub.listen(HubChannel.Auth, (event) {
      if (event.eventName == 'SIGNED_IN') {
        setState(() {
          _isSignedIn = true;
        });
      } else if (event.eventName == 'SIGNED_OUT') {
        setState(() {
          _isSignedIn = false;
        });
      }
    });
  }

  Future<void> _checkAuth() async {
    try {
      final session = await Amplify.Auth.fetchAuthSession();
      debugPrint('Auth session check: isSignedIn = ${session.isSignedIn}');
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

  @override
  Widget build(BuildContext context) {
    if (_isCheckingAuth) {
      return MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return MaterialApp(
      home: _isSignedIn ? const CalendarScreen() : const LoginPage(),
      routes: {
        CalendarScreen.routeName: (context) => const CalendarScreen(),
        MembersScreen.routeName: (context) => const MembersScreen(),
      },
    );
    // return MaterialApp(
    //   home: const CalendarScreen(),
    //   routes: {
    //     CalendarScreen.routeName: (context) => const CalendarScreen(),
    //     MembersScreen.routeName: (context) => const MembersScreen(),
    //   },
    // );
  }
}
