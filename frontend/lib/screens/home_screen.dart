import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/story_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/app_colors.dart';
import '../models/story.dart';
import '../services/api_service.dart';
import 'story_viewer_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
    // Set default theme to Adventure if not already set
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        _selectedTheme = context.read<ThemeProvider>().selectedTheme;
      } catch (e) {
        // If ThemeProvider not available, keep default
        _selectedTheme = 'Adventure';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Logo/Title
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.auto_stories,
                          size: 60,
                          color: AppColors.primary,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'AI Storybook',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Create magical stories with AI',
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Story Creation Form
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Theme Selection
                                                       Text(
                                 'Choose a Theme',
                                 style: const TextStyle(
                                   fontFamily: 'Nunito',
                                   fontSize: 18,
                                   fontWeight: FontWeight.bold,
                                   color: AppColors.textPrimary,
                                 ),
                               ),
                        const SizedBox(height: 12),
                        
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedTheme,
                              isExpanded: true,
                              hint: Row(
                                children: [
                                  Icon(
                                    Icons.palette,
                                    color: AppColors.primary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Select Theme',
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                              selectedItemBuilder: (BuildContext context) {
                                return _themes.map((theme) {
                                  final isSelected = _selectedTheme == theme['name'];
                                  return Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: theme['color'].withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Icon(
                                          theme['icon'],
                                          color: theme['color'],
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        theme['name'],
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: AppColors.textPrimary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList();
                              },
                              items: _themes.map((theme) {
                                return DropdownMenuItem<String>(
                                  value: theme['name'],
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: theme['color'].withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Icon(
                                          theme['icon'],
                                          color: theme['color'],
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        theme['name'],
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: AppColors.textPrimary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedTheme = newValue ?? 'Adventure';
                                });
                                try {
                                  context.read<ThemeProvider>().setTheme(_selectedTheme);
                                } catch (e) {
                                  // Provider not available, continue with local state
                                }
                              },
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Story Prompt
                        Text(
                          'Story Prompt',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextField(
                            controller: _promptController,
                            maxLines: 4,
                            decoration: InputDecoration(
                              hintText: 'Describe your story idea...',
                              hintStyle: const TextStyle(
                                color: AppColors.textLight,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.all(16),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Additional Context
                        Text(
                          'Additional Context (Optional)',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextField(
                            controller: _contextController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: 'Any additional details or preferences...',
                              hintStyle: const TextStyle(
                                color: AppColors.textLight,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.all(16),
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
                ],
              ),
            ),
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
