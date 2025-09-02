import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../utils/app_colors.dart';
import '../start_feedback_widget.dart';
import '../models/story.dart';

class StoryViewerScreen extends StatefulWidget {
  final Story story;

  const StoryViewerScreen({super.key, required this.story});

  @override
  State<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends State<StoryViewerScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late FlutterTts _flutterTts;
  int _currentPage = 0;
  bool _isPlaying = false;
  List<StoryPage> _pages = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _flutterTts = FlutterTts();
    _initializeTts();
    _createPages();
  }

  void _initializeTts() {
    _flutterTts.setLanguage("en-US");
    _flutterTts.setSpeechRate(0.5);
    _flutterTts.setVolume(1.0);
    _flutterTts.setPitch(1.0);
  }

  void _createPages() {
    final content = widget.story.content;
    final imageUrls = widget.story.imageUrls;
    final title = widget.story.title;
    final theme = widget.story.theme;

    // Split content into paragraphs
    final paragraphs = content.split('\n\n').where((p) => p.trim().isNotEmpty).toList();
    
    _pages = [];
    
    // Title page
    _pages.add(StoryPage(
      type: PageType.title,
      title: title,
      theme: theme,
      imageUrl: imageUrls.isNotEmpty ? imageUrls[0] : null,
    ));

    // Content pages (max 8 pages for content)
    final maxContentPages = 8;
    final contentPerPage = (paragraphs.length / maxContentPages).ceil();
    
    for (int i = 0; i < paragraphs.length; i += contentPerPage) {
      final endIndex = (i + contentPerPage < paragraphs.length) ? i + contentPerPage : paragraphs.length;
      final pageContent = paragraphs.sublist(i, endIndex).join('\n\n');
      final pageIndex = _pages.length;
      final imageUrl = pageIndex < imageUrls.length ? imageUrls[pageIndex] : null;
      
      _pages.add(StoryPage(
        type: PageType.content,
        content: pageContent,
        imageUrl: imageUrl,
        pageNumber: pageIndex,
      ));
    }

    // End page
    _pages.add(StoryPage(
      type: PageType.end,
      title: "The End",
      theme: theme,
    ));
  }

  @override
  void dispose() {
    _pageController.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  void _playCurrentPage() async {
    final currentPage = _pages[_currentPage];
    if (currentPage.type == PageType.content && currentPage.content != null) {
      if (_isPlaying) {
        await _flutterTts.stop();
        setState(() => _isPlaying = false);
      } else {
        await _flutterTts.speak(currentPage.content!);
        setState(() => _isPlaying = true);
      }
    }
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      setState(() {
        _currentPage++;
        _isPlaying = false;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
        _isPlaying = false;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(),
              
              // Story Pages
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                      _isPlaying = false;
                    });
                  },
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    return _buildPage(_pages[index]);
                  },
                ),
              ),
              
              // Navigation Controls
              _buildNavigationControls(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          Expanded(
            child: Text(
              'Page ${_currentPage + 1} of ${_pages.length}',
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          IconButton(
            onPressed: _playCurrentPage,
            icon: Icon(
              _isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(StoryPage page) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _buildContentSection(page),
        ),
      ),
    );
  }

  Widget _buildContentSection(StoryPage page) {
    switch (page.type) {
      case PageType.title:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (page.imageUrl != null) ...[
              Container(
                height: 250,
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CachedNetworkImage(
                    imageUrl: page.imageUrl!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[200],
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_not_supported,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Image not available',
                            style: GoogleFonts.nunito(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
            Text(
              page.title ?? 'Untitled',
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'A ${page.theme ?? 'Magical'} Story',
              style: GoogleFonts.nunito(
                fontSize: 16,
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 24),
            Icon(
              Icons.auto_stories,
              size: 48,
              color: AppColors.primary,
            ),
          ],
        );
        
      case PageType.content:
        return SingleChildScrollView(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Text Content (Left side)
              Expanded(
                flex: 3,
                child: Text(
                  page.content ?? 'No content available',
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    height: 1.6,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.justify,
                ),
              ),
              
              // Image (Right side) - if available
              if (page.imageUrl != null) ...[
                const SizedBox(width: 20),
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(
                        imageUrl: page.imageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[200],
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image_not_supported,
                                size: 32,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Image not available',
                                style: GoogleFonts.nunito(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
        
      case PageType.end:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              page.title ?? 'The End',
              style: GoogleFonts.nunito(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            Icon(
              Icons.favorite,
              size: 48,
              color: AppColors.primary,
            ),
            const SizedBox(height: 20),
            Text(
              'Thank you for reading!',
              style: GoogleFonts.nunito(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            StarFeedbackWidget(
              size: 28,
              mainContext: context,
              icon: Icons.feedback,
              isShowText: true,
            ),
          ],
        );
    }
  }

  Widget _buildNavigationControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Previous Button
          ElevatedButton.icon(
            onPressed: _currentPage > 0 ? _previousPage : null,
            icon: const Icon(Icons.arrow_back),
            label: Text(
              'Previous',
              style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          
          // Page Indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '${_currentPage + 1} / ${_pages.length}',
              style: GoogleFonts.nunito(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          
          // Next Button
          ElevatedButton.icon(
            onPressed: _currentPage < _pages.length - 1 ? _nextPage : null,
            icon: const Icon(Icons.arrow_forward),
            label: Text(
              'Next',
              style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum PageType { title, content, end }

class StoryPage {
  final PageType type;
  final String? title;
  final String? content;
  final String? imageUrl;
  final String? theme;
  final int? pageNumber;

  StoryPage({
    required this.type,
    this.title,
    this.content,
    this.imageUrl,
    this.theme,
    this.pageNumber,
  });
}
