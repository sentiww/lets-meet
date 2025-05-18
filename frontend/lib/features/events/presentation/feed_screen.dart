import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../widgets/feed_drawer.dart';
import '../event_service.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  List<Map<String, dynamic>> _events = [];
  int _currentIndex = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    try {
      final events = await EventService.getEvents();
      setState(() {
        _events = events;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nie udało się pobrać wydarzeń')),
      );
    }
  }

  void _handleSwipe(bool attending) async {
    if (_currentIndex >= _events.length) return;
    final eventId = _events[_currentIndex]['id'];
    await EventService.reactToEvent(eventId, attending);
    setState(() => _currentIndex++);
  }

  @override
  Widget build(BuildContext context) {
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
          if (_loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_currentIndex >= _events.length) {
            return const Center(child: Text('Brak dalszych wydarzeń'));
          }

          final event = _events[_currentIndex];

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Dismissible(
                key: ValueKey(event['id']),
                direction: DismissDirection.horizontal,
                onDismissed: (direction) {
                  final attending = direction == DismissDirection.endToStart ? false : true;
                  _handleSwipe(attending);
                },
                background: Container(
                  color: Colors.green,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 32),
                  child: const Icon(Icons.check, color: Colors.white, size: 32),
                ),
                secondaryBackground: Container(
                  color: Colors.redAccent,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 32),
                  child: const Icon(Icons.close, color: Colors.white, size: 32),
                ),
                child: _EventCard(title: event['title']),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: const _BottomNavBar(currentIndex: 0),
    );
  }
}

class _EventCard extends StatelessWidget {
  final String title;
  const _EventCard({required this.title});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                'assets/images/eventPhotoDefault.png',
                height: 280,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Row(
              children: [
                Icon(Icons.location_on, size: 22),
                SizedBox(width: 6),
                Text(
                  'Miejsce wydarzenia',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Row(
              children: [
                Icon(Icons.calendar_today, size: 22),
                SizedBox(width: 6),
                Text(
                  'Data wydarzenia',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Row(
              children: [
                Icon(Icons.access_time, size: 22),
                SizedBox(width: 6),
                Text(
                  'Godzina wydarzenia',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
          ],
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
            break;
          case 1:
            break;
          case 2:
            context.goNamed('profile');
            break;
        }
      },
    );
  }
}