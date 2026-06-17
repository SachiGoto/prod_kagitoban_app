import 'package:flutter/material.dart';
import 'package:prod_kagitoban_app/models/member.dart';
import 'package:prod_kagitoban_app/services/line_user_service.dart';
import 'package:prod_kagitoban_app/stub/members_stub.dart';

class MemberViewModel extends ChangeNotifier {
  List<Member> _members = [];
  List<Member> get members => _members;
  List<Member> get activeMembers =>
      _members.where((member) => member.active == 1).toList();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> loadMembers() async {
    if (_members.isNotEmpty) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final lineUsers = await LineUserService.listLineUsers();

      _members = lineUsers
          .map(
            (user) => Member(
              id: user.id,
              name: user.name ?? 'No Name',
              email: user.email,
              avatar: user.avatar,
              active: 1,
            ),
          )
          .toList();

      debugPrint('Loaded ${_members.length} members');
    } catch (e) {
      debugPrint('Exception loading members: $e');
      _error = 'Could not load members.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void toggleActive(String id) {
    final index = _members.indexWhere((member) => member.id == id);
    if (index != -1) {
      final member = _members[index];
      _members[index] = Member(
        id: member.id,
        name: member.name,
        email: member.email,
        avatar: member.avatar,
        active: member.active == 1 ? 0 : 1,
      );
      notifyListeners();
    }
  }
}
