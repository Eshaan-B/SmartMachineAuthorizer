import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'screens/splash_screen.dart';
import 'screens/login.dart';
import 'screens/tabs_screen.dart';
import 'screens/machines.dart';
import 'screens/bookings_screen.dart';
import 'screens/select_date.dart';
import 'screens/select_machine.dart';
import 'screens/select_time.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    final Future<FirebaseApp> _initialization = Firebase.initializeApp();

    return FutureBuilder(
        future: _initialization,
        builder: (context, appSnapshot) {
          return MaterialApp(
            home: appSnapshot.connectionState != ConnectionState.waiting
                ? LoginScreen()
                : SplashScreen(),
            routes: {
              TabsScreen.routeName: (ctx) => TabsScreen(),
              MachinesPage.routeName: (ctx) => MachinesPage(),
              BookingsScreen.routeName: (ctx) => BookingsScreen(),
              SelectDate.routeName: (ctx) => SelectDate(),
              SelectMachine.routeName: (ctx) => SelectMachine(),
              SelectTime.routeName: (ctx) => SelectTime(),
            },
          );
        });
  }
}
