import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/gemini_service.dart';
import '../services/database_service.dart';
import '../models/article_model.dart';

class NewsCard extends StatefulWidget {
  final String title;
  final String imageUrl;
  final String source;
  final String description;
  final String url;

  const NewsCard({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.source,
    required this.description,
    required this.url,
  });

  @override
  State<NewsCard> createState() => _NewsCardState();
}

class _NewsCardState extends State<NewsCard> {
  final GeminiService _geminiService = GeminiService();
  
  bool _isBookmarked = false;
  bool _isGenerating = false;
  String? _aiSummary;
  String? _errorMessage;

  // --- Logic: Generate AI Summary ---
  Future<void> _generateSummary() async {
    setState(() {
      _isGenerating = true;
      _errorMessage = null;
    });

    try {
      final summary = await _geminiService.generateSummary(
        articleTitle: widget.title,
        articleDescription: widget.description,
      );
      
      if (mounted) {
        setState(() {
          _aiSummary = summary;
          _isGenerating = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Failed to generate summary.";
          _isGenerating = false;
        });
      }
    }
  }
  // Inside _NewsCardState
  // 1. Add this at the top of your _NewsCardState class (right below _geminiService):
    final DatabaseService _dbService = DatabaseService();

    // 2. Replace your _toggleBookmark method with this fixed version:
    // Replace your _toggleBookmark method with this version:
    void _toggleBookmark() async {
      setState(() => _isBookmarked = true);

      try {
        final articleToSave = Article(
          sourceName: widget.source,
          title: widget.title,
          description: widget.description,
          url: widget.url,
          imageUrl: widget.imageUrl,
          publishedAt: '', 
          content: '',
        );

        // Pass the AI summary if it exists, otherwise pass a default placeholder
        final summaryToSave = _aiSummary ?? "No AI summary generated for this article.";

        await _dbService.saveArticle(articleToSave, summaryToSave);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Saved to Cloud Library!'))
          );
        }
      } catch (e) {
        setState(() => _isBookmarked = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save: $e'))
          );
        }
      }
    }



  // --- Logic: Open Original Article ---
  Future<void> _launchUrl() async {
    final Uri uri = Uri.parse(widget.url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the article.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      elevation: 4,
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,// Slightly lighter than scaffold background
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias, // Ensures the image respects the border radius
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- 1. Image & Bookmark Stack ---
          Stack(
            children: [
              // Image container with a fallback for missing/broken URLs
              Container(
                height: 200,
                width: double.infinity,
                color: const Color(0xFF2A2A2A),
                child: widget.imageUrl.isNotEmpty
                    ? Image.network(
                        widget.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(Icons.broken_image, color: Colors.grey, size: 50),
                          );
                        },
                      )
                    : const Center(
                        child: Icon(Icons.image_not_supported, color: Colors.grey, size: 50),
                      ),
              ),
              
              // Bookmark Button (Top Right)
              Positioned(
                top: 12,
                right: 12,
                child: CircleAvatar(
                  backgroundColor: Colors.black.withOpacity(0.6),
                  child: IconButton(
                    icon: Icon(
                      _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                      color: _isBookmarked ? Colors.blueAccent : Colors.white,
                    ),
                    onPressed: _toggleBookmark,
                  ),
                ),
              ),
            ],
          ),

          // --- 2. Article Content ---
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Source Name
                Text(
                  widget.source.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                
                // Headline
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),

                // --- 3. AI Summary Section or Generate Button ---
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: _buildAiSection(),
                ),
                
                const SizedBox(height: 16),
                const Divider(color: Colors.white10),

                // --- 4. External Link Action ---
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: _launchUrl,
                    icon: const Icon(Icons.open_in_new, size: 16, color: Colors.grey),
                    label: const Text(
                      'Read Full Article',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper: Builds the Dynamic AI UI ---
  Widget _buildAiSection() {
    // State 1: Summary is ready
    if (_aiSummary != null) {
      return Container(
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
                Text(
                  'AI Overview',
                  style: TextStyle(
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _aiSummary!,
              style: const TextStyle(
                fontStyle: FontStyle.italic,
                height: 1.4,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      );
    }

    // State 2: Error
    if (_errorMessage != null) {
      return Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 16),
          const SizedBox(width: 8),
          Expanded(child: Text(_errorMessage!, style: const TextStyle(color: Colors.redAccent))),
          TextButton(
            onPressed: _generateSummary,
            child: const Text('Retry'),
          ),
        ],
      );
    }

    // State 3: Generating/Loading or Ready to Generate Button
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _isGenerating ? null : _generateSummary,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.blueAccent),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        icon: _isGenerating
            ? const SizedBox(
                height: 16, width: 16, 
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.blueAccent),
              )
            : const Icon(Icons.auto_awesome, color: Colors.blueAccent),
        label: Text(
          _isGenerating ? "Analyzing article..." : "Generate 2-Sentence AI Overview",
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}