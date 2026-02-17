import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/classification_service.dart';
import '../../domain/entities/chat_message.dart';
import '../../l10n/app_strings.dart';
import 'app_providers.dart';

// ---------------------------------------------------------------------------
// Service provider
// ---------------------------------------------------------------------------

final classificationServiceProvider = Provider<ClassificationService>((ref) {
  return ClassificationService();
});

// ---------------------------------------------------------------------------
// Chat state
// ---------------------------------------------------------------------------

/// Confidence threshold below which we treat the result as uncertain.
const double _confidenceThreshold = 0.65;

/// Immutable snapshot of the chat intake state.
class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final ClassificationResult? lastResult;

  const ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.lastResult,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    ClassificationResult? lastResult,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      lastResult: lastResult ?? this.lastResult,
    );
  }
}

/// Manages the chat intake flow: message list, loading state, classification.
final chatProvider = NotifierProvider<ChatNotifier, ChatState>(
  ChatNotifier.new,
);

class ChatNotifier extends Notifier<ChatState> {
  int _messageCounter = 0;

  @override
  ChatState build() {
    // Start with the system greeting
    final locale = ref.read(localeProvider);
    return ChatState(
      messages: [
        _systemMessage(AppStrings.get(locale, 'chat_greeting')),
      ],
    );
  }

  /// User sends a problem description.
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty || state.isLoading) return;

    final locale = ref.read(localeProvider);

    // 1. Add user message immediately (optimistic UI)
    final userMsg = ChatMessage(
      id: _nextId(),
      text: text.trim(),
      sender: MessageSender.user,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isLoading: true,
    );

    // 2. Call classification backend
    try {
      final service = ref.read(classificationServiceProvider);
      final result = await service.classify(text.trim());

      if (result.fallback || result.confidence < _confidenceThreshold) {
        // Low confidence — ask user to rephrase or choose manually
        _addSystemMessage(
          AppStrings.get(locale, 'chat_unclear'),
          quickReplies: [
            QuickReply(
              value: 'choose_manual',
              label: AppStrings.get(locale, 'chat_choose_from_list'),
            ),
            QuickReply(
              value: 'rephrase',
              label: AppStrings.get(locale, 'chat_try_rephrase'),
            ),
          ],
        );
      } else {
        // Good confidence — ask user to confirm the detected issue
        final issues = await ref.read(issueRepositoryProvider).getAllIssues();
        final matchedIssue = issues.where((i) => i.issueId == result.issueId).firstOrNull;
        final issueName = matchedIssue?.titleForLocale(locale) ?? result.issueId;

        _addSystemMessage(
          AppStrings.getFormatted(locale, 'chat_detected', {'issue': issueName}),
          quickReplies: [
            QuickReply(
              value: 'confirm_${result.issueId}',
              label: AppStrings.get(locale, 'chat_yes_correct'),
            ),
            QuickReply(
              value: 'choose_manual',
              label: AppStrings.get(locale, 'chat_no_different'),
            ),
          ],
        );
      }

      state = state.copyWith(isLoading: false, lastResult: result);
    } catch (_) {
      // Network error or server failure — always let user proceed manually
      _addSystemMessage(
        AppStrings.get(locale, 'chat_error'),
        quickReplies: [
          QuickReply(
            value: 'choose_manual',
            label: AppStrings.get(locale, 'chat_choose_from_list'),
          ),
        ],
      );
      state = state.copyWith(isLoading: false);
    }
  }

  /// Handle a quick reply button tap.
  /// Returns a route name and optional arguments for navigation,
  /// or null if no navigation is needed (e.g., rephrase).
  ({String route, Object? arguments})? handleQuickReply(String value) {
    if (value == 'choose_manual') {
      return (route: '/home', arguments: null);
    }

    if (value == 'rephrase') {
      final locale = ref.read(localeProvider);
      _addSystemMessage(AppStrings.get(locale, 'chat_rephrase_prompt'));
      return null;
    }

    if (value.startsWith('confirm_')) {
      final issueId = value.replaceFirst('confirm_', '');
      return (route: '/issue-flow-by-id', arguments: issueId);
    }

    return null;
  }

  /// Reset chat state (e.g. when navigating back to chat).
  void resetChat() {
    _messageCounter = 0;
    final locale = ref.read(localeProvider);
    state = ChatState(
      messages: [
        _systemMessage(AppStrings.get(locale, 'chat_greeting')),
      ],
    );
  }

  // ---- Helpers ----

  void _addSystemMessage(String text, {List<QuickReply>? quickReplies}) {
    final msg = ChatMessage(
      id: _nextId(),
      text: text,
      sender: MessageSender.system,
      timestamp: DateTime.now(),
      quickReplies: quickReplies,
    );
    state = state.copyWith(messages: [...state.messages, msg]);
  }

  ChatMessage _systemMessage(String text) {
    return ChatMessage(
      id: _nextId(),
      text: text,
      sender: MessageSender.system,
      timestamp: DateTime.now(),
    );
  }

  String _nextId() => 'msg_${++_messageCounter}';
}
