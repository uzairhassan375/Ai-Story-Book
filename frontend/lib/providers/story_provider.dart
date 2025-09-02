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

    try {
      final story = await ApiService.generateStory(request);
      _currentStory = story;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
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
