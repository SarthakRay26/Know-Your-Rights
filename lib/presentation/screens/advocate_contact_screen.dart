import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../application/providers/app_providers.dart';
import '../../l10n/app_strings.dart';
import '../theme/app_theme.dart';

/// A neutral, professional screen that shows advocate contact details.
///
/// The user must check the acknowledgment checkbox before contact
/// buttons are enabled. No marketing language — purely informational.
class AdvocateContactScreen extends ConsumerStatefulWidget {
  const AdvocateContactScreen({super.key});

  @override
  ConsumerState<AdvocateContactScreen> createState() =>
      _AdvocateContactScreenState();
}

class _AdvocateContactScreenState extends ConsumerState<AdvocateContactScreen> {
  bool _acknowledged = false;

  // ── Advocate details ──
  static const _advocateName = 'Sanjay Kumar Ray';
  static const _association = 'Sarthak Law Academy';
  static const _practiceAreas = 'Supreme Court and High Court';
  static const _phone = '8240935363';
  static const _email = 'sanjaykray@rediffmail.com';

  Future<void> _makeCall() async {
    final uri = Uri.parse('tel:$_phone');
    await launchUrl(uri);
  }

  Future<void> _sendEmail() async {
    final uri = Uri.parse('mailto:$_email');
    await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.get(locale, 'need_legal_advice')),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Intro section ──
              _InfoSection(
                icon: Icons.info_outline_rounded,
                text: AppStrings.get(locale, 'advocate_intro'),
                color: AppTheme.accentBlue,
              ),
              const SizedBox(height: 16),

              // ── Neutral reminder ──
              _InfoSection(
                icon: Icons.people_outline_rounded,
                text: AppStrings.get(locale, 'advocate_reminder'),
                color: AppTheme.accentGreen,
              ),
              const SizedBox(height: 28),

              // ── Disclosure ──
              Text(
                AppStrings.get(locale, 'advocate_disclosure'),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 16),

              // ── Advocate card ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  boxShadow: AppTheme.shadowSm,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    _DetailRow(
                      label: AppStrings.get(locale, 'advocate_name'),
                      value: _advocateName,
                    ),
                    const SizedBox(height: 14),
                    // Association
                    _DetailRow(
                      label: AppStrings.get(locale, 'advocate_association'),
                      value: _association,
                    ),
                    const SizedBox(height: 14),
                    // Practice areas
                    _DetailRow(
                      label: AppStrings.get(locale, 'advocate_practice'),
                      value: _practiceAreas,
                    ),
                    const SizedBox(height: 14),
                    // Phone
                    _DetailRow(
                      label: AppStrings.get(locale, 'advocate_phone'),
                      value: _phone,
                    ),
                    const SizedBox(height: 14),
                    // Email
                    _DetailRow(
                      label: AppStrings.get(locale, 'advocate_email'),
                      value: _email,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Acknowledgment checkbox ──
              GestureDetector(
                onTap: () => setState(() => _acknowledged = !_acknowledged),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: _acknowledged,
                        onChanged: (v) =>
                            setState(() => _acknowledged = v ?? false),
                        activeColor: AppTheme.controlDark,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusSm / 2),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        AppStrings.get(locale, 'advocate_acknowledgment'),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // ── Contact buttons (enabled only when acknowledged) ──
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _acknowledged ? _makeCall : null,
                      icon: const Icon(Icons.phone_rounded, size: 18),
                      label: Text(AppStrings.get(locale, 'advocate_phone')),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _acknowledged ? _sendEmail : null,
                      icon: const Icon(Icons.email_outlined, size: 18),
                      label: Text(AppStrings.get(locale, 'advocate_email')),
                    ),
                  ),
                ],
              ),

              // ── Disclaimer ──
              const SizedBox(height: 20),
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
}

// ──────────────────────────────────────────────────────────
// Private helper widgets
// ──────────────────────────────────────────────────────────

class _InfoSection extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _InfoSection({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.45),
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

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppTheme.fgTertiary,
                fontSize: 12,
                letterSpacing: 0.3,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.fgPrimary,
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }
}
