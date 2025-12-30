import 'package:flutter/material.dart';
import 'home/home_screen.dart';
import 'chat/chat_screen.dart';
import 'medications/medications_screen.dart';
import 'devices/devices_screen.dart';
import '../widgets/app_drawer.dart';

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
    MedicationsScreen(),
    DevicesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final titles = ['Dashboard', 'Chat', 'Medikamente', 'Geräte'];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_currentIndex]),
        automaticallyImplyLeading: false, // Hamburger Menu
      ),
      endDrawer: const AppDrawer(),
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
          BottomNavigationBarItem(
            icon: Icon(Icons.medication),
            label: 'Medikamente',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.devices), label: 'Geräte'),
        ],
      ),
    );
  }
}
