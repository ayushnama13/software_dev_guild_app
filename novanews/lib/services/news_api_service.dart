import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/article_model.dart'; 

class NewsApiService {
  static const String _baseUrl = 'https://newsapi.org/v2';
  
  // Fetch the key securely through dotenv
  String get _apiKey {
    final key = dotenv.env['NEWS_API_KEY'];
    if (key == null || key.isEmpty) {
      throw Exception('NEWS_API_KEY not found in .env file');
    }
    return key;
  }

  Future<List<Article>> fetchTopHeadlines({String category = 'general'}) async {
    final Uri url = Uri.parse(
        '$_baseUrl/top-headlines?country=us&category=$category&apiKey=$_apiKey');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['status'] == 'ok') {
          final List<dynamic> articlesJson = data['articles'];
          return articlesJson
              .where((json) => json['title'] != '[Removed]')
              .map((json) => Article.fromJson(json))
              .toList();
        } else {
          throw Exception('API Error: ${data['message']}');
        }
      } else {
        throw Exception('Failed to load news. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching top headlines: $e');
    }
  }

  // Add this method to your existing class
  Future<List<Article>> searchNews(String query) async {
    final Uri url = Uri.parse(
        '$_baseUrl/everything?q=$query&sortBy=relevancy&apiKey=$_apiKey');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> articlesJson = data['articles'];
        return articlesJson
            .where((json) => json['title'] != '[Removed]')
            .map((json) => Article.fromJson(json))
            .toList();
      } else {
        throw Exception('Search failed');
      }
    } catch (e) {
      throw Exception('Error searching news: $e');
    }
  }

  // (Include the searchNews method here, updated similarly)
}