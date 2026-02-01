import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:prod_kagitoban_app/models/member.dart';
import 'package:prod_kagitoban_app/services/line_user_service.dart';
import 'package:prod_kagitoban_app/view_models/calendarViewModel.dart';
import 'package:provider/provider.dart';

/// Simple members screen with logged-in user from LINE authentication.
class MembersScreen extends StatefulWidget {
  static const routeName = '/members';
  DateTime? selectedDate;

  MembersScreen({Key? key, this.selectedDate}) : super(key: key);
  @override
  State<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  String _userName = 'Loading...';
  String _userPicture = '';
  bool _isLoading = true;
  List<Map<String, dynamic>> _members = [];

  @override
  void initState() {
    super.initState();
    // _fetchUserInfo();
    _fetchMembers();
  }

  Future<void> _fetchMembers() async {
    debugPrint('🔥 _fetchMembers started');
    print(widget.selectedDate);

    try {
      final users = await LineUserService.listLineUsers();
      debugPrint('✅ users fetched: ${users.length}');
      debugPrint(users.toString());

      setState(() {
        _members = users;
        _isLoading = false;
      });
    } catch (e, stack) {
      debugPrint('❌ Error loading members: $e');
      debugPrint(stack.toString());

      setState(() {
        _isLoading = false; // ← CRITICAL
      });
    }
  }

  // Future<void> _fetchUserInfo() async {
  //   try {
  //     // First, just get the current user (this should always work)
  //     final user = await Amplify.Auth.getCurrentUser();
  //     debugPrint('=== CURRENT USER ===');
  //     debugPrint('User ID: ${user.userId}');
  //     debugPrint('Username: ${user.username}');
  //     debugPrint('Sign-in details: ${user.signInDetails}');

  //     // Try to get session without forcing credential refresh
  //     final session = await Amplify.Auth.fetchAuthSession(
  //       options: const FetchAuthSessionOptions(forceRefresh: false),
  //     );
  //     debugPrint('=== SESSION ===');
  //     debugPrint('Is signed in: ${session.isSignedIn}');

  //     final cognitoSession = session as CognitoAuthSession;

  //     // Check if we have tokens
  //     final tokensResult = cognitoSession.userPoolTokensResult;
  //     if (tokensResult.value != null) {
  //       final idToken = tokensResult.value!.idToken;
  //       debugPrint('=== ID TOKEN (raw) ===');
  //       debugPrint('Token: ${idToken.raw.substring(0, 50)}...');

  //       // Decode claims
  //       final parts = idToken.raw.split('.');
  //       if (parts.length == 3) {
  //         final payload = base64Url.normalize(parts[1]);
  //         final decoded = utf8.decode(base64Url.decode(payload));
  //         final claims = jsonDecode(decoded) as Map<String, dynamic>;

  //         debugPrint('=== ID TOKEN CLAIMS ===');
  //         claims.forEach((key, value) {
  //           debugPrint('$key: $value');
  //         });

  //         setState(() {
  //           _userName = claims['name'] ??
  //               claims['preferred_username'] ??
  //               claims['cognito:username'] ??
  //               user.username;
  //           _userPicture = claims['picture'] ?? '';
  //           _isLoading = false;
  //         });
  //         return;
  //       }
  //     } else {
  //       debugPrint('No tokens available');
  //     }

  //     // Fallback
  //     setState(() {
  //       _userName = user.username;
  //       _isLoading = false;
  //     });
  //   } catch (e) {
  //     debugPrint('Error fetching user info: $e');
  //     // Try basic fallback
  //     try {
  //       final user = await Amplify.Auth.getCurrentUser();
  //       setState(() {
  //         _userName = user.username;
  //         _isLoading = false;
  //       });
  //     } catch (_) {
  //       setState(() {
  //         _userName = 'Unknown User';
  //         _isLoading = false;
  //       });
  //     }
  //   }
  // }

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Members'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _members.isEmpty
              ? const Center(child: Text('No members found'))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _members.length,
                  itemBuilder: (context, index) {
                    final user = _members[index];

                    final name = (user['name'] as String?)?.isNotEmpty == true
                        ? user['name']
                        : 'No Name';

                    final avatar = user['avatar'] as String? ?? '';

                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage:
                              avatar.isNotEmpty ? NetworkImage(avatar) : null,
                          child:
                              avatar.isEmpty ? Text(_getInitials(name)) : null,
                        ),
                        title: Text(name),
                        subtitle: Text(user['email'] ?? ''),
                        onTap: () {
                          final member = Member(
                            id: user['id'] as String,
                            name: name,
                            email: user['email'] as String?,
                            avatar: avatar,
                          );
                          context
                              .read<CalendarViewModel>()
                              .assignMemberToSelectedDate(
                                  member, widget.selectedDate);
                          Navigator.pop(context);
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
