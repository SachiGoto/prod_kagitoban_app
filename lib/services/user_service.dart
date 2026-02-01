import 'dart:convert';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:flutter/foundation.dart';

class UserService {
  /// Save or update user info in DynamoDB after sign-in
  static Future<void> saveUserOnSignIn() async {
    try {
      final user = await Amplify.Auth.getCurrentUser();
      final session = await Amplify.Auth.fetchAuthSession();
      final cognitoSession = session as CognitoAuthSession;

      // Extract user info from ID token claims
      final idToken = cognitoSession.userPoolTokensResult.value?.idToken;
      if (idToken == null) {
        debugPrint('No ID token available');
        return;
      }

      // Decode JWT claims
      final parts = idToken.raw.split('.');
      if (parts.length != 3) return;

      final payload = base64Url.normalize(parts[1]);
      final decoded = utf8.decode(base64Url.decode(payload));
      final claims = jsonDecode(decoded) as Map<String, dynamic>;

      // Extract user data
      final cognitoId = user.userId;
      final displayName = claims['name'] ?? claims['preferred_username'];
      final email = claims['email'];
      final pictureUrl = claims['picture'];

      // Extract LINE user ID from identities
      String? lineUserId;
      if (claims['identities'] != null) {
        final identities = claims['identities'] as List;
        final lineIdentity = identities.firstWhere(
          (id) => id['providerName'] == 'LINE',
          orElse: () => null,
        );
        if (lineIdentity != null) {
          lineUserId = lineIdentity['userId'];
        }
      }

      final now = DateTime.now().toUtc().toIso8601String();

      // Create or update user using GraphQL mutation
      final createUserMutation = '''
        mutation CreateOrUpdateUser(\$input: CreateUserInput!) {
          createUser(input: \$input) {
            cognitoId
            displayName
            email
            pictureUrl
            lineUserId
            createdAt
            lastLoginAt
          }
        }
      ''';

      final updateUserMutation = '''
        mutation UpdateUser(\$input: UpdateUserInput!) {
          updateUser(input: \$input) {
            cognitoId
            displayName
            email
            pictureUrl
            lineUserId
            lastLoginAt
          }
        }
      ''';

      // Try to update first (existing user), if fails, create new
      try {
        final updateResponse = await Amplify.API.mutate(
          request: GraphQLRequest<String>(
            document: updateUserMutation,
            variables: {
              'input': {
                'cognitoId': cognitoId,
                'displayName': displayName,
                'email': email,
                'pictureUrl': pictureUrl,
                'lineUserId': lineUserId,
                'lastLoginAt': now,
              },
            },
          ),
        ).response;

        if (updateResponse.errors.isEmpty) {
          debugPrint('User updated successfully');
          return;
        }
      } catch (e) {
        debugPrint('Update failed, trying create: $e');
      }

      // Create new user
      final createResponse = await Amplify.API.mutate(
        request: GraphQLRequest<String>(
          document: createUserMutation,
          variables: {
            'input': {
              'cognitoId': cognitoId,
              'displayName': displayName,
              'email': email,
              'pictureUrl': pictureUrl,
              'lineUserId': lineUserId,
              'createdAt': now,
              'lastLoginAt': now,
            },
          },
        ),
      ).response;

      if (createResponse.errors.isEmpty) {
        debugPrint('User created successfully');
      } else {
        debugPrint('Error creating user: ${createResponse.errors}');
      }
    } catch (e) {
      debugPrint('Error saving user: $e');
    }
  }
}
