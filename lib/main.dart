import 'package:flutter/material.dart';
import 'package:prod_kagitoban_app/presentation/screens/calendar.dart';
import 'package:prod_kagitoban_app/presentation/screens/members.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const CalendarScreen(),
      routes: {
        CalendarScreen.routeName: (context) => const CalendarScreen(),
        MembersScreen.routeName: (context) => const MembersScreen(),
      },
    );
  }
}
