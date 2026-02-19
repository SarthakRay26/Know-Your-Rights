import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/app_providers.dart';
import '../../domain/entities/issue.dart';
import '../../l10n/app_strings.dart';
import '../theme/app_theme.dart';

/// Shows plain-language legal rights, myths, applicable laws, timeline,
/// obligations, allowed actions, other-side perspective, misuse warnings,
/// and escalation boundaries.
class RightsExplanationScreen extends ConsumerStatefulWidget {
  final Issue issue;

  const RightsExplanationScreen({super.key, required this.issue});

  @override
  ConsumerState<RightsExplanationScreen> createState() =>
      _RightsExplanationScreenState();
}

class _RightsExplanationScreenState
    extends ConsumerState<RightsExplanationScreen> {
  /// false = "Your Side", true = "Other Perspective"
  bool _showOtherSide = false;

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final content = widget.issue.content;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.get(locale, 'your_rights')),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Issue title
              Text(
                widget.issue.titleForLocale(locale),
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 20),

              // ── Perspective toggle ──
              _buildPerspectiveToggle(locale),
              const SizedBox(height: 24),

              // ── YOUR SIDE content ──
              if (!_showOtherSide) ...[
                // What the law says
                _SectionHeader(
                  icon: Icons.balance_rounded,
                  title: AppStrings.get(locale, 'what_law_says'),
                  accent: AppTheme.accentBlue,
                ),
                const SizedBox(height: 12),
                Text(
                  content.explanationForLocale(locale),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 28),

                // Allowed actions
                if (content.allowedActions.isNotEmpty) ...[
                  _SectionHeader(
                    icon: Icons.check_circle_outline_rounded,
                    title: AppStrings.get(locale, 'allowed_actions'),
                    accent: AppTheme.accentGreen,
                  ),
                  const SizedBox(height: 12),
                  ...content.allowedActionsForLocale(locale).map(
                        (action) => _BulletItem(
                          text: action,
                          icon: Icons.check_rounded,
                          iconColor: const Color(0xFF2E7D32),
                          iconBg: AppTheme.accentGreen,
                        ),
                      ),
                  const SizedBox(height: 28),
                ],

                // Common myths
                if (content.myths.isNotEmpty) ...[
                  _SectionHeader(
                    icon: Icons.lightbulb_outline_rounded,
                    title: AppStrings.get(locale, 'common_myths'),
                    accent: AppTheme.accentYellow,
                  ),
                  const SizedBox(height: 12),
                  ...content.myths.map(
                    (myth) => _MythCard(myth: myth, locale: locale),
                  ),
                  const SizedBox(height: 28),
                ],

                // Applicable laws
                if (content.applicableLaws.isNotEmpty) ...[
                  _SectionHeader(
                    icon: Icons.menu_book_rounded,
                    title: AppStrings.get(locale, 'applicable_laws'),
                    accent: AppTheme.accentPurple,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: content.applicableLaws
                        .map((law) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.accentPurple,
                                borderRadius:
                                    BorderRadius.circular(AppTheme.radiusFull),
                              ),
                              child: Text(
                                law,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.fgPrimary,
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 28),
                ],

                // Timeline
                _SectionHeader(
                  icon: Icons.schedule_rounded,
                  title: AppStrings.get(locale, 'typical_timeline'),
                  accent: AppTheme.accentGreen,
                ),
                const SizedBox(height: 12),
                _InfoBox(
                  text: content.timelineForLocale(locale),
                  color: AppTheme.accentYellow,
                  icon: Icons.info_outline_rounded,
                ),

                const SizedBox(height: 28),

                // Your obligations / What you should NOT do
                if (content.obligations.isNotEmpty) ...[
                  _SectionHeader(
                    icon: Icons.warning_amber_rounded,
                    title: AppStrings.get(locale, 'your_obligations'),
                    accent: const Color(0xFFFDE8E8),
                  ),
                  const SizedBox(height: 12),
                  ...content.obligationsForLocale(locale).map(
                        (obligation) => _BulletItem(
                          text: obligation,
                          icon: Icons.arrow_forward_rounded,
                          iconColor: const Color(0xFFD32F2F),
                          iconBg: const Color(0xFFFDE8E8),
                        ),
                      ),
                  const SizedBox(height: 28),
                ],

                // Misuse warning
                if (content.misuseWarningForLocale(locale).isNotEmpty) ...[
                  _SectionHeader(
                    icon: Icons.gavel_rounded,
                    title: AppStrings.get(locale, 'misuse_warning'),
                    accent: const Color(0xFFFDE8E8),
                  ),
                  const SizedBox(height: 12),
                  _InfoBox(
                    text: content.misuseWarningForLocale(locale),
                    color: const Color(0xFFFDE8E8),
                    icon: Icons.report_outlined,
                  ),
                  const SizedBox(height: 28),
                ],

                // Escalation boundaries
                if (content.escalationBoundaries != null) ...[
                  _SectionHeader(
                    icon: Icons.trending_up_rounded,
                    title: AppStrings.get(locale, 'escalation_guide'),
                    accent: AppTheme.accentBlue,
                  ),
                  const SizedBox(height: 12),
                  _EscalationCard(
                    boundaries: content.escalationBoundaries!,
                    locale: locale,
                  ),
                  const SizedBox(height: 28),
                ],
              ],

              // ── OTHER SIDE content ──
              if (_showOtherSide) ...[
                if (content
                    .otherSidePerspectiveForLocale(locale)
                    .isNotEmpty) ...[
                  _SectionHeader(
                    icon: Icons.people_alt_outlined,
                    title: AppStrings.get(locale, 'other_perspective'),
                    accent: AppTheme.accentBlue,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    content.otherSidePerspectiveForLocale(locale),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 28),
                ],

                // Re-show escalation boundaries for context
                if (content.escalationBoundaries != null) ...[
                  _SectionHeader(
                    icon: Icons.trending_up_rounded,
                    title: AppStrings.get(locale, 'escalation_guide'),
                    accent: AppTheme.accentBlue,
                  ),
                  const SizedBox(height: 12),
                  _EscalationCard(
                    boundaries: content.escalationBoundaries!,
                    locale: locale,
                  ),
                  const SizedBox(height: 28),
                ],
              ],

              // Navigate to action steps — dark pill button
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(
                    '/action-steps',
                    arguments: widget.issue,
                  );
                },
                child: Text(AppStrings.get(locale, 'see_action_steps')),
              ),

              // Disclaimer
              const SizedBox(height: 16),
              Text(
                AppStrings.get(locale, 'disclaimer'),
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppTheme.fgTertiary),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPerspectiveToggle(String locale) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: _ToggleTab(
              label: AppStrings.get(locale, 'your_side'),
              isActive: !_showOtherSide,
              onTap: () => setState(() => _showOtherSide = false),
            ),
          ),
          Expanded(
            child: _ToggleTab(
              label: AppStrings.get(locale, 'other_perspective'),
              isActive: _showOtherSide,
              onTap: () => setState(() => _showOtherSide = true),
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────
// Private helper widgets
// ──────────────────────────────────────────────────────────

class _ToggleTab extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _ToggleTab({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          boxShadow: isActive ? AppTheme.shadowSm : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            color: isActive ? AppTheme.fgPrimary : AppTheme.fgSecondary,
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color accent;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: accent,
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          ),
          child: Icon(icon, size: 18, color: AppTheme.controlDark),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
      ],
    );
  }
}

