/// Represents a single message in the chat intake flow.
/// Used for both user-submitted and system-generated messages.
class ChatMessage {
  final String id;
  final String text;
  final MessageSender sender;
  final DateTime timestamp;

  /// Optional quick-reply buttons attached to system messages.
  final List<QuickReply>? quickReplies;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.sender,
    required this.timestamp,
    this.quickReplies,
  });
}

/// Distinguishes user input from system guidance messages.
enum MessageSender { user, system }

/// A tappable button shown below a system message.
/// [value] is the internal action key; [label] is what the user sees.
class QuickReply {
  final String value;
  final String label;

  const QuickReply({required this.value, required this.label});
}

/// Result returned by the classification backend.
class ClassificationResult {
  final String issueId;
  final double confidence;
  final bool fallback;

  const ClassificationResult({
    required this.issueId,
    required this.confidence,
    required this.fallback,
  });

  factory ClassificationResult.fromJson(Map<String, dynamic> json) {
    return ClassificationResult(
      issueId: json['issue_id'] as String? ?? '',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      fallback: json['fallback'] as bool? ?? true,
    );
  }
}
