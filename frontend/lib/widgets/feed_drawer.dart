import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';

class FeedDrawer extends StatefulWidget {
  const FeedDrawer({super.key});

  @override
  State<FeedDrawer> createState() => _FeedDrawerState();
}

class _FeedDrawerState extends State<FeedDrawer> with SingleTickerProviderStateMixin {
  final List<String> allTags = [
    'muzyka',
    'sztuka',
    'sport',
    'kino',
    'technologia',
    'literatura'
  ];

  final Set<String> selectedTags = {};
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filteredTags = allTags
        .where((tag) => tag.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return Drawer(
      child: SafeArea(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'MENU',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Szukaj...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey.shade200,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) => setState(() => searchQuery = value),
              ),
              const SizedBox(height: 24),
              const Text(
                'Wybierz interesujące cię tagi:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView(
                  children: filteredTags.map((tag) {
                    return CheckboxListTile(
                      value: selectedTags.contains(tag),
                      onChanged: (checked) {
                        setState(() {
                          if (checked == true) {
                            selectedTags.add(tag);
                          } else {
                            selectedTags.remove(tag);
                          }
                        });
                      },
                      title: Text(tag),
                      contentPadding: EdgeInsets.zero,
                      activeColor: const Color(0xFF4A148C),
                      controlAffinity: ListTileControlAffinity.leading,
                    );
                  }).toList(),
                ),
              ),
              const Divider(),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop(); // zamknij drawer
                  context.push('/likedEvents'); // przejdź do formularza
                },
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Moje wydarzenia'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade300,
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop(); // zamknij drawer
                  context.push('/getEvents'); // przejdź do formularza
                },
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Zakończone wydarzenia'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade300,
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop(); // zamknij drawer
                  context.push('/createEvent'); // przejdź do formularza
                },
                icon: const Icon(Icons.add),
                label: const Text('Dodaj wydarzenie'),
                style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6A1B9A),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
                minimumSize: const Size.fromHeight(48),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: () async {
                    await AuthService.signOut();
                    if (context.mounted) context.go('/');
                  },
                  child: const Text(
                    'Wyloguj się',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.group),
                title: const Text('Twoi znajomi'),
                onTap: () {
                  context.go('/friends');
                },
              ),
              ListTile(
                leading: const Icon(Icons.mail_outline),
                title: const Text('Zaproszenia do znajomych'),
                onTap: () {
                  context.go('/friendRequests');
                },
              ),
              ListTile(
                leading: const Icon(Icons.person_add_alt),
                title: const Text('Wyślij zaproszenie'),
                onTap: () {
                  context.go('/addFriend');
                },
              ),

            ],
          ),
        ),
      ),
    );
  }
}
