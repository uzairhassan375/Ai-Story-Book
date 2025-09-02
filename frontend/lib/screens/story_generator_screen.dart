import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/story_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/app_colors.dart';
import '../models/story.dart';
import 'story_viewer_screen.dart';

class StoryGeneratorScreen extends StatefulWidget {
  const StoryGeneratorScreen({super.key});

  @override
  State<StoryGeneratorScreen> createState() => _StoryGeneratorScreenState();
}

class _StoryGeneratorScreenState extends State<StoryGeneratorScreen> {
  final TextEditingController _promptController = TextEditingController();
  final TextEditingController _contextController = TextEditingController();
  String _selectedTheme = 'Adventure';

  final List<Map<String, dynamic>> _themes = [
    {
      'name': 'Adventure',
      'icon': Icons.explore,
      'color': AppColors.adventure,
      'description': 'Exciting quests and discoveries',
    },
    {
      'name': 'Fantasy',
      'icon': Icons.auto_awesome,
      'color': AppColors.fantasy,
      'description': 'Magical worlds and creatures',
    },
    {
      'name': 'Space',
      'icon': Icons.rocket_launch,
      'color': AppColors.space,
      'description': 'Futuristic space adventures',
    },
    {
      'name': 'Nature',
      'icon': Icons.eco,
      'color': AppColors.nature,
      'description': 'Beautiful natural world',
    },
    {
      'name': 'Friendship',
      'icon': Icons.favorite,
      'color': AppColors.friendship,
      'description': 'Heartwarming friendship stories',
    },
    {
      'name': 'Science',
      'icon': Icons.science,
      'color': AppColors.science,
      'description': 'Educational scientific concepts',
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedTheme = context.read<ThemeProvider>().selectedTheme;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Your Story'),
        backgroundColor: AppColors.primary,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Let\'s Create a Magical Story!',
                style: GoogleFonts.nunito(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose a theme and describe your story idea',
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Theme Selection
              Text(
                'Choose a Theme',
                style: GoogleFonts.nunito(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2,
                ),
                itemCount: _themes.length,
                itemBuilder: (context, index) {
                  final theme = _themes[index];
                  final isSelected = _selectedTheme == theme['name'];
                  
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTheme = theme['name'];
                      });
                      context.read<ThemeProvider>().setTheme(theme['name']);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? theme['color'] : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? theme['color'] : Colors.grey.shade300,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            theme['icon'],
                            size: 40,
                            color: isSelected ? Colors.white : theme['color'],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            theme['name'],
                            style: GoogleFonts.nunito(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            theme['description'],
                            style: GoogleFonts.nunito(
                              fontSize: 12,
                              color: isSelected ? Colors.white70 : AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 32),
              
              // Story Prompt
              Text(
                'Story Prompt',
                style: GoogleFonts.nunito(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _promptController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Describe your story idea... (e.g., "A brave little mouse who wants to become a knight")',
                    hintStyle: GoogleFonts.nunito(
                      color: AppColors.textLight,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(20),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Additional Context (Optional)
              Text(
                'Additional Context (Optional)',
                style: GoogleFonts.nunito(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _contextController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Any additional details or preferences...',
                    hintStyle: GoogleFonts.nunito(
                      color: AppColors.textLight,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(20),
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Generate Button
              Consumer<StoryProvider>(
                builder: (context, storyProvider, child) {
                  return SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: storyProvider.isLoading
                          ? null
                          : () => _generateStory(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: storyProvider.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              'Generate Story',
                              style: GoogleFonts.nunito(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 16),
              
              // Error Display
              Consumer<StoryProvider>(
                builder: (context, storyProvider, child) {
                  if (storyProvider.error != null) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.error),
                      ),
                      child: Text(
                        storyProvider.error!,
                        style: GoogleFonts.nunito(
                          color: AppColors.error,
                          fontSize: 14,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _generateStory(BuildContext context) {
    if (_promptController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter a story prompt',
            style: GoogleFonts.nunito(),
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final request = StoryRequest(
      prompt: _promptController.text.trim(),
      theme: _selectedTheme,
      additionalContext: _contextController.text.trim().isNotEmpty
          ? _contextController.text.trim()
          : null,
    );

    context.read<StoryProvider>().generateStory(request).then((_) {
      final storyProvider = context.read<StoryProvider>();
      if (storyProvider.currentStory != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StoryViewerScreen(story: storyProvider.currentStory!),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _promptController.dispose();
    _contextController.dispose();
    super.dispose();
  }
}
