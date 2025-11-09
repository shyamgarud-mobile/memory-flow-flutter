import 'package:flutter/foundation.dart';

/// Provider for managing bottom navigation state
class NavigationProvider extends ChangeNotifier {
  int _currentIndex = 0;

  /// Get current selected tab index
  int get currentIndex => _currentIndex;

  /// Set current tab index
  void setIndex(int index) {
    if (_currentIndex != index) {
      _currentIndex = index;
      notifyListeners();
    }
  }

  /// Navigate to Home tab
  void goToHome() => setIndex(0);

  /// Navigate to Calendar tab
  void goToCalendar() => setIndex(1);

  /// Navigate to Add Topic tab
  void goToAddTopic() => setIndex(2);

  /// Navigate to Topics List tab
  void goToTopicsList() => setIndex(3);

  /// Navigate to Settings tab
  void goToSettings() => setIndex(4);
}