class _InfoBox extends StatelessWidget {
  final String text;
  final Color color;
  final IconData icon;

  const _InfoBox({
    required this.text,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.controlDark, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.fgPrimary,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BulletItem extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;

  const _BulletItem({
    required this.text,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: Icon(icon, size: 14, color: iconColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }
}

class _MythCard extends StatelessWidget {
  final Myth myth;
  final String locale;

  const _MythCard({required this.myth, required this.locale});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Myth
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDE8E8),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                  child: const Icon(Icons.close_rounded,
                      color: Color(0xFFD32F2F), size: 16),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.get(locale, 'myth_label'),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFD32F2F),
                          fontSize: 12,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        myth.mythForLocale(locale),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppTheme.fgPrimary,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Divider(height: 1),
            ),
            // Fact
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppTheme.accentGreen,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                  child: const Icon(Icons.check_rounded,
                      color: Color(0xFF2E7D32), size: 16),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.get(locale, 'fact_label'),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2E7D32),
                          fontSize: 12,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        myth.factForLocale(locale),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppTheme.fgPrimary,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EscalationCard extends StatelessWidget {
  final EscalationBoundaries boundaries;
  final String locale;

  const _EscalationCard({
    required this.boundaries,
    required this.locale,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        children: [
          // Reasonable section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.accentGreen.withValues(alpha: 0.5),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppTheme.radiusLg),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.check_circle_outline_rounded,
                        color: Color(0xFF2E7D32), size: 18),
                    const SizedBox(width: 8),
                    Text(
                      AppStrings.get(locale, 'when_to_escalate'),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  boundaries.reasonableForLocale(locale),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          // Caution section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFDE8E8).withValues(alpha: 0.5),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(AppTheme.radiusLg),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        color: Color(0xFFD32F2F), size: 18),
                    const SizedBox(width: 8),
                    Text(
                      AppStrings.get(locale, 'when_escalation_risky'),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Color(0xFFD32F2F),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  boundaries.cautionForLocale(locale),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
