import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'application/providers/app_providers.dart';
import 'data/repositories/hive_preferences_repository.dart';
import 'presentation/router/app_router.dart';
import 'presentation/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for local storage (preferences, bookmarks)
  await Hive.initFlutter();
  final prefsRepo = HivePreferencesRepository();
  await prefsRepo.init();

  // Load persisted preferences before rendering
  final savedLocale = await prefsRepo.getSelectedLanguage();
  final onboardingDone = await prefsRepo.hasCompletedOnboarding();

  runApp(
    ProviderScope(
      overrides: [
        // Inject the concrete preferences repository
        preferencesRepositoryProvider.overrideWithValue(prefsRepo),
      ],
      child: _EagerInitializer(
        savedLocale: savedLocale,
        onboardingDone: onboardingDone,
      ),
    ),
  );
}

/// Initializes locale and onboarding state before the first frame.
class _EagerInitializer extends ConsumerStatefulWidget {
  final String? savedLocale;
  final bool onboardingDone;

  const _EagerInitializer({
    required this.savedLocale,
    required this.onboardingDone,
  });

  @override
  ConsumerState<_EagerInitializer> createState() => _EagerInitializerState();
}

class _EagerInitializerState extends ConsumerState<_EagerInitializer> {
  @override
  void initState() {
    super.initState();
    // Hydrate providers with persisted data
    if (widget.savedLocale != null) {
      ref.read(localeProvider.notifier).setLocale(widget.savedLocale!);
    }
    if (widget.onboardingDone) {
      ref.read(onboardingCompleteProvider.notifier).complete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return const KnowYourRightsApp();
  }
}

class KnowYourRightsApp extends ConsumerWidget {
  const KnowYourRightsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardingDone = ref.watch(onboardingCompleteProvider);

    return MaterialApp(
      title: 'Know Your Rights',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      // Start on language selection if not yet completed, else home
      initialRoute: onboardingDone ? '/home' : '/',
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
