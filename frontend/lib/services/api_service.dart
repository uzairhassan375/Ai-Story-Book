import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:api_key_pool/api_key_pool.dart';
import '../models/story.dart';

class ApiService {
  // For development - local Flask server
  static const String baseUrl = 'http://localhost:8080/api';
  
  // For production - Vercel deployment
  // static const String baseUrl = 'https://your-vercel-app.vercel.app/api';
  
  // Helper method to convert relative image URLs to absolute URLs
  static String getImageUrl(String relativeUrl) {
    if (relativeUrl.startsWith('http')) {
      return relativeUrl;
    }
    return 'http://localhost:8080$relativeUrl';
  }
  
  // Story generation
  static Future<Story> generateStory(StoryRequest request) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/stories/generate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return Story.fromJson(data['data']);
        } else {
          throw Exception(data['error'] ?? 'Failed to generate story');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Submit feedback
  static Future<Map<String, dynamic>> submitFeedback({
    required String feedbackType,
    required String selectedFeedback,
    String? customFeedback,
    String? storyId,
    int rating = 5,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/feedback'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'feedbackType': feedbackType,
          'selectedFeedback': selectedFeedback,
          'customFeedback': customFeedback,
          'storyId': storyId,
          'rating': rating,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to submit feedback: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Get feedback options
  static Future<Map<String, dynamic>> getFeedbackOptions() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/feedback/options'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get feedback options: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Get feedback for a story
  static Future<List<Feedback>> getFeedbackForStory(String storyId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/feedback/$storyId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> feedbackList = data['data'];
          return feedbackList.map((json) => Feedback.fromJson(json)).toList();
        } else {
          throw Exception(data['error'] ?? 'Failed to get feedback');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Get feedback stats for a story
  static Future<Map<String, dynamic>> getFeedbackStats(String storyId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/feedback/$storyId/stats'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return Map<String, dynamic>.from(data['data']);
        } else {
          throw Exception(data['error'] ?? 'Failed to get feedback stats');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Generate image
  static Future<Map<String, dynamic>> generateImage({
    required String prompt,
    List<Uint8List>? images,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/images/generate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'prompt': prompt,
          'images': images?.map((img) => base64Encode(img)).toList(),
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to generate image: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Generate text
  static Future<Map<String, dynamic>> generateText({
    required String prompt,
    String? systemInstruction,
    Map<String, dynamic>? generationConfig,
    List<Uint8List>? images,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/text/generate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'prompt': prompt,
          'systemInstruction': systemInstruction,
          'generationConfig': generationConfig,
          'images': images?.map((img) => base64Encode(img)).toList(),
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to generate text: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Health check
  static Future<bool> checkHealth() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
        headers: {'Content-Type': 'application/json'},
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
