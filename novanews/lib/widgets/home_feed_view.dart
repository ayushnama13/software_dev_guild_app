import 'package:flutter/material.dart';
import '../services/news_api_service.dart';
import '../models/article_model.dart';
import 'news_card.dart';

class HomeFeedView extends StatefulWidget {
  const HomeFeedView({super.key});

  @override
  State<HomeFeedView> createState() => _HomeFeedViewState();
}

class _HomeFeedViewState extends State<HomeFeedView> {
  final NewsApiService _newsService = NewsApiService();
  late Future<List<Article>> _newsFuture;
  
  String _selectedCategory = 'general';
  
  final List<String> _categories = [
    'General', 'Technology', 'Business', 'Science', 'Health', 'Entertainment'
  ];

  @override
  void initState() {
    super.initState();
    _fetchNews();
  }

  void _fetchNews() {
    setState(() {
      _newsFuture = _newsService.fetchTopHeadlines(category: _selectedCategory.toLowerCase());
    });
  }

  void _onCategorySelected(String category) {
    if (_selectedCategory == category) return;
    setState(() {
      _selectedCategory = category;
      _fetchNews(); 
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- Category Selector ---
        SizedBox(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              final isSelected = _selectedCategory.toLowerCase() == category.toLowerCase();
              
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (_) => _onCategorySelected(category),
                  selectedColor: Colors.blueAccent.withOpacity(0.2),
                  backgroundColor: const Color(0xFF1E1E1E),
                  side: BorderSide(
                    color: isSelected ? Colors.blueAccent : Colors.transparent,
                  ),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.blueAccent : Colors.grey,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              );
            },
          ),
        ),

        // --- Main News List ---
        Expanded(
          child: FutureBuilder<List<Article>>(
            future: _newsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Colors.blueAccent));
              }
              
              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
                        const SizedBox(height: 16),
                        Text(
                          'Failed to load news.\n${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _fetchNews,
                          child: const Text('Try Again'),
                        )
                      ],
                    ),
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text('No articles found for this category.', style: TextStyle(color: Colors.grey)),
                );
              }

              final articles = snapshot.data!;
              return RefreshIndicator(
                color: Colors.blueAccent,
                backgroundColor: const Color(0xFF1A1A1A),
                onRefresh: () async => _fetchNews(),
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 24),
                  itemCount: articles.length,
                  itemBuilder: (context, index) {
                    final article = articles[index];
                    return NewsCard(
                      title: article.title,
                      imageUrl: article.imageUrl,
                      source: article.sourceName,
                      description: article.description,
                      url: article.url, 
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}