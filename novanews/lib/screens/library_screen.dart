import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/saved_article_model.dart';
import '../widgets/saved_news_card.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final DatabaseService _dbService = DatabaseService();
  late Future<List<SavedArticle>> _savedArticlesFuture;

  @override
  void initState() {
    super.initState();
    _loadSavedArticles();
  }

  // Update this method:
  void _loadSavedArticles() {
    setState(() {
      // Calls the new method that uses the static currentUserId
      _savedArticlesFuture = _dbService.fetchSavedArticles();
    });
  }

  void _removeArticle(String dbId) async {
    int id = int.tryParse(dbId) ?? 0;
    
    // Calls the new method without the token
    await _dbService.removeSavedArticle(id);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Article removed from library.')),
      );
      _loadSavedArticles();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Library', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        centerTitle: false,
      ),
      body: FutureBuilder<List<SavedArticle>>(
        future: _savedArticlesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.blueAccent));
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error loading library: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bookmark_border, size: 64, color: Colors.grey.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  const Text(
                    "Your library is empty.",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Save articles from the feed to read them later.",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final articles = snapshot.data!;

          return RefreshIndicator(
            color: Colors.blueAccent,
            backgroundColor: const Color(0xFF1A1A1A),
            onRefresh: () async => _loadSavedArticles(),
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 24),
              itemCount: articles.length,
              itemBuilder: (context, index) {
                final savedArticle = articles[index];
                return SavedNewsCard(
                  savedArticle: savedArticle,
                  onRemove: () => _removeArticle(savedArticle.dbId),
                );
              },
            ),
          );
        },
      ),
    );
  }
}