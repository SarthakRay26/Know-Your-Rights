import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/app_providers.dart';
import '../../domain/entities/issue.dart';
import '../../l10n/app_strings.dart';
import '../theme/app_theme.dart';

/// Maps issue icon strings from JSON to actual Material Icons.
const Map<String, IconData> _iconMap = {
  'currency_rupee': Icons.currency_rupee,
  'home': Icons.home_rounded,
  'security': Icons.security_rounded,
  'receipt_long': Icons.receipt_long_rounded,
  'local_police': Icons.local_police_rounded,
  'shield': Icons.shield_rounded,
  'emergency': Icons.emergency_rounded,
  'help_outline': Icons.help_outline_rounded,
};

/// Pastel accent colors cycled per card for visual variety.
const List<Color> _cardAccents = [
  AppTheme.accentBlue,
  AppTheme.accentGreen,
  AppTheme.accentYellow,
  AppTheme.accentPurple,
];

/// Home screen: "What happened?" — shows large, accessible issue buttons.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final issuesAsync = ref.watch(issuesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.get(locale, 'app_title')),
        actions: [
          // Language switcher shortcut
          IconButton(
            icon: const Icon(Icons.language_rounded),
            tooltip: AppStrings.get(locale, 'select_language'),
            onPressed: () {
              Navigator.of(context).pushNamed('/language');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: issuesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (issues) => _IssueGrid(issues: issues, locale: locale),
        ),
      ),
      // FAB — dark pill
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).pushNamed('/chat');
        },
        icon: const Icon(Icons.chat_rounded),
        label: Text(AppStrings.get(locale, 'describe_problem')),
      ),
    );
  }
}

class _IssueGrid extends StatelessWidget {
  final List<Issue> issues;
  final String locale;

  const _IssueGrid({required this.issues, required this.locale});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Text(
            AppStrings.get(locale, 'home_title'),
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 4),
          Text(
            AppStrings.get(locale, 'home_subtitle'),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.only(bottom: 88),
              itemCount: issues.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final issue = issues[index];
                return _IssueCard(
                  issue: issue,
                  locale: locale,
                  accent: _cardAccents[index % _cardAccents.length],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _IssueCard extends StatelessWidget {
  final Issue issue;
  final String locale;
  final Color accent;

  const _IssueCard({
    required this.issue,
    required this.locale,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final icon = _iconMap[issue.icon] ?? Icons.help_outline_rounded;

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
          onTap: () {
            Navigator.of(context).pushNamed(
              '/issue-flow',
              arguments: issue,
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Pastel icon container
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
                  child: Icon(
                    icon,
                    size: 26,
                    color: AppTheme.controlDark,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    issue.titleForLocale(locale),
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
