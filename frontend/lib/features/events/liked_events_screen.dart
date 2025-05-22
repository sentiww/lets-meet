import 'package:flutter/material.dart';
import '../../models/event.dart';
import '../../services/event_service.dart';
import '../../services/feed_service.dart';
import '../../services/auth_service.dart';
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
    try {
      final likedIds = await FeedService.fetchLikedEventIds();

      final events = <Event>[];
      for (final id in likedIds) {
        final event = await EventService.getEvent(id);
        if (event != null) {
          events.add(event);
        }
      }

      return events;
    } catch (e) {
      rethrow;
    }
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
        title: const Text('Polubione wydarzenia', style: TextStyle(color: Colors.black)),
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
                    return const Center(child: Text('Brak polubionych wydarzeń'));
                  }

                  final events = snapshot.data!;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    child: Column(
                      children: events.map((event) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: EventCard(
                            eventId: event.id,
                            title: event.title,
                            location: 'Nieznana lokalizacja',
                            dateTime: event.eventDate ?? DateTime.now(),
                            imagePath: 'assets/images/eventPhotoDefault.png',
                          ),
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
