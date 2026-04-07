import 'package:flutter/material.dart';
import '../services/database_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart'; // <--- Import main.dart to access the themeNotifier

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final DatabaseService _dbService = DatabaseService();
  int _savedArticleCount = 0;
  bool _isLoadingStats = true;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    try {
      final savedArticles = await _dbService.fetchSavedArticles();
      if (mounted) {
        setState(() {
          _savedArticleCount = savedArticles.length;
          _isLoadingStats = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingStats = false);
    }
  }

  void _handleLogout(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        title: Text('Sign Out', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
        content: Text('Are you sure you want to sign out of NovaNews?', style: TextStyle(color: isDark ? Colors.grey : Colors.black54)),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(context); 
              await DatabaseService.clearSession(); // <--- Clears SharedPrefs
              if (mounted) Navigator.pushReplacementNamed(context, '/login');
            }, 
            child: Text('Cancel', style: TextStyle(color: isDark ? Colors.grey : Colors.black54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              Navigator.pop(context); 
              DatabaseService.currentUserId = null;
              DatabaseService.currentUserEmail = null;
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final email = DatabaseService.currentUserEmail ?? 'guest@example.com';
    final displayName = email.split('@')[0];
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';

    // --- CHECK CURRENT THEME ---
    final isDark = themeNotifier.value == ThemeMode.dark;
    
    // --- SET DYNAMIC COLORS ---
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.grey : Colors.black54;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Settings', style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
        backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        iconTheme: IconThemeData(color: textColor),
        elevation: 0,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.blueAccent,
                child: Text(initial, style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              displayName, 
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor),
            ),
            const SizedBox(height: 4),
            Text(
              email, 
              style: TextStyle(fontSize: 14, color: subTextColor),
            ),
            const SizedBox(height: 32),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatColumn('Articles Read', '124', textColor, subTextColor), 
                Container(height: 40, width: 1, color: isDark ? Colors.white10 : Colors.black12), 
                _buildStatColumn(
                  'Saved to Library', 
                  _isLoadingStats ? '...' : '$_savedArticleCount',
                  textColor, subTextColor
                ),
              ],
            ),
            const SizedBox(height: 32),

            _buildSettingsTile(
              icon: Icons.person_outline,
              title: 'Account Information',
              textColor: textColor, cardColor: cardColor,
              onTap: () {},
            ),
            _buildSettingsTile(
              icon: Icons.notifications_outlined,
              title: 'Notifications',
              textColor: textColor, cardColor: cardColor,
              onTap: () {},
            ),
            
            // --- THE UPDATED TOGGLE BUTTON ---
            _buildSettingsTile(
              icon: isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
              title: 'App Appearance',
              textColor: textColor, cardColor: cardColor,
              trailing: Text(
                isDark ? 'Dark' : 'Light', 
                style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)
              ),
              onTap: () async {
                final newIsDark = !isDark;
                themeNotifier.value = newIsDark ? ThemeMode.dark : ThemeMode.light;
                // Change the global app theme
                
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('is_dark_theme', newIsDark);
                // Force this screen to rebuild and update its text colors
                setState(() {});
              },
            ),
            
            _buildSettingsTile(
              icon: Icons.security,
              title: 'Data & Privacy',
              textColor: textColor, cardColor: cardColor,
              onTap: () {},
            ),
            
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _handleLogout(context, isDark),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.redAccent),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.logout, color: Colors.redAccent),
                label: const Text(
                  'Sign Out',
                  style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            Text('NovaNews v1.0.0', style: TextStyle(color: isDark ? Colors.white24 : Colors.black26, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String count, Color textColor, Color subTextColor) {
    return Column(
      children: [
        Text(count, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: subTextColor)),
      ],
    );
  }

  Widget _buildSettingsTile({
    required IconData icon, 
    required String title, 
    Widget? trailing, 
    required VoidCallback onTap,
    required Color textColor,
    required Color cardColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        // Add a soft shadow in light mode so the cards stand out from the background
        boxShadow: [
          if (cardColor == Colors.white) 
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
        ]
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.blueAccent),
        title: Text(title, style: TextStyle(color: textColor)),
        trailing: trailing ?? const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}