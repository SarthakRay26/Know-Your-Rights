import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../domain/entities/chat_message.dart';

/// Communicates with the classification backend.
/// Performs ONLY classification — no legal advice is generated or returned.
class ClassificationService {
  /// Base URL of the deployed backend.
  static const _baseUrl = 'https://know-your-right-backend.onrender.com';
  static const _classifyEndpoint = '/api/classify';

  /// Render free tier can have cold starts — allow extra time.
  static const _timeout = Duration(seconds: 30);

  final http.Client _client;

  ClassificationService({http.Client? client})
      : _client = client ?? http.Client();

  /// Sends the user's problem description to the backend for classification.
  /// Returns a [ClassificationResult] with issue_id and confidence.
  /// Throws on network/server errors — caller must handle gracefully.
  Future<ClassificationResult> classify(String userText) async {
    final uri = Uri.parse('$_baseUrl$_classifyEndpoint');

    try {
      debugPrint('[ClassificationService] POST $uri');
      final response = await _client
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'text': userText}),
          )
          .timeout(_timeout);

      debugPrint('[ClassificationService] Status: ${response.statusCode}');
      debugPrint('[ClassificationService] Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return ClassificationResult.fromJson(data);
      } else {
        throw ClassificationException(
          'Server returned ${response.statusCode}',
          response.statusCode,
        );
      }
    } catch (e) {
      debugPrint('[ClassificationService] Error: $e');
      rethrow;
    }
  }

  void dispose() {
    _client.close();
  }
}

/// Custom exception for classification failures.
class ClassificationException implements Exception {
  final String message;
  final int? statusCode;

  const ClassificationException(this.message, [this.statusCode]);

  @override
  String toString() => 'ClassificationException: $message';
}
