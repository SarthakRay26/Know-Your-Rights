/// Represents a legal issue category (e.g., "Salary not paid").
/// This is the core domain entity — it carries no serialization logic.
class Issue {
  final String issueId;
  final String icon; // Material icon name for display
  final Map<String, String> localizedTitles; // locale code → title
  final List<FlowQuestion> questions;
  final RightsContent content;
  final List<ActionStep> actionSteps;
  final SelfCheck? selfCheck; // optional self-check before flow

  const Issue({
    required this.issueId,
    required this.icon,
    required this.localizedTitles,
    required this.questions,
    required this.content,
    required this.actionSteps,
    this.selfCheck,
  });

  /// Returns the title for the given locale, falling back to English.
  String titleForLocale(String localeCode) {
    return localizedTitles[localeCode] ?? localizedTitles['en'] ?? issueId;
  }
}

/// A single question in the decision-flow tree.
/// Each option can optionally lead to the next question index or jump
/// directly to the rights content.
class FlowQuestion {
  final String questionId;
  final Map<String, String> localizedText; // locale → question text
  final List<FlowOption> options;

  const FlowQuestion({
    required this.questionId,
    required this.localizedText,
    required this.options,
  });

  String textForLocale(String localeCode) {
    return localizedText[localeCode] ?? localizedText['en'] ?? '';
  }
}

/// An option the user can select inside a FlowQuestion.
/// [nextQuestionIndex] drives the decision tree — null means "go to results".
class FlowOption {
  final String optionId;
  final Map<String, String> localizedLabel;
  final int? nextQuestionIndex; // null = show results

  const FlowOption({
    required this.optionId,
    required this.localizedLabel,
    this.nextQuestionIndex,
  });

  String labelForLocale(String localeCode) {
    return localizedLabel[localeCode] ?? localizedLabel['en'] ?? '';
  }
}

/// Plain-language rights explanation shown after the decision flow.
class RightsContent {
  final Map<String, String> localizedExplanation;
  final List<Myth> myths;
  final List<String> applicableLaws; // law names only, no section numbers
  final Map<String, String> localizedTimeline;
  final List<Map<String, String>> allowedActions; // list of localized strings
  final List<Map<String, String>> obligations; // list of localized strings
  final Map<String, String> otherSidePerspective; // localized paragraph
  final Map<String, String> misuseWarning; // localized warning
  final EscalationBoundaries? escalationBoundaries;

  const RightsContent({
    required this.localizedExplanation,
    required this.myths,
    required this.applicableLaws,
    required this.localizedTimeline,
    this.allowedActions = const [],
    this.obligations = const [],
    this.otherSidePerspective = const {},
    this.misuseWarning = const {},
    this.escalationBoundaries,
  });

  String explanationForLocale(String localeCode) {
    return localizedExplanation[localeCode] ??
        localizedExplanation['en'] ??
        '';
  }

  String timelineForLocale(String localeCode) {
    return localizedTimeline[localeCode] ?? localizedTimeline['en'] ?? '';
  }

  List<String> allowedActionsForLocale(String localeCode) {
    return allowedActions
        .map((m) => m[localeCode] ?? m['en'] ?? '')
        .where((s) => s.isNotEmpty)
        .toList();
  }

  List<String> obligationsForLocale(String localeCode) {
    return obligations
        .map((m) => m[localeCode] ?? m['en'] ?? '')
        .where((s) => s.isNotEmpty)
        .toList();
  }

  String otherSidePerspectiveForLocale(String localeCode) {
    return otherSidePerspective[localeCode] ??
        otherSidePerspective['en'] ??
        '';
  }

  String misuseWarningForLocale(String localeCode) {
    return misuseWarning[localeCode] ?? misuseWarning['en'] ?? '';
  }
}

/// A common myth with its correction.
class Myth {
  final Map<String, String> localizedMyth;
  final Map<String, String> localizedFact;

  const Myth({
    required this.localizedMyth,
    required this.localizedFact,
  });

  String mythForLocale(String localeCode) {
    return localizedMyth[localeCode] ?? localizedMyth['en'] ?? '';
  }

  String factForLocale(String localeCode) {
    return localizedFact[localeCode] ?? localizedFact['en'] ?? '';
  }
}

/// A single numbered action step the user should take.
class ActionStep {
  final int stepNumber;
  final Map<String, String> localizedTitle;
  final Map<String, String> localizedDescription;

  const ActionStep({
    required this.stepNumber,
    required this.localizedTitle,
    required this.localizedDescription,
  });

  String titleForLocale(String localeCode) {
    return localizedTitle[localeCode] ?? localizedTitle['en'] ?? '';
  }

  String descriptionForLocale(String localeCode) {
    return localizedDescription[localeCode] ??
        localizedDescription['en'] ??
        '';
  }
}

/// A self-check question shown before the decision flow to encourage
/// the user to reflect on their own situation.
class SelfCheck {
  final Map<String, String> localizedQuestion;
  final List<SelfCheckOption> options;
  final Map<String, String> localizedBalancedNote;

  const SelfCheck({
    required this.localizedQuestion,
    required this.options,
    required this.localizedBalancedNote,
  });

  String questionForLocale(String localeCode) {
    return localizedQuestion[localeCode] ?? localizedQuestion['en'] ?? '';
  }

  String balancedNoteForLocale(String localeCode) {
    return localizedBalancedNote[localeCode] ??
        localizedBalancedNote['en'] ??
        '';
  }
}

/// An option within a self-check question.
class SelfCheckOption {
  final String optionId;
  final Map<String, String> localizedLabel;

  const SelfCheckOption({
    required this.optionId,
    required this.localizedLabel,
  });

  String labelForLocale(String localeCode) {
    return localizedLabel[localeCode] ?? localizedLabel['en'] ?? '';
  }
}

/// Guidelines on when escalation is appropriate vs. risky.
class EscalationBoundaries {
  final Map<String, String> localizedReasonable;
  final Map<String, String> localizedCaution;

  const EscalationBoundaries({
    required this.localizedReasonable,
    required this.localizedCaution,
  });

  String reasonableForLocale(String localeCode) {
    return localizedReasonable[localeCode] ??
        localizedReasonable['en'] ??
        '';
  }

  String cautionForLocale(String localeCode) {
    return localizedCaution[localeCode] ?? localizedCaution['en'] ?? '';
  }
}
