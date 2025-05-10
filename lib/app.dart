import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_meet/features/auth/login_screen.dart';
import 'package:lets_meet/features/auth/register_screen.dart';
import 'package:lets_meet/features/events/presentation/feed_screen.dart';

class LetsMeetApp extends StatelessWidget {
  const LetsMeetApp({super.key});

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
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/feed',
      builder: (context, state) => const FeedScreen(),
    ),
  ],
);
