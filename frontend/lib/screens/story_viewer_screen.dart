import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../utils/app_colors.dart';
import '../widgets/smart_image_widget.dart';
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

    // Split content into sentences for better page distribution
    final sentences = content.split(RegExp(r'[.!?]+\s*')).where((s) => s.trim().isNotEmpty).toList();
    
    _pages = [];
    
    // Title page
    _pages.add(StoryPage(
      type: PageType.title,
      title: title,
      theme: theme,
      imageUrl: imageUrls.isNotEmpty ? imageUrls[0] : null,
    ));

    // Content pages (aim for 8-10 content pages)
    final targetPages = 8;
    final sentencesPerPage = (sentences.length / targetPages).ceil().clamp(1, 4);
    
    // Generate placeholder images for pages that don't have them
    List<String> allImageUrls = List.from(imageUrls);
    while (allImageUrls.length < targetPages + 2) { // +2 for title and end pages
      allImageUrls.add('https://picsum.photos/400/300?random=${allImageUrls.length}');
    }
    
    for (int i = 0; i < sentences.length; i += sentencesPerPage) {
      final endIndex = (i + sentencesPerPage < sentences.length) ? i + sentencesPerPage : sentences.length;
      final pageContent = sentences.sublist(i, endIndex).join('. ').trim();
      if (pageContent.isNotEmpty && !pageContent.endsWith('.')) {
        // pageContent += '.'; // Ensure sentences end with period
      }
      
      final pageIndex = _pages.length - 1; // -1 because title page is index 0
      final imageUrl = pageIndex < allImageUrls.length ? allImageUrls[pageIndex] : allImageUrls.last;
      
      _pages.add(StoryPage(
        type: PageType.content,
        content: pageContent.isEmpty ? 'Content continues...' : pageContent,
        imageUrl: imageUrl,
        pageNumber: pageIndex + 1,
      ));
    }

    // End page
    _pages.add(StoryPage(
      type: PageType.end,
      title: "The End",
      theme: theme,
      imageUrl: allImageUrls.length > 1 ? allImageUrls[1] : null,
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
            icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          ),
          Expanded(
            child: Text(
              'Page ${_currentPage + 1} of ${_pages.length}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
          // Audio button removed - now shown at bottom of story pages
          const SizedBox(width: 48), // Spacer to keep title centered
        ],
      ),
    );
  }

  Widget _buildPage(StoryPage page) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: _buildContentSection(page),
          ),
        ),
      ),
    );
  }

  Widget _buildContentSection(StoryPage page) {
    switch (page.type) {
      case PageType.title:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (page.imageUrl != null) ...[
              Container(
                height: MediaQuery.of(context).size.height * 0.3,
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SmartImageWidget(
                    imageUrl: page.imageUrl!,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
            Text(
              page.title ?? 'Untitled',
              textAlign: TextAlign.center,
              style: GoogleFonts.playfairDisplay(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'A ${page.theme ?? 'Magical'} Story',
              style: GoogleFonts.nunito(
                fontSize: 18,
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                Icons.auto_stories,
                size: 40,
                color: AppColors.primary,
              ),
            ),
          ],
        );
        
      case PageType.content:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image at top for mobile-friendly layout
            if (page.imageUrl != null) ...[
              Container(
                height: MediaQuery.of(context).size.height * 0.25,
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SmartImageWidget(
                    imageUrl: page.imageUrl!,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
            
            // Story content with drop cap
            _buildStoryText(page.content ?? 'No content available'),
            
            // Audio Control Button at bottom
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 20),
              child: ElevatedButton.icon(
                onPressed: _playCurrentPage,
                icon: Icon(
                  _isPlaying ? Icons.pause : Icons.play_arrow,
                  size: 24,
                ),
                label: Text(
                  _isPlaying ? 'Pause Audio' : 'Listen to Story',
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isPlaying ? Colors.red : AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
              ),
            ),
          ],
        );
        
      case PageType.end:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // End page image
            if (page.imageUrl != null) ...[
              Container(
                height: 200,
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SmartImageWidget(
                    imageUrl: page.imageUrl!,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
            Text(
              page.title ?? 'The End',
              style: GoogleFonts.playfairDisplay(
                fontSize: 32,
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
                fontSize: 18,
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
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

  Widget _buildStoryText(String content) {
    if (content.isEmpty) return const Text('No content available');
    
    // Get the first character for drop cap
    final firstChar = content.isNotEmpty ? content[0].toUpperCase() : '';
    final restOfText = content.length > 1 ? content.substring(1) : '';
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Text with drop cap
          RichText(
            textAlign: TextAlign.justify,
            text: TextSpan(
              children: [
                // Drop cap - first letter
                TextSpan(
                  text: firstChar,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 56,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    height: 0.8,
                  ),
                ),
                // Rest of the text
                TextSpan(
                  text: restOfText,
                  style: GoogleFonts.nunito(
                    fontSize: 18,
                    height: 1.8,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w400,
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
