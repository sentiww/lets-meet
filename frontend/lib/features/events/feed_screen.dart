import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../widgets/feed_drawer.dart';
import '../../../widgets/event_card.dart';
import '../../../models/feed_event.dart';  // Use the correct model
import '../../../services/feed_service.dart'; // Your service with getFeed() & likeEvent()

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  FeedEvent? _currentEvent;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadNextEvent();
  }

  Future<void> _loadNextEvent() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final event = await FeedService.fetchFeedEvent();
      setState(() {
        _currentEvent = event;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load event';
        _isLoading = false;
      });
    }
  }

  Future<void> _likeCurrentEvent() async {
    if (_currentEvent == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await FeedService.likeEvent(_currentEvent!.eventId);
      await _loadNextEvent(); // Load a new event after liking
    } catch (e) {
      setState(() {
        _error = 'Failed to like event';
        _isLoading = false;
      });
    }
  }

  Future<void> _dislikeCurrentEvent() async {
    // Just load new event without liking
    await _loadNextEvent();
  }

  @override
  Widget build(BuildContext context) {
    Widget bodyContent;

    if (_isLoading) {
      bodyContent = const Center(child: CircularProgressIndicator());
    } else if (_error != null) {
      bodyContent = Center(child: Text(_error!));
    } else if (_currentEvent == null) {
      bodyContent = const Center(child: Text('No more events'));
    } else {
      // Show the event
      bodyContent = Column(
        children: [
          EventCard(
            eventId: _currentEvent!.eventId,
            title: _currentEvent!.title,
            location: 'Unknown location', // You can add location if you have it
            dateTime: DateTime.now(), // You can update if eventDate is available
            imagePath: 'assets/images/eventPhotoDefault.png', // You can map photos if needed
          ),
          const SizedBox(height: 24),
          _ActionButtons(
            onLike: _likeCurrentEvent,
            onDislike: _dislikeCurrentEvent,
          ),
        ],
      );
    }

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
                child: bodyContent,
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
  final VoidCallback onLike;
  final VoidCallback onDislike;

  const _ActionButtons({
    required this.onLike,
    required this.onDislike,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _CircleButton(
          icon: Icons.close,
          color: Colors.redAccent,
          onTap: onDislike,
        ),
        const SizedBox(width: 36),
        _CircleButton(
          icon: Icons.favorite,
          color: Colors.green,
          onTap: onLike,
        ),
      ],
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _CircleButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      shape: const CircleBorder(),
      elevation: 6,
      color: Colors.white,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
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
            // Already on feed
            break;
          case 1:
            // TODO: messages route
            break;
          case 2:
            context.goNamed('profile');
            break;
        }
      },
    );
  }
}
