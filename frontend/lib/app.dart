import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_meet/features/auth/login_screen.dart';
import 'package:lets_meet/features/auth/register_screen.dart';
import 'package:lets_meet/features/events/feed_screen.dart';
import 'package:lets_meet/features/profile/my_profile_screen.dart';
import 'package:lets_meet/features/events/create_event_screen.dart';
import 'package:lets_meet/features/events/liked_events_screen.dart';

import 'features/profile/edit_profile_screen.dart';
import 'features/events/event_screen.dart';
import 'features/events/get_events_screen.dart';

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
    GoRoute(
      path: '/profile',
      name: 'profile',
      builder: (context, state) => const MyProfileScreen(),
    ),
    GoRoute(
      path: '/editProfile',
      name: 'editProfile',
      builder: (context, state) => const EditProfileScreen(),
    ),
    GoRoute(
    path: '/createEvent',
    name: 'createEvent',
    builder: (context, state) => const CreateEventScreen(),
    ),
    GoRoute(
      path: '/event/:id',
      name: 'eventProfile',
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '');
        if (id == null) {
          return const Scaffold(body: Center(child: Text('Nieprawidłowe ID wydarzenia')));
        }
        return EventProfileScreen(eventId: id);
      },
    ),
    GoRoute(
    path: '/getEvents',
    name: 'getEvents',
    builder: (context, state) => const GetEventsScreen(),
    ),
     GoRoute(
    path: '/likedEvents',
    name: 'likedEvents',
    builder: (context, state) => const LikedEventsScreen(),
    ),
  ],
);
