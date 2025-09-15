import 'package:flutter/material.dart';
import 'package:my_app/Screens/create_post_screen.dart';
import 'package:my_app/Screens/profile.dart';

class BottomBarNavigation extends StatefulWidget {
  @override
  _BottomBarNavigationState createState() => _BottomBarNavigationState();
}

class _BottomBarNavigationState extends State<BottomBarNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    Center(child: Text('Home Screen')),
    Center(child: Text('Favorites Screen')),
    CreatePostScreen(),
    Center(child: Text('Settings Screen')),
    ProfileScreen(),
  ];

  final Color selectedColor = Color(0xFF1A9C8C);
  final List<Color> gradientColors = [Color(0xFF1A9C8C), Color(0xFF0233A4)];

  void _onTabSelected(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        height: 65,
        margin: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(36),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavIcon(Icons.home, 0),
            _buildNavIcon(Icons.favorite, 1),
            _buildAlwaysFilledAddIcon(2),
            _buildNavIcon(Icons.settings, 3),
            _buildNavIcon(Icons.person, 4),
          ],
        ),
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, int index) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => _onTabSelected(index),
      child: Icon(
        icon,
        color: isSelected ? selectedColor : Colors.grey,
        size: 28,
      ),
    );
  }

  Widget _buildAlwaysFilledAddIcon(int index) {
    return GestureDetector(
      onTap: () => _onTabSelected(index),
      child: Container(
        height: 48,
        width: 48,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradientColors),
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}
