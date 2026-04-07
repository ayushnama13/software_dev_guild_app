import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/article_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/saved_article_model.dart';

class DatabaseService {
  // Your live AWS EC2 IP
  final String baseUrl = "http://13.60.167.160:8000";

  // Temporary session holder for the presentation demo
  static int? currentUserId;
  static String? currentUserEmail;
  static Future<void> saveSession(int id, String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_id', id);
    await prefs.setString('user_email', email);
    currentUserId = id;
    currentUserEmail = email;
  }

  // 1. SAVE ARTICLE (POST)
  Future<void> saveArticle(Article article, String aiSummary) async {
    if (currentUserId == null) throw Exception('User not logged in');

    final response = await http.post(
      Uri.parse('$baseUrl/bookmarks'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': currentUserId,
        'title': article.title,
        'url': article.url,
        'image_url': article.imageUrl,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to save article: ${response.body}');
    }
  }
  static Future<bool> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('user_id')) {
      currentUserId = prefs.getInt('user_id');
      currentUserEmail = prefs.getString('user_email');
      return true;
    }
    return false;
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    currentUserId = null;
    currentUserEmail = null;
  }
  
  // 2. FETCH LIBRARY (GET)
  Future<List<SavedArticle>> fetchSavedArticles() async {
    if (currentUserId == null) throw Exception('User not logged in');

    final response = await http.get(
      Uri.parse('$baseUrl/bookmarks/$currentUserId'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<dynamic> bookmarks = data['bookmarks'];
      return bookmarks.map((item) => SavedArticle.fromFastApiJson(item)).toList();
    } else {
      throw Exception('Failed to load library');
    }
  }

  // 3. REMOVE ARTICLE (Optional placeholder, as we didn't add DELETE to FastAPI yet)
  // 3. REMOVE ARTICLE (DELETE)
  Future<void> removeSavedArticle(int dbId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/bookmarks/$dbId'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to remove article');
    }
  }
}