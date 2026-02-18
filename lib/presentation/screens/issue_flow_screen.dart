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
  @override
  void initState() {
    super.initState();
    // Start the flow when the screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(issueFlowProvider.notifier).startFlow(widget.issue);
    });
  }

  @override
  Widget build(BuildContext context) {
    final flowState = ref.watch(issueFlowProvider);
    final locale = ref.watch(localeProvider);

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
