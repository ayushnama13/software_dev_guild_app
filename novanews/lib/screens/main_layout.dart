import 'package:flutter/material.dart';

// Import your tab views
import '../widgets/home_feed_view.dart';
import 'library_screen.dart'; 
import 'profile_screen.dart';
import '../widgets/news_search_delegate.dart';
import '../services/news_api_service.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  // The screens controlled by the Bottom Navigator
  final List<Widget> _screens = [
    const HomeFeedView(), 
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Only show the custom AppBar on the Feed tab (index 0)
      appBar: _currentIndex == 0 ? _buildHomeAppBar(context) : null, 
      
      body: IndexedStack(
        index: _currentIndex,
        children: [
          const HomeFeedView(), // Index 0: Keeps scroll position alive
          
          // Index 1: Destroys and recreates the Library to fetch fresh data every time it's clicked
          _currentIndex == 1 ? const LibraryScreen() : const SizedBox.shrink(), 
          
          // Index 2: Profile Screen
          const ProfileScreen(),
        ],
      ),
      
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Colors.white10, width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: const Color(0xFF1A1A1A),
          selectedItemColor: Colors.blueAccent,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: false,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.public), label: 'Feed'),
            BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: 'Library'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }

  // Passed context here so we can trigger the search modal
  AppBar _buildHomeAppBar(BuildContext context) {
    return AppBar(
      title: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome, color: Colors.blueAccent),
          SizedBox(width: 8),
          Text('NovaNews', style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            showSearch(
              context: context,
              delegate: NewsSearchDelegate(newsService: NewsApiService()),
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: GestureDetector(
            // Tapping the avatar also takes you to the profile tab
            onTap: () => setState(() => _currentIndex = 2), 
            child: const CircleAvatar(
              radius: 16,
              backgroundColor: Colors.blueAccent,
              child: Text('A', style: TextStyle(color: Colors.white, fontSize: 14)), 
            ),
          ),
        ),
      ],
    );
  }
}