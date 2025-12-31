import 'package:flutter/material.dart';
import 'package:medi_rag_app/widgets/app_drawer.dart';
import 'home/home_screen.dart';
import 'chat/chat_screen.dart';
import 'therapy/therapy_screen.dart';
import 'profile/profile_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    ChatScreen(),
    TherapyScreen(), // NEU!
    ProfileScreen(), // NEU!
  ];

  @override
  Widget build(BuildContext context) {
    final titles = ['Heute', 'Chat', 'Therapie', 'Profil'];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_currentIndex]),
        automaticallyImplyLeading: false,
        actions: [
          // Drawer Icon nur bei Profil (Index 3)
          if (_currentIndex == 3)
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () => Scaffold.of(context).openEndDrawer(),
              ),
            ),
        ],
      ),
      endDrawer: _currentIndex == 3
          ? const AppDrawer()
          : null, // Nur bei Profil!
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Heute'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.healing), label: 'Therapie'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
