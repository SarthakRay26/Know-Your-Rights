import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/app_providers.dart';
import '../../domain/entities/issue.dart';
import '../../l10n/app_strings.dart';

/// Maps issue icon strings from JSON to actual Material Icons.
const Map<String, IconData> _iconMap = {
  'currency_rupee': Icons.currency_rupee,
  'home': Icons.home,
  'security': Icons.security,
  'receipt_long': Icons.receipt_long,
  'local_police': Icons.local_police,
  'help_outline': Icons.help_outline,
};

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
            icon: const Icon(Icons.language),
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
      // FAB to launch chat-based problem description
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text(
            AppStrings.get(locale, 'home_title'),
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 4),
          Text(
            AppStrings.get(locale, 'home_subtitle'),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.separated(
              itemCount: issues.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final issue = issues[index];
                return _IssueCard(issue: issue, locale: locale);
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

  const _IssueCard({required this.issue, required this.locale});

  @override
  Widget build(BuildContext context) {
    final icon = _iconMap[issue.icon] ?? Icons.help_outline;

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.of(context).pushNamed(
            '/issue-flow',
            arguments: issue,
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 28,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  issue.titleForLocale(locale),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
