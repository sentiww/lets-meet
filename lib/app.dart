import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_meet/features/auth/login_screen.dart';

class LetsMeetApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Let\'s Meet',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routerConfig: _router,
    );
  }
}

final GoRouter _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => LoginScreen(),
    ),
    // później dodasz resztę ekranów
  ],
);
