import '../services/api_service.dart';

class Story {
  final String id;
  final String title;
  final String content;
  final String theme;
  final List<String> imageUrls;
  final String audioUrl;
  final DateTime createdAt;

  Story({
    required this.id,
    required this.title,
    required this.content,
    required this.theme,
    required this.imageUrls,
    required this.audioUrl,
    required this.createdAt,
  });

  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      theme: json['theme'] as String,
      imageUrls: List<String>.from(json['imageUrls']).map((url) => ApiService.getImageUrl(url)).toList(),
      audioUrl: json['audioUrl'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'theme': theme,
      'imageUrls': imageUrls,
      'audioUrl': audioUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class StoryRequest {
  final String prompt;
  final String theme;
  final String? additionalContext;

  StoryRequest({
    required this.prompt,
    required this.theme,
    this.additionalContext,
  });

  Map<String, dynamic> toJson() {
    return {
      'prompt': prompt,
      'theme': theme,
      'additionalContext': additionalContext,
    };
  }
}

class Feedback {
  final String id;
  final String storyId;
  final String feedbackType;
  final String feedbackText;
  final int rating;
  final DateTime timestamp;

  Feedback({
    required this.id,
    required this.storyId,
    required this.feedbackType,
    required this.feedbackText,
    required this.rating,
    required this.timestamp,
  });

  factory Feedback.fromJson(Map<String, dynamic> json) {
    return Feedback(
      id: json['id'] as String,
      storyId: json['storyId'] as String,
      feedbackType: json['feedbackType'] as String,
      feedbackText: json['feedbackText'] as String,
      rating: json['rating'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'storyId': storyId,
      'feedbackType': feedbackType,
      'feedbackText': feedbackText,
      'rating': rating,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

class ThemeOption {
  final String name;
  final String description;
  final String icon;
  final String color;

  const ThemeOption({
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
  });
}
