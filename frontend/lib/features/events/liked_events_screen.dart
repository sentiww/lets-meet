import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/event.dart';
import '../../services/event_service.dart';
import '../../services/feed_service.dart';
import '../../widgets/event_card.dart';
import '../../widgets/feed_drawer.dart';

class LikedEventsScreen extends StatefulWidget {
  const LikedEventsScreen({super.key});

  @override
  State<LikedEventsScreen> createState() => _LikedEventsScreenState();
}

class _LikedEventsScreenState extends State<LikedEventsScreen> {
  late Future<List<Event>> _futureLikedEvents;

  @override
  void initState() {
    super.initState();
    _futureLikedEvents = _loadLikedEvents();
  }

  Future<List<Event>> _loadLikedEvents() async {
    final now = DateTime.now();
    final likedIds = await FeedService.fetchLikedEventIds();
    final events = <Event>[];

    for (final id in likedIds) {
      final event = await EventService.getEvent(id);
      if (event != null
          && event.eventDate != null
          && event.eventDate!.isAfter(now)) {
        events.add(event);
      }
    }

    return events;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const FeedDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black87),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        title: GestureDetector(
          onTap: () => context.go('/feed'),
          child: Image.asset(
            'assets/images/appLogoDark.png',
            height: 32,
            fit: BoxFit.contain,
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: FutureBuilder<List<Event>>(
                future: _futureLikedEvents,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Błąd: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Brak nadchodzących polubionych wydarzeń'));
                  }

                  final events = snapshot.data!;
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    child: Column(
                      children: events.map((event) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: EventCard(eventId: event.id),
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
