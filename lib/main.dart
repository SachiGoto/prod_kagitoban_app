import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:prod_kagitoban_app/core/api_loading_controller.dart';
import 'package:prod_kagitoban_app/models/ModelProvider.dart';
import 'package:prod_kagitoban_app/presentation/widgets/api_loading_overlay.dart';
import 'package:prod_kagitoban_app/view_models/calendarViewModel.dart';
import 'package:prod_kagitoban_app/view_models/memberViewMode.dart';
import 'package:provider/provider.dart';

import 'package:prod_kagitoban_app/amplify_outputs.dart';

import 'package:prod_kagitoban_app/presentation/screens/calendar.dart';
import 'package:prod_kagitoban_app/presentation/screens/login.dart';
import 'package:prod_kagitoban_app/presentation/screens/members.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await _configureAmplify();
    runApp(MultiProvider(providers: [
      ChangeNotifierProvider(create: (_) => CalendarViewModel()),
      ChangeNotifierProvider(create: (_) => MemberViewModel()),
    ], child: const MyApp()));
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
      AmplifyAPI(
          options: APIPluginOptions(modelProvider: ModelProvider.instance))
    ]);
    // await Amplify.configure(amplifyConfig);
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
    await ApiLoadingController.instance.run(() async {
      try {
        final session =
            await Amplify.Auth.fetchAuthSession() as CognitoAuthSession;

        debugPrint('Auth session: signedIn=${session.isSignedIn}');

        if (!mounted) return;
        setState(() {
          _isSignedIn = session.isSignedIn;
          _isCheckingAuth = false;
        });
      } catch (e) {
        debugPrint('Auth check error: $e');
        if (!mounted) return;
        setState(() {
          _isSignedIn = false;
          _isCheckingAuth = false;
        });
      }
    });
  }

  /// 🔁 Listen for Hosted UI / Auth changes
  void _listenToAuthEvents() {
    Amplify.Hub.listen(HubChannel.Auth, (event) async {
      debugPrint('🔥 Auth Hub event: ${event.eventName}');

      if (event.eventName == 'signedIn') {
        if (!mounted) return;
        setState(() => _isSignedIn = true);
      }

      if (event.eventName == 'signedOut') {
        if (!mounted) return;
        setState(() => _isSignedIn = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingAuth) {
      return const MaterialApp(
        home: ApiLoadingScreen(),
      );
    }

    // return MaterialApp(
    //   home: const CalendarScreen(),
    //   routes: {
    //     CalendarScreen.routeName: (_) => const CalendarScreen(),
    //     MembersScreen.routeName: (_) => MembersScreen(),
    //   },
    // );

    return MaterialApp(
      builder: (context, child) => ApiLoadingOverlay(
        child: child ?? const SizedBox.shrink(),
      ),
      home: _isSignedIn ? const CalendarScreen() : const LoginPage(),
      routes: {
        CalendarScreen.routeName: (_) => const CalendarScreen(),
        MembersScreen.routeName: (_) => MembersScreen(),
      },
    );
  }
}
