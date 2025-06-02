import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OtherUserProfileScreen extends StatefulWidget {
  const OtherUserProfileScreen({Key? key}) : super(key: key);

  @override
  State<OtherUserProfileScreen> createState() => _OtherUserProfileScreenState();
}

class _OtherUserProfileScreenState extends State<OtherUserProfileScreen> {
  // Na razie przykładowe dane „na sztywno”
  String username = 'Imię Nazwisko';
  DateTime dateOfBirth = DateTime(1990, 1, 15);
  bool _isFriend = false;
  bool _isBlocked = false;

  String get _formattedDate {
    final d = dateOfBirth;
    final day = d.day.toString().padLeft(2, '0');
    final month = d.month.toString().padLeft(2, '0');
    final year = d.year.toString();
    return '$day-$month-$year';
  }

  void _toggleFriendStatus() {
    setState(() {
      _isFriend = !_isFriend;
    });
    // Tutaj można wywołać swoją logikę wysłania zaproszenia / usunięcia ze znajomych
  }

  void _sendMessage() {
    // Na razie tylko przykładowe przejście
    context.go('/chat_list');
  }

  void _toggleBlockStatus() {
    setState(() {
      _isBlocked = !_isBlocked;
    });
    // Tutaj można wywołać swoją logikę blokowania / odblokowywania
  }

  @override
  Widget build(BuildContext context) {
    // Ustalmy szerokość dla dwóch innych przycisków
    const otherButtonWidth = 250.0;

    return Scaffold(
      backgroundColor: Colors.white,
      // --- AppBar z przyciskiem powrotu ---
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {
            context.pop();
          },
        ),
        centerTitle: true,
        title: Image.asset(
          'assets/images/appLogoDark.png',
          height: 40,
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // --- Awatar ---
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDE7F6),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 80,
                      color: Color(0xFF6A1B9A),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- Nazwa użytkownika ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.person_outline,
                        color: Colors.black87,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        username,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // --- Data urodzenia ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        color: Colors.black87,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formattedDate,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // --- Przycisk: Wyślij zaproszenie / Usuń ze znajomych ---
                  // Dopasowany do szerokości tekstu + ikony
                  ElevatedButton.icon(
                    onPressed: _toggleFriendStatus,
                    icon: Icon(
                      _isFriend ? Icons.person_remove : Icons.person_add,
                      color: Colors.white,
                    ),
                    label: Text(
                      _isFriend
                          ? 'Usuń ze znajomych'
                          : 'Wyślij zaproszenie do znajomych',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white, // napis biały
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isFriend
                          ? Colors.grey.shade700
                          : const Color(0xFF6A1B9A),
                      padding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // --- Przycisk: Wyślij wiadomość ---
                  SizedBox(
                    width: otherButtonWidth,
                    child: ElevatedButton.icon(
                      onPressed: _sendMessage,
                      icon: const Icon(
                        Icons.chat_bubble_outline,
                        color: Colors.black87,
                      ),
                      label: const Text(
                        'Wyślij wiadomość',
                        style: TextStyle(fontSize: 16, color: Colors.black87),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE1BEE7),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // --- Przycisk: Zablokuj / Odblokuj ---
                  SizedBox(
                    width: otherButtonWidth,
                    child: ElevatedButton.icon(
                      onPressed: _toggleBlockStatus,
                      icon: Icon(
                        _isBlocked ? Icons.lock_open : Icons.block,
                        color: Colors.white,
                      ),
                      label: Text(
                        _isBlocked ? 'Odblokuj' : 'Zablokuj',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white, // napis biały
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isBlocked
                            ? Colors.green.shade600
                            : Colors.red.shade600,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      // --- Dolny pasek nawigacji ---
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2, // Zakładamy, że jesteśmy w „Profilu”
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black87,
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
              context.go('/feed');
              break;
            case 1:
              context.go('/chat_list');
              break;
            case 2:
              context.go('/profile');
              break;
          }
        },
      ),
    );
  }
}
