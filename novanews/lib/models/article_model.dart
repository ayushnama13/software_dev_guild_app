class Article {
  final String sourceName;
  final String? author;
  final String title;
  final String description;
  final String url;
  final String imageUrl;
  final String publishedAt;
  final String content;

  Article({
    required this.sourceName,
    this.author,
    required this.title,
    required this.description,
    required this.url,
    required this.imageUrl,
    required this.publishedAt,
    required this.content,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      // Safely access nested 'source' object
      sourceName: json['source']?['name'] ?? 'Unknown Source',
      author: json['author'],
      title: json['title'] ?? 'No Title Available',
      // Provide fallback strings for null text fields
      description: json['description'] ?? 'No description available for this article.',
      url: json['url'] ?? '',
      // Provide a fallback image URL or leave empty to handle in UI
      imageUrl: json['urlToImage'] ?? '', 
      publishedAt: json['publishedAt'] ?? '',
      content: json['content'] ?? '',
    );
  }
}