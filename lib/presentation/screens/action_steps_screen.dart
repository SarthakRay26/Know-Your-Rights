import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/app_providers.dart';
import '../../domain/entities/issue.dart';
import '../../l10n/app_strings.dart';

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
                      style: Theme.of(context).textTheme.headlineMedium,
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step number circle
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${step.stepNumber}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Step content
          Expanded(
            child: Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step.titleForLocale(locale),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        border: Border(
          top: BorderSide(color: Colors.orange.shade200),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.orange[800], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              AppStrings.get(locale, 'disclaimer'),
              style: TextStyle(
                fontSize: 13,
                color: Colors.orange[900],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
