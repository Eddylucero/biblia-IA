import 'package:flutter/material.dart';

import 'bible/bible_screen.dart';
import 'home/home_screen.dart';
import 'profile/profile_screen.dart';
import '../repositories/bible_repository.dart';

class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;
  final BibleDataSource? dataSource;

  const MainNavigationScreen({
    super.key,
    this.initialIndex = 0,
    this.dataSource,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _selectedIndex;

  List<Widget> get _screens => [
    HomeScreen(dataSource: widget.dataSource),
    BibleScreen(dataSource: widget.dataSource),
    const ProfileScreen(),
  ];

  int _clampSelectedIndex(int index) {
    if (_screens.isEmpty) {
      return 0;
    }
    return index.clamp(0, _screens.length - 1);
  }

  @override
  void initState() {
    super.initState();
    _selectedIndex = _clampSelectedIndex(widget.initialIndex);
  }

  @override
  void didUpdateWidget(covariant MainNavigationScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialIndex != widget.initialIndex) {
      _selectedIndex = _clampSelectedIndex(widget.initialIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_stories_outlined),
            selectedIcon: Icon(Icons.auto_stories),
            label: 'Biblia',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
