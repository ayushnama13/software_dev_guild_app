import 'package:flutter/material.dart';
import '../services/news_api_service.dart';
import '../models/article_model.dart';
import 'news_card.dart';

class NewsSearchDelegate extends SearchDelegate {
  final NewsApiService newsService;

  NewsSearchDelegate({required this.newsService});

  @override
  ThemeData appBarTheme(BuildContext context) {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF121212),
      appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF1A1A1A)),
      inputDecorationTheme: const InputDecorationTheme(border: InputBorder.none),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    // Clear query button
    return [
      IconButton(
        icon: const Icon(Icons.clear, color: Colors.grey),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    // Back button
    return IconButton(
      icon: const Icon(Icons.arrow_back, color: Colors.blueAccent),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.isEmpty) return const SizedBox();

    return FutureBuilder<List<Article>>(
      future: newsService.searchNews(query), // Calls your News API service
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.blueAccent));
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No results found.', style: TextStyle(color: Colors.grey)));
        }

        return ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final article = snapshot.data![index];
            return NewsCard(
              title: article.title,
              imageUrl: article.imageUrl,
              source: article.sourceName,
              description: article.description,
              url: article.url,
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return const Center(
      child: Text('Type to search global news...', style: TextStyle(color: Colors.grey)),
    );
  }
}