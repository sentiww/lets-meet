import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../widgets/feed_drawer.dart';
import '../../../widgets/event_card.dart';
import '../../../models/event.dart'; // <-- jeśli masz model
import '../../../services/event_service.dart'; // <-- ważne

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Event> events = EventService.TEST_events;
    final Event? firstEvent = events.isNotEmpty ? events.first : null;

    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black87),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Image.asset(
          'assets/images/appLogoDark.png',
          height: 40,
        ),
        centerTitle: true,
      ),
      drawer: const FeedDrawer(),
      backgroundColor: const Color(0xFFF5F5F5),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  children: [
                    EventCard(
                      eventId: firstEvent?.id ?? -1,
                      title: firstEvent?.title ?? 'Jazz',
                      location: 'Wyspa Słodowa',
                      dateTime: firstEvent?.eventDate ?? DateTime(2025, 4, 1, 18, 30),
                      imagePath: 'assets/images/eventPhotoDefault.png',
                    ),
                    const SizedBox(height: 24),
                    _ActionButtons(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: const _BottomNavBar(currentIndex: 0),
    );
  }
  
}

class _ActionButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _CircleButton(
          icon: Icons.close,
          color: Colors.redAccent,
        ),
        SizedBox(width: 36),
        _CircleButton(
          icon: Icons.favorite,
          color: Colors.green,
        ),
      ],
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _CircleButton({
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      shape: const CircleBorder(),
      elevation: 6,
      color: Colors.white,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Icon(
            icon,
            size: 36,
            color: color,
          ),
        ),
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  final int currentIndex;

  const _BottomNavBar({required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      backgroundColor: Colors.white,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.grey,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Odkrywaj',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble_outline),
          label: 'Wiadomości',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Profil',
        ),
      ],
      onTap: (index) {
        switch (index) {
          case 0:
          // Jeśli już jesteś na feedzie, nie rób nic
            break;
          case 1:
          // TODO: dodać trasę dla wiadomości
            break;
          case 2:
            context.goNamed('profile');
            break;
        }
      },

    );
  }
}