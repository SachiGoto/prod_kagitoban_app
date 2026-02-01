// lib/services/line_user_service.dart
import 'dart:convert';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';

class LineUserService {
  /// CREATE (low-level)
  static Future<void> createLineUser({
    required String id,
    String? name,
    String? email,
    String? avatar,
  }) async {
    final request = GraphQLRequest<String>(
      document: '''
      mutation CreateLineUser(\$input: CreateLineUserInput!) {
        createLineUser(input: \$input) {
          id
        }
      }
      ''',
      variables: {
        'input': {
          'id': id,
          'name': name,
          'email': email,
          'avatar': avatar,
        }
      },
      authorizationMode: APIAuthorizationType.userPools,
    );

    final response = await Amplify.API.mutate(request: request).response;

    debugPrint('=== CREATE LINE USER MUTATION ===');
    debugPrint('Data: ${response.data}');
    debugPrint('Errors: ${response.errors}');

    // Ignore "already exists"
    final isDuplicate = response.errors.any(
      (e) =>
          e.errorType == 'DynamoDB:ConditionalCheckFailedException' ||
          e.message.toLowerCase().contains('conditional request failed'),
    );

    if (isDuplicate) {
      debugPrint('ℹ️ LineUser already exists → skip insert');
      return;
    }

    if (response.errors.isNotEmpty) {
      throw Exception(response.errors.first.message);
    }
  }

  /// CREATE IF NOT EXISTS (safe to call many times)
  static Future<void> createLineUserIfNotExists({
    required String id,
    String? name,
    String? email,
    String? avatar,
  }) async {
    try {
      debugPrint('🔐 Ensuring LineUser exists (id=$id)');

      await createLineUser(
        id: id,
        name: name,
        email: email,
        avatar: avatar,
      );

      debugPrint('✅ LineUser ensured');
    } catch (e) {
      debugPrint('❌ Failed to create LineUser: $e');
      rethrow;
    }
  }

  /// READ ALL
  static Future<List<Map<String, dynamic>>> listLineUsers() async {
    final request = GraphQLRequest<String>(
      document: '''
      query ListLineUsers {
        listLineUsers {
          nextToken
          items {
            id
            name
            email
            avatar
          }
        }
      }
      ''',
      authorizationMode: APIAuthorizationType.userPools, // ✅ important
    );

    final response = await Amplify.API.query(request: request).response;

    if (response.errors.isNotEmpty) {
      throw Exception(response.errors.first.message);
    }

    if (response.data == null) return [];

    final decoded = jsonDecode(response.data!) as Map<String, dynamic>;
    final items = decoded['listLineUsers']?['items'] as List<dynamic>? ?? [];

    return items.cast<Map<String, dynamic>>();
  }
}
