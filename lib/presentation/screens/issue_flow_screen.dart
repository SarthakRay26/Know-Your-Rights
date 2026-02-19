import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/app_providers.dart';
import '../../domain/entities/issue.dart';
import '../../l10n/app_strings.dart';
import '../theme/app_theme.dart';

/// Displays the step-by-step decision flow for an issue.
/// Each question shows selectable options with a progress indicator.
class IssueFlowScreen extends ConsumerStatefulWidget {
  final Issue issue;

  const IssueFlowScreen({super.key, required this.issue});

  @override
  ConsumerState<IssueFlowScreen> createState() => _IssueFlowScreenState();
}

class _IssueFlowScreenState extends ConsumerState<IssueFlowScreen> {
  /// Whether we're showing the self-check phase.
  bool _inSelfCheck = true;

  /// The option the user selected in the self-check (null = not yet answered).
  String? _selfCheckAnswer;

  /// Whether to show the balanced note after answering.
  bool _showBalancedNote = false;

  @override
  void initState() {
    super.initState();
    // Skip self-check if the issue doesn't have one
    if (widget.issue.selfCheck == null) {
      _inSelfCheck = false;
    }
    // Start the flow when the screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(issueFlowProvider.notifier).startFlow(widget.issue);
    });
  }

  void _onSelfCheckOptionSelected(String optionId) {
    setState(() {
      _selfCheckAnswer = optionId;
      // Show balanced note for all answers to encourage awareness
      _showBalancedNote = true;
    });
  }

  void _onSelfCheckContinue() {
    setState(() {
      _inSelfCheck = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);

    // ── Self-check phase ──
    if (_inSelfCheck && widget.issue.selfCheck != null) {
      return _buildSelfCheckScreen(context, locale);
    }

    // ── Normal decision flow ──
    return _buildDecisionFlow(context, locale);
  }

  Widget _buildSelfCheckScreen(BuildContext context, String locale) {
    final selfCheck = widget.issue.selfCheck!;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.issue.titleForLocale(locale)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppTheme.accentBlue,
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    ),
                    child: const Icon(Icons.psychology_outlined,
                        size: 18, color: AppTheme.controlDark),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      AppStrings.get(locale, 'self_check_title'),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Question
              Text(
                selfCheck.questionForLocale(locale),
                style: Theme.of(context).textTheme.headlineMedium,
              ),

              const SizedBox(height: 24),

              // Options
              ...selfCheck.options.map((option) {
                final isSelected = _selfCheckAnswer == option.optionId;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.accentBlue
                          : AppTheme.surface,
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusLg),
                      boxShadow: AppTheme.shadowSm,
                      border: isSelected
                          ? Border.all(
                              color: AppTheme.controlDark, width: 1.5)
                          : null,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusLg),
                      child: InkWell(
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusLg),
                        onTap: () => _onSelfCheckOptionSelected(
                            option.optionId),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  option.labelForLocale(locale),
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium,
                                ),
                              ),
                              if (isSelected)
                                const Icon(Icons.check_rounded,
                                    color: AppTheme.controlDark, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),

              // Balanced note (shown after selection)
              if (_showBalancedNote) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.accentYellow,
                    borderRadius:
                        BorderRadius.circular(AppTheme.radiusLg),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline_rounded,
                          color: AppTheme.controlDark, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          selfCheck.balancedNoteForLocale(locale),
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: AppTheme.fgPrimary),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const Spacer(),

              // Continue button
              if (_selfCheckAnswer != null)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _onSelfCheckContinue,
                    child: Text(
                        AppStrings.get(locale, 'self_check_continue')),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDecisionFlow(BuildContext context, String locale) {
    final flowState = ref.watch(issueFlowProvider);

    if (flowState == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // If the flow is complete, navigate to the rights screen
    if (flowState.isComplete) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed(
          '/rights',
          arguments: widget.issue,
        );
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final question = flowState.currentQuestion;
    final totalQuestions = widget.issue.questions.length;
    final currentStep = flowState.currentQuestionIndex + 1;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.issue.titleForLocale(locale)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (flowState.currentQuestionIndex > 0) {
              ref.read(issueFlowProvider.notifier).goBack();
            } else {
              ref.read(issueFlowProvider.notifier).reset();
              Navigator.of(context).pop();
            }
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress indicator
              _ProgressBar(
                current: currentStep,
                total: totalQuestions,
                locale: locale,
              ),

              const SizedBox(height: 32),

              // Question text
              Text(
                question.textForLocale(locale),
                style: Theme.of(context).textTheme.headlineMedium,
              ),

              const SizedBox(height: 28),

              // Options
              Expanded(
                child: ListView.separated(
                  itemCount: question.options.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final option = question.options[index];
                    return _OptionCard(
                      label: option.labelForLocale(locale),
                      onTap: () {
                        ref
                            .read(issueFlowProvider.notifier)
                            .selectOption(option);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final int current;
  final int total;
  final String locale;

  const _ProgressBar({
    required this.current,
    required this.total,
    required this.locale,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.getFormatted(locale, 'step_of', {
            'current': current.toString(),
            'total': total.toString(),
          }),
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          child: LinearProgressIndicator(
            value: current / total,
            minHeight: 6,
            backgroundColor: AppTheme.surfaceElevated,
            valueColor: const AlwaysStoppedAnimation(AppTheme.controlDark),
          ),
        ),
      ],
    );
  }
}

class _OptionCard extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _OptionCard({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppTheme.fgTertiary,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
