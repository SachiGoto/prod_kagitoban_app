import 'dart:convert';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:prod_kagitoban_app/core/api_loading_controller.dart';

class LineNotificationService {
  static const _notifyMutation = r'''
    mutation notifyUsers($assignments: AWSJSON!) {
      notifyUsers(assignments: $assignments)
    }
  ''';

  static Future<void> notifyAssignments(
      List<Map<String, String>> assignments) async {
    if (assignments.isEmpty) {
      return;
    }

    final authMode = await _getPreferredAuthorizationMode();

    final jsonAssignments = assignments
        .map((assignment) => Map<String, dynamic>.from(assignment))
        .toList();

    // AWSJSON に渡すため、Listをそのまま渡さず、JSON文字列にする
    final jsonPayload = jsonEncode({
      'items': jsonAssignments,
    });

    debugPrint('LINE notify payload authMode=$authMode: $jsonPayload');

    final request = GraphQLRequest<String>(
      document: _notifyMutation,
      variables: {
        'assignments': jsonPayload,
      },
      authorizationMode: authMode,
    );

    try {
      final response = await ApiLoadingController.instance.run(
        () => Amplify.API.mutate(request: request).response,
      );

      if (response.errors.isNotEmpty) {
        throw Exception(response.errors.map((e) => e.message).join(', '));
      }
    } on Exception catch (e) {
      final fallbackMode = authMode == APIAuthorizationType.apiKey
          ? APIAuthorizationType.userPools
          : APIAuthorizationType.apiKey;

      if (e.toString().contains('Not Authorized')) {
        final fallbackRequest = GraphQLRequest<String>(
          document: _notifyMutation,
          variables: {
            'assignments': jsonPayload,
          },
          authorizationMode: fallbackMode,
        );

        final response = await ApiLoadingController.instance.run(
          () => Amplify.API.mutate(request: fallbackRequest).response,
        );

        if (response.errors.isNotEmpty) {
          throw Exception(response.errors.map((e) => e.message).join(', '));
        }

        return;
      }

      rethrow;
    }
  }

  static Future<APIAuthorizationType> _getPreferredAuthorizationMode() async {
    try {
      final session = await Amplify.Auth.fetchAuthSession();
      if (session.isSignedIn) {
        return APIAuthorizationType.userPools;
      }
    } catch (_) {
      // ignore and fall back to apiKey
    }

    return APIAuthorizationType.apiKey;
  }
}
