/// Represents a legal issue category (e.g., "Salary not paid").
/// This is the core domain entity — it carries no serialization logic.
class Issue {
  final String issueId;
  final String icon; // Material icon name for display
  final Map<String, String> localizedTitles; // locale code → title
  final List<FlowQuestion> questions;
  final RightsContent content;
  final List<ActionStep> actionSteps;

  const Issue({
    required this.issueId,
    required this.icon,
    required this.localizedTitles,
    required this.questions,
    required this.content,
    required this.actionSteps,
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

  const RightsContent({
    required this.localizedExplanation,
    required this.myths,
    required this.applicableLaws,
    required this.localizedTimeline,
  });

  String explanationForLocale(String localeCode) {
    return localizedExplanation[localeCode] ??
        localizedExplanation['en'] ??
        '';
  }

  String timelineForLocale(String localeCode) {
    return localizedTimeline[localeCode] ?? localizedTimeline['en'] ?? '';
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
