/// Abstract contract for persisting user preferences (language, bookmarks).
abstract class PreferencesRepository {
  Future<String?> getSelectedLanguage();
  Future<void> setSelectedLanguage(String localeCode);
  Future<bool> hasCompletedOnboarding();
  Future<void> setOnboardingComplete(bool complete);
  Future<List<String>> getBookmarkedIssueIds();
  Future<void> toggleBookmark(String issueId);
}
