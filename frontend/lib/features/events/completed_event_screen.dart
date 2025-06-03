import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/event.dart';
import '../../services/event_service.dart';
import '../../services/feed_service.dart';
import '../../widgets/event_card.dart';
import '../../widgets/feed_drawer.dart';

class CompletedEventsScreen extends StatefulWidget {
  const CompletedEventsScreen({super.key});

  @override
  State<CompletedEventsScreen> createState() => _CompletedEventsScreenState();
}

class _CompletedEventsScreenState extends State<CompletedEventsScreen> {
  late Future<List<Event>> _futureCompletedEvents;

  @override
  void initState() {
    super.initState();
    _futureCompletedEvents = _loadCompletedEvents();
  }

  Future<List<Event>> _loadCompletedEvents() async {
    final now = DateTime.now();
    final likedIds = await FeedService.fetchLikedEventIds();
    final events = <Event>[];

    for (final id in likedIds) {
      final event = await EventService.getEvent(id);
      if (event != null && event.eventDate != null && event.eventDate!.isBefore(now)) {
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
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black87),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text(
          'Zakończone wydarzenia',
          style: TextStyle(color: Colors.black87),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () {
              context.go('/feed');
            },
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: FutureBuilder<List<Event>>(
                future: _futureCompletedEvents,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Błąd: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Brak zakończonych wydarzeń'));
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
