import '../../domain/entities/issue.dart';

/// Data-layer model that knows how to deserialize from JSON.
/// Maps directly to the domain [Issue] entity.
class IssueModel {
  /// Parses a single issue from a decoded JSON map.
  static Issue fromJson(Map<String, dynamic> json) {
    return Issue(
      issueId: json['issue_id'] as String,
      icon: json['icon'] as String? ?? 'help_outline',
      localizedTitles: _parseLocalizedMap(json['titles']),
      questions: _parseQuestions(json['questions'] as List<dynamic>? ?? []),
      content: _parseContent(json['content'] as Map<String, dynamic>? ?? {}),
      actionSteps: _parseActionSteps(json['action_steps'] as List<dynamic>? ?? []),
    );
  }

  static Map<String, String> _parseLocalizedMap(dynamic raw) {
    if (raw is Map) {
      return raw.map((k, v) => MapEntry(k.toString(), v.toString()));
    }
    return {};
  }

  static List<FlowQuestion> _parseQuestions(List<dynamic> list) {
    return list.map((q) {
      final map = q as Map<String, dynamic>;
      return FlowQuestion(
        questionId: map['question_id'] as String,
        localizedText: _parseLocalizedMap(map['text']),
        options: (map['options'] as List<dynamic>? ?? []).map((o) {
          final oMap = o as Map<String, dynamic>;
          return FlowOption(
            optionId: oMap['option_id'] as String,
            localizedLabel: _parseLocalizedMap(oMap['label']),
            nextQuestionIndex: oMap['next_question_index'] as int?,
          );
        }).toList(),
      );
    }).toList();
  }

  static RightsContent _parseContent(Map<String, dynamic> map) {
    return RightsContent(
      localizedExplanation: _parseLocalizedMap(map['explanation']),
      myths: (map['myths'] as List<dynamic>? ?? []).map((m) {
        final mMap = m as Map<String, dynamic>;
        return Myth(
          localizedMyth: _parseLocalizedMap(mMap['myth']),
          localizedFact: _parseLocalizedMap(mMap['fact']),
        );
      }).toList(),
      applicableLaws: (map['applicable_laws'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      localizedTimeline: _parseLocalizedMap(map['timeline']),
    );
  }

  static List<ActionStep> _parseActionSteps(List<dynamic> list) {
    return list.asMap().entries.map((entry) {
      final map = entry.value as Map<String, dynamic>;
      return ActionStep(
        stepNumber: entry.key + 1,
        localizedTitle: _parseLocalizedMap(map['title']),
        localizedDescription: _parseLocalizedMap(map['description']),
      );
    }).toList();
  }
}
