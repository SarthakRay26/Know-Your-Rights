import 'package:hive/hive.dart';
import '../../domain/repositories/preferences_repository.dart';

/// Hive-backed implementation of [PreferencesRepository].
/// Stores language choice, onboarding state, and bookmarks locally.
class HivePreferencesRepository implements PreferencesRepository {
  static const _boxName = 'preferences';
  static const _keyLanguage = 'selected_language';
  static const _keyOnboarding = 'onboarding_complete';
  static const _keyBookmarks = 'bookmarked_issues';

  late Box _box;

  /// Must be called once at app startup after Hive.init().
  Future<void> init() async {
    _box = await Hive.openBox(_boxName);
  }

  @override
  Future<String?> getSelectedLanguage() async {
    return _box.get(_keyLanguage) as String?;
  }

  @override
  Future<void> setSelectedLanguage(String localeCode) async {
    await _box.put(_keyLanguage, localeCode);
  }

  @override
  Future<bool> hasCompletedOnboarding() async {
    return _box.get(_keyOnboarding, defaultValue: false) as bool;
  }

  @override
  Future<void> setOnboardingComplete(bool complete) async {
    await _box.put(_keyOnboarding, complete);
  }

  @override
  Future<List<String>> getBookmarkedIssueIds() async {
    final raw = _box.get(_keyBookmarks, defaultValue: <String>[]);
    return List<String>.from(raw as List);
  }

  @override
  Future<void> toggleBookmark(String issueId) async {
    final bookmarks = await getBookmarkedIssueIds();
    if (bookmarks.contains(issueId)) {
      bookmarks.remove(issueId);
    } else {
      bookmarks.add(issueId);
    }
    await _box.put(_keyBookmarks, bookmarks);
  }
}
