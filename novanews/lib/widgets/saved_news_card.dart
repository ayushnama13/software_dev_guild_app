import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/saved_article_model.dart';

class SavedNewsCard extends StatelessWidget {
  final SavedArticle savedArticle;
  final VoidCallback onRemove;

  const SavedNewsCard({
    super.key,
    required this.savedArticle,
    required this.onRemove,
  });

  Future<void> _launchUrl(BuildContext context) async {
    final Uri uri = Uri.parse(savedArticle.article.url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the article.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final article = savedArticle.article;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      elevation: 4,
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image & Remove Button Stack
          Stack(
            children: [
              Container(
                height: 180,
                width: double.infinity,
                color: const Color(0xFF2A2A2A),
                child: article.imageUrl.isNotEmpty
                    ? Image.network(article.imageUrl, fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, color: Colors.grey))
                    : const Icon(Icons.image_not_supported, color: Colors.grey),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: CircleAvatar(
                  backgroundColor: Colors.black.withOpacity(0.7),
                  child: IconButton(
                    icon: const Icon(Icons.bookmark_remove, color: Colors.redAccent),
                    tooltip: "Remove from Library",
                    onPressed: onRemove,
                  ),
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  article.sourceName.toUpperCase(),
                  style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.2),
                ),
                const SizedBox(height: 8),
                Text(
                  article.title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, height: 1.3),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),

                // Pre-Generated AI Summary (Always Visible)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.auto_awesome, color: Colors.blueAccent, size: 16),
                          SizedBox(width: 8),
                          Text('Saved AI Overview', style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        savedArticle.aiSummary,
                        style: const TextStyle(fontStyle: FontStyle.italic, height: 1.4, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () => _launchUrl(context),
                    icon: const Icon(Icons.open_in_new, size: 16, color: Colors.grey),
                    label: const Text('Read Full Article', style: TextStyle(color: Colors.grey)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}