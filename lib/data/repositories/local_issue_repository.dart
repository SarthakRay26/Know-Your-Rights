import '../../domain/entities/issue.dart';
import '../../domain/repositories/issue_repository.dart';
import '../datasources/local_issue_datasource.dart';

/// Concrete implementation of [IssueRepository].
/// Delegates to [LocalIssueDatasource] and caches results in memory.
class LocalIssueRepository implements IssueRepository {
  final LocalIssueDatasource _datasource;

  /// In-memory cache keyed by locale code.
  final Map<String, List<Issue>> _cache = {};

  LocalIssueRepository(this._datasource);

  @override
  Future<List<Issue>> getAllIssues() async {
    // In MVP we always load from English JSON (content has all locale strings)
    if (_cache.containsKey('en')) return _cache['en']!;
    final issues = await _datasource.loadIssues('en');
    _cache['en'] = issues;
    return issues;
  }

  @override
  Future<Issue?> getIssueById(String issueId) async {
    final issues = await getAllIssues();
    try {
      return issues.firstWhere((i) => i.issueId == issueId);
    } catch (_) {
      return null;
    }
  }
}
