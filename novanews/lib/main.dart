import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './screens/auth_screen.dart'; // Verify this path
import 'screens/main_layout.dart';      
import 'services/database_service.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.dark);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  
  // Check if user is already logged in
  bool isLoggedIn = await DatabaseService.loadSession(); 
  final prefs = await SharedPreferences.getInstance();
  final isDarkSaved = prefs.getBool('is_dark_theme') ?? true;
  themeNotifier.value = isDarkSaved ? ThemeMode.dark : ThemeMode.light;
  
  runApp(NovaNewsApp(isLoggedIn: isLoggedIn));
}

class NovaNewsApp extends StatelessWidget {
  final bool isLoggedIn;
  const NovaNewsApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          title: 'NovaNews',
          debugShowCheckedModeBanner: false,
          themeMode: currentMode,
          
          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: const Color(0xFFF5F5F5),
            primaryColor: Colors.blueAccent,
            colorScheme: const ColorScheme.light(primary: Colors.blueAccent, secondary: Colors.black),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white, elevation: 0, centerTitle: true,
              iconTheme: IconThemeData(color: Colors.black),
              titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ),

          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF121212),
            primaryColor: Colors.blueAccent,
            colorScheme: const ColorScheme.dark(primary: Colors.blueAccent, secondary: Colors.white),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF1A1A1A), elevation: 0, centerTitle: true,
              titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),

          // Dynamically set the first screen
          initialRoute: isLoggedIn ? '/home' : '/login', 
          routes: {
            '/login': (context) => const CombinedAuthPage(), 
            '/home': (context) => const MainLayout(),        
          },
        );
      }
    );
  }
}