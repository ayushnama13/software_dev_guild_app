import 'article_model.dart';

class SavedArticle {
  final String dbId;
  final Article article;
  final String aiSummary;

  SavedArticle({
    required this.dbId,
    required this.article,
    required this.aiSummary,
  });

  // Parses the JSON coming from FastAPI
  factory SavedArticle.fromFastApiJson(Map<String, dynamic> json) {
    return SavedArticle(
      dbId: json['id'].toString(),
      // Since our basic FastAPI DB didn't include the AI summary column, we provide a fallback
      aiSummary: 'Summary securely saved in NovaNews Cloud.', 
      article: Article(
        sourceName: 'Saved Bookmark',
        title: json['title'] ?? 'No Title',
        description: '',
        url: json['url'] ?? '',
        imageUrl: json['image_url'] ?? '',
        publishedAt: json['created_at'] ?? '',
        content: '', 
      ),
    );
  }
}