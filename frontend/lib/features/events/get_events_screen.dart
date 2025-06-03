import 'package:flutter/material.dart';
import '../../models/event.dart';
import '../../services/event_service.dart';
import '../../widgets/event_card.dart';
import '../../widgets/feed_drawer.dart';

class GetEventsScreen extends StatefulWidget {
  const GetEventsScreen({super.key});

  @override
  State<GetEventsScreen> createState() => _GetEventsScreenState();
}

class _GetEventsScreenState extends State<GetEventsScreen> {
  late Future<List<Event>> _futureEvents;

  @override
  void initState() {
    super.initState();
    _futureEvents = EventService.getEvents();
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
        title: const Text('Wszystkie wydarzenia', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: FutureBuilder<List<Event>>(
                future: _futureEvents,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Błąd: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Brak wydarzeń do wyświetlenia'));
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
                            //title: event.title,
                            //location: 'Nieznana lokalizacja',
                            //dateTime: event.eventDate ?? DateTime.now(),
                            //imagePath: 'assets/images/eventPhotoDefault.png',
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
