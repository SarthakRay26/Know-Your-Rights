import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/local_issue_datasource.dart';
import '../../data/repositories/local_issue_repository.dart';
import '../../domain/entities/issue.dart';
import '../../domain/repositories/issue_repository.dart';
import '../../domain/repositories/preferences_repository.dart';

// ---------------------------------------------------------------------------
// Data-layer singletons
// ---------------------------------------------------------------------------

final preferencesRepositoryProvider = Provider<PreferencesRepository>((ref) {
  // Initialized in main.dart before runApp
  throw UnimplementedError('Must be overridden in ProviderScope');
});

final issueRepositoryProvider = Provider<IssueRepository>((ref) {
  return LocalIssueRepository(LocalIssueDatasource());
});

// ---------------------------------------------------------------------------
// Language
// ---------------------------------------------------------------------------

/// Holds the current locale code ('en', 'hi').
/// Initialized from Hive, updated by the language selection screen.
final localeProvider = NotifierProvider<LocaleNotifier, String>(
  LocaleNotifier.new,
);

class LocaleNotifier extends Notifier<String> {
  @override
  String build() => 'en';

  Future<void> loadSavedLocale() async {
    final prefs = ref.read(preferencesRepositoryProvider);
    final saved = await prefs.getSelectedLanguage();
    if (saved != null) state = saved;
  }

  Future<void> setLocale(String code) async {
    state = code;
    final prefs = ref.read(preferencesRepositoryProvider);
    await prefs.setSelectedLanguage(code);
  }
}

// ---------------------------------------------------------------------------
// Onboarding (language chosen at least once)
// ---------------------------------------------------------------------------

final onboardingCompleteProvider = NotifierProvider<OnboardingNotifier, bool>(
  OnboardingNotifier.new,
);

class OnboardingNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  Future<void> load() async {
    final prefs = ref.read(preferencesRepositoryProvider);
    state = await prefs.hasCompletedOnboarding();
  }

  Future<void> complete() async {
    state = true;
    final prefs = ref.read(preferencesRepositoryProvider);
    await prefs.setOnboardingComplete(true);
  }
}

// ---------------------------------------------------------------------------
// Issues list
// ---------------------------------------------------------------------------

/// Fetches all issues once and caches them.
final issuesProvider = FutureProvider<List<Issue>>((ref) async {
  final repo = ref.read(issueRepositoryProvider);
  return repo.getAllIssues();
});

// ---------------------------------------------------------------------------
// Issue flow state (tracks which question the user is on)
// ---------------------------------------------------------------------------

class IssueFlowState {
  final Issue issue;
  final int currentQuestionIndex;
  final Map<String, String> selectedOptions; // questionId → optionId

  const IssueFlowState({
    required this.issue,
    this.currentQuestionIndex = 0,
    this.selectedOptions = const {},
  });

  bool get isComplete {
    if (currentQuestionIndex >= issue.questions.length) return true;
    return false;
  }

  FlowQuestion get currentQuestion => issue.questions[currentQuestionIndex];

  IssueFlowState copyWith({
    int? currentQuestionIndex,
    Map<String, String>? selectedOptions,
  }) {
    return IssueFlowState(
      issue: issue,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      selectedOptions: selectedOptions ?? this.selectedOptions,
    );
  }
}

final issueFlowProvider =
    NotifierProvider<IssueFlowNotifier, IssueFlowState?>(
  IssueFlowNotifier.new,
);

class IssueFlowNotifier extends Notifier<IssueFlowState?> {
  @override
  IssueFlowState? build() => null;

  /// Start a new issue flow.
  void startFlow(Issue issue) {
    state = IssueFlowState(issue: issue);
  }

  /// Select an option for the current question and advance.
  void selectOption(FlowOption option) {
    if (state == null) return;
    final current = state!;
    final newSelections = Map<String, String>.from(current.selectedOptions)
      ..[current.currentQuestion.questionId] = option.optionId;

    if (option.nextQuestionIndex != null) {
      state = current.copyWith(
        currentQuestionIndex: option.nextQuestionIndex!,
        selectedOptions: newSelections,
      );
    } else {
      // No next question — mark flow as complete by moving past last index
      state = current.copyWith(
        currentQuestionIndex: current.issue.questions.length,
        selectedOptions: newSelections,
      );
    }
  }

  /// Go back one question in the flow.
  void goBack() {
    if (state == null || state!.currentQuestionIndex <= 0) return;
    state = state!.copyWith(
      currentQuestionIndex: state!.currentQuestionIndex - 1,
    );
  }

  /// Reset the flow.
  void reset() {
    state = null;
  }
}

// ---------------------------------------------------------------------------
// Bookmarks (optional feature)
// ---------------------------------------------------------------------------

final bookmarksProvider = NotifierProvider<BookmarksNotifier, List<String>>(
  BookmarksNotifier.new,
);

class BookmarksNotifier extends Notifier<List<String>> {
  @override
  List<String> build() => [];

  Future<void> load() async {
    final prefs = ref.read(preferencesRepositoryProvider);
    state = await prefs.getBookmarkedIssueIds();
  }

  Future<void> toggle(String issueId) async {
    final prefs = ref.read(preferencesRepositoryProvider);
    await prefs.toggleBookmark(issueId);
    state = await prefs.getBookmarkedIssueIds();
  }
}
