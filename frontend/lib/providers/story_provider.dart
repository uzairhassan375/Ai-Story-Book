import 'package:flutter/foundation.dart';
import '../models/story.dart';
import '../services/api_service.dart';

class StoryProvider extends ChangeNotifier {
  Story? _currentStory;
  bool _isLoading = false;
  String? _error;

  Story? get currentStory => _currentStory;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> generateStory(StoryRequest request) async {
    _setLoading(true);
    _error = null;

    try {      print('🔄 Starting story generation...');
      print('📝 Request: ${request.toJson()}');

      final story = await ApiService.generateStory(request);
      print('✅ Story generated successfully');
      print('📖 Story title: ${story.title}');
      print('📄 Pages count: ${story.pages.length}');

      _currentStory = story;
      notifyListeners();
    } catch (e, stackTrace) {
      print('❌ STORY GENERATION ERROR:');
      print('🔴 Error: $e');
      print('🔴 Stack Trace: $stackTrace');
      print('🔴 Error type: ${e.runtimeType}');
      print('🔴 Error toString: ${e.toString()}');

      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
      print('🏁 Story generation process finished');
    }
  }

  void clearStory() {
    _currentStory = null;
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
