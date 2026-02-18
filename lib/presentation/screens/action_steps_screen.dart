import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/app_providers.dart';
import '../../domain/entities/issue.dart';
import '../../l10n/app_strings.dart';
import '../theme/app_theme.dart';

/// Shows numbered action steps: what to do, documents needed, where to go.
/// Ends with a mandatory legal disclaimer.
class ActionStepsScreen extends ConsumerWidget {
  final Issue issue;

  const ActionStepsScreen({super.key, required this.issue});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.get(locale, 'action_steps')),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      issue.titleForLocale(locale),
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 24),

                    // Action step cards
                    ...issue.actionSteps.map(
                      (step) => _ActionStepCard(step: step, locale: locale),
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // Disclaimer — always visible at the bottom
            _Disclaimer(locale: locale),
          ],
        ),
      ),
    );
  }
}

class _ActionStepCard extends StatelessWidget {
  final ActionStep step;
  final String locale;

  const _ActionStepCard({required this.step, required this.locale});

  /// Cycle pastel colors for step number circles
  Color get _stepColor {
    const colors = [
      AppTheme.accentBlue,
      AppTheme.accentGreen,
      AppTheme.accentYellow,
      AppTheme.accentPurple,
    ];
    return colors[(step.stepNumber - 1) % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step number circle — pastel accent
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _stepColor,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: Center(
              child: Text(
                '${step.stepNumber}',
                style: const TextStyle(
                  color: AppTheme.controlDark,
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Step content card
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                boxShadow: AppTheme.shadowSm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.titleForLocale(locale),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    step.descriptionForLocale(locale),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Disclaimer extends StatelessWidget {
  final String locale;

  const _Disclaimer({required this.locale});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.accentYellow,
        border: const Border(
          top: BorderSide(color: Color(0xFFE8DFB0), width: 1),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded,
              color: AppTheme.controlDark, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              AppStrings.get(locale, 'disclaimer'),
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.fgPrimary,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
