import 'package:flutter/material.dart';
import '../../domain/entities/issue.dart';
import '../screens/action_steps_screen.dart';
import '../screens/chat_screen.dart';
import '../screens/home_screen.dart';
import '../screens/issue_flow_screen.dart';
import '../screens/language_selection_screen.dart';
import '../screens/rights_explanation_screen.dart';

/// Centralized route generation.
/// Named routes keep navigation logic out of individual screens.
class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
      case '/language':
        return MaterialPageRoute(
          builder: (_) => const LanguageSelectionScreen(),
          settings: settings,
        );

      case '/home':
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
          settings: settings,
        );

      case '/chat':
        return MaterialPageRoute(
          builder: (_) => const ChatScreen(),
          settings: settings,
        );

      case '/issue-flow':
        final issue = settings.arguments as Issue;
        return MaterialPageRoute(
          builder: (_) => IssueFlowScreen(issue: issue),
          settings: settings,
        );

      case '/rights':
        final issue = settings.arguments as Issue;
        return MaterialPageRoute(
          builder: (_) => RightsExplanationScreen(issue: issue),
          settings: settings,
        );

      case '/action-steps':
        final issue = settings.arguments as Issue;
        return MaterialPageRoute(
          builder: (_) => ActionStepsScreen(issue: issue),
          settings: settings,
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Route not found: ${settings.name}'),
            ),
          ),
        );
    }
  }
}
