import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../../domain/entities/issue.dart';
import '../models/issue_model.dart';

/// Reads issue JSON files from the app's asset bundle.
/// This is the single source of truth for legal content in the MVP.
class LocalIssueDatasource {
  /// Loads all issues from the JSON file for the given locale.
  /// Falls back to English if the locale file doesn't exist.
  Future<List<Issue>> loadIssues(String localeCode) async {
    try {
      final jsonString = await rootBundle.loadString(
        'assets/content/$localeCode/issues.json',
      );
      final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
      return jsonList
          .map((e) => IssueModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      // Locale-specific file missing — fall back to English.
      if (localeCode != 'en') {
        return loadIssues('en');
      }
      return [];
    }
  }
}
