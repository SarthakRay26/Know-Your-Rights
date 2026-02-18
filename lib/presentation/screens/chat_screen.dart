import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/app_providers.dart';
import '../../application/providers/chat_providers.dart';
import '../../domain/entities/chat_message.dart';
import '../../l10n/app_strings.dart';
import '../theme/app_theme.dart';

/// Chat-style intake screen where users describe their problem in natural
/// language. The backend classifies the input and routes to the correct
/// legal awareness flow. No AI-generated advice is ever shown.
class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _onSend() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    _textController.clear();
    ref.read(chatProvider.notifier).sendMessage(text);
    _focusNode.requestFocus();
  }

  void _onQuickReply(String value) {
    final result = ref.read(chatProvider.notifier).handleQuickReply(value);
    if (result == null) return; // rephrase — stay on chat

    if (result.route == '/issue-flow-by-id') {
      // Resolve issue_id to Issue object, then navigate
      _navigateToIssueFlow(result.arguments as String);
    } else {
      Navigator.of(context).pushReplacementNamed(result.route);
    }
  }

  Future<void> _navigateToIssueFlow(String issueId) async {
    final repo = ref.read(issueRepositoryProvider);
    final issue = await repo.getIssueById(issueId);
    if (issue != null && mounted) {
      ref.read(chatProvider.notifier).resetChat();
      Navigator.of(context).pushNamed('/issue-flow', arguments: issue);
    } else if (mounted) {
      // Issue not found locally — fall back to manual selection
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);
    final locale = ref.watch(localeProvider);

    // Auto-scroll when messages change
    ref.listen(chatProvider, (prev, next) {
      if (prev?.messages.length != next.messages.length ||
          prev?.isLoading != next.isLoading) {
        _scrollToBottom();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.get(locale, 'chat_title')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            ref.read(chatProvider.notifier).resetChat();
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Message list
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                itemCount: chatState.messages.length +
                    (chatState.isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  // Show typing indicator at the end while loading
                  if (index == chatState.messages.length &&
                      chatState.isLoading) {
                    return const _TypingIndicator();
                  }

                  final message = chatState.messages[index];
                  return _ChatBubble(
                    message: message,
                    onQuickReply: _onQuickReply,
                  );
                },
              ),
            ),

            // Input bar
            _ChatInputBar(
              controller: _textController,
              focusNode: _focusNode,
              isLoading: chatState.isLoading,
              locale: locale,
              onSend: _onSend,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Chat bubble
// ---------------------------------------------------------------------------

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final void Function(String value) onQuickReply;

  const _ChatBubble({
    required this.message,
    required this.onQuickReply,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.sender == MessageSender.user;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // Message bubble
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.78,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: isUser ? AppTheme.controlDark : AppTheme.surface,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(AppTheme.radiusLg),
                topRight: const Radius.circular(AppTheme.radiusLg),
                bottomLeft:
                    Radius.circular(isUser ? AppTheme.radiusLg : 4),
                bottomRight:
                    Radius.circular(isUser ? 4 : AppTheme.radiusLg),
              ),
              boxShadow: AppTheme.shadowSm,
            ),
            child: Text(
              message.text,
              style: TextStyle(
                fontSize: 15,
                height: 1.45,
                color: isUser ? Colors.white : AppTheme.fgPrimary,
                letterSpacing: -0.1,
              ),
            ),
          ),

          // Quick reply buttons (system messages only)
          if (message.quickReplies != null &&
              message.quickReplies!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: message.quickReplies!.map((reply) {
                return OutlinedButton(
                  onPressed: () => onQuickReply(reply.value),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 40),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusFull),
                    ),
                    side: const BorderSide(
                      color: AppTheme.controlDark,
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    reply.label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.controlDark,
                      letterSpacing: -0.1,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Typing indicator (shown while waiting for backend)
// ---------------------------------------------------------------------------

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppTheme.radiusLg),
              topRight: Radius.circular(AppTheme.radiusLg),
              bottomRight: Radius.circular(AppTheme.radiusLg),
              bottomLeft: Radius.circular(4),
            ),
            boxShadow: AppTheme.shadowSm,
          ),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (index) {
                  // Stagger each dot by a phase offset
                  final offset = index * 0.33;
                  final value =
                      (((_controller.value + offset) % 1.0) * 2 - 1).abs();
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Opacity(
                      opacity: 0.3 + (0.7 * (1 - value)),
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppTheme.fgTertiary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  );
                }),
              );
            },
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Input bar
// ---------------------------------------------------------------------------

class _ChatInputBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isLoading;
  final String locale;
  final VoidCallback onSend;

  const _ChatInputBar({
    required this.controller,
    required this.focusNode,
    required this.isLoading,
    required this.locale,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000000).withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Multiline text field — pill-shaped
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              enabled: !isLoading,
              maxLines: 4,
              minLines: 1,
              textInputAction: TextInputAction.newline,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: AppStrings.get(locale, 'chat_input_hint'),
                hintStyle: const TextStyle(
                  color: AppTheme.fgTertiary,
                  fontSize: 15,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  borderSide: const BorderSide(
                    color: AppTheme.controlDark,
                    width: 1.5,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                filled: true,
                fillColor: AppTheme.surfaceElevated,
              ),
              style: const TextStyle(
                fontSize: 15,
                color: AppTheme.fgPrimary,
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Send button — dark circle
          Material(
            color:
                isLoading ? AppTheme.surfaceElevated : AppTheme.controlDark,
            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
            child: InkWell(
              onTap: isLoading ? null : onSend,
              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              child: Container(
                width: 46,
                height: 46,
                alignment: Alignment.center,
                child: Icon(
                  Icons.arrow_upward_rounded,
                  color: isLoading ? AppTheme.fgTertiary : Colors.white,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
