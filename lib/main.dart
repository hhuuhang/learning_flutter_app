import 'package:flutter/material.dart';

import 'screens/chatbot_screen.dart';
import 'screens/maps_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.enableNetworkTiles = true});

  final bool enableNetworkTiles;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Map Chat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: HomeShell(enableNetworkTiles: enableNetworkTiles),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.enableNetworkTiles});

  final bool enableNetworkTiles;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          MapsScreen(enableNetworkTiles: widget.enableNetworkTiles),
          const ChatbotScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: 'Bản đồ',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: 'Chatbot',
          ),
        ],
      ),
    );
  }
}
