import '../entities/issue.dart';

/// Abstract contract for fetching issue data.
/// The data layer provides the concrete implementation.

abstract class IssueRepository {
  /// Loads all available issues for the app.
  Future<List<Issue>> getAllIssues();

  /// Loads a single issue by its id.
  Future<Issue?> getIssueById(String issueId);
}
