import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_api/amplify_api.dart';

import 'package:prod_kagitoban_app/core/api_loading_controller.dart';
import 'package:prod_kagitoban_app/models/ModelProvider.dart';
import 'package:prod_kagitoban_app/models/member.dart';
import 'package:prod_kagitoban_app/services/line_notification_service.dart';

class CalendarViewModel extends ChangeNotifier {
  DateTime? _selectedDate;

  final Map<DateTime, Member> _assignments = {};
  Map<DateTime, Member> get assignments => _assignments;

  bool _isFinalized = false;
  bool get isFinalized => _isFinalized;

  DateTime? get selectedDate => _selectedDate;

  Member? memberForDate(DateTime date) {
    final key = DateTime(date.year, date.month, date.day);
    return _assignments[key];
  }

  void selectDate(DateTime date) {
    _selectedDate = DateTime(date.year, date.month, date.day);
    notifyListeners();
  }

  void assignMemberToSelectedDate(Member member, DateTime? date) {
    if (date == null) return;
    final key = DateTime(date.year, date.month, date.day);
    _assignments[key] = member;
    notifyListeners();
  }

  Future<void> updateAssignments({
    DateTime? month,
    Map<DateTime, Member>? assignments,
  }) async {
    var didUpdate = false;

    for (final entry in (assignments ?? _assignments).entries.toList()) {
      final date = entry.key;
      final key = DateTime(date.year, date.month, date.day);
      final updatedMember = entry.value;
      final currentMember = _assignments[key];

      if (currentMember?.id == updatedMember.id &&
          currentMember?.name == updatedMember.name &&
          currentMember?.email == updatedMember.email &&
          currentMember?.avatar == updatedMember.avatar) {
        continue;
      }

      _assignments[key] = updatedMember;
      didUpdate = true;
    }

    if (didUpdate) {
      notifyListeners();
    }

    await _saveAssignments(month: month, source: assignments ?? _assignments);
  }

  void autoAssignMembersForMonth({
    required String yyyyMM,
    required List<Member> members,
  }) {
    final activeMembers =
        members.where((member) => member.active == 1).toList();
    if (activeMembers.isEmpty) return;

    final year = int.parse(yyyyMM.substring(0, 4));
    final month = int.parse(yyyyMM.substring(4, 6));

    final daysInMonth = DateTime(year, month + 1, 0).day;

    _assignments
        .removeWhere((date, _) => date.year == year && date.month == month);

    final memberCount = activeMembers.length;
    final baseDays = daysInMonth ~/ memberCount;
    final remainder = daysInMonth % memberCount;

    int currentDay = 1;

    for (int i = 0; i < memberCount; i++) {
      final member = activeMembers[i];
      final daysForThisMember = baseDays + (i < remainder ? 1 : 0);

      for (int d = 0; d < daysForThisMember; d++) {
        if (currentDay > daysInMonth) break;
        final date = DateTime(year, month, currentDay);
        _assignments[date] = member;
        currentDay++;
      }
    }

    notifyListeners();
  }

  Future<void> finalizeAssignments({DateTime? month}) async {
    final savedAssignments = await _saveAssignments(
      month: month,
      source: _assignments,
    );

    if (savedAssignments.isNotEmpty) {
      await LineNotificationService.notifyAssignments(savedAssignments);
    }
  }

  Future<List<Map<String, String>>> _saveAssignments({
    DateTime? month,
    required Map<DateTime, Member> source,
  }) async {
    if (source.isEmpty) return [];

    final firstDate = month ?? source.keys.first;
    final yearMonth =
        '${firstDate.year}-${firstDate.month.toString().padLeft(2, '0')}';
    final monthEntries = source.entries
        .where(
          (entry) =>
              entry.key.year == firstDate.year &&
              entry.key.month == firstDate.month,
        )
        .toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    if (monthEntries.isEmpty) return [];

    final savedAssignments = monthEntries
        .map((entry) => {
              'date': entry.key.toIso8601String().substring(0, 10),
              'memberId': entry.value.id,
              'memberName': entry.value.name,
            })
        .toList();

    try {
      // Step 1: Fetch existing assignments for this month from DynamoDB
      final existing = await _listAssignmentsForMonth(yearMonth);

      // Build a map of date -> Assignment for quick lookup
      final existingMap = {
        for (final a in existing)
          if (a != null) a.date: a,
      };

      // Step 2: Compare and create/update
      for (final entry in monthEntries) {
        final date = entry.key.toIso8601String().substring(0, 10);
        final member = entry.value;
        final existing = existingMap[date];

        if (existing == null) {
          final assignment = Assignment(
            yearMonth: yearMonth,
            date: date,
            memberId: member.id,
            memberName: member.name,
          );
          final response = await ApiLoadingController.instance.run(
            () => Amplify.API
                .mutate(
                    request: ModelMutations.create(
                  assignment,
                  authorizationMode: APIAuthorizationType.apiKey,
                ))
                .response,
          );
          if (response.errors.isNotEmpty) {
            throw Exception(response.errors.first.message);
          }
          safePrint('✅ Created: $date');
        } else if (existing.memberId != member.id ||
            existing.memberName != member.name) {
          final updated = existing.copyWith(
            memberId: member.id,
            memberName: member.name,
          );
          final response = await ApiLoadingController.instance.run(
            () => Amplify.API
                .mutate(
                    request: ModelMutations.update(updated,
                        authorizationMode: APIAuthorizationType.apiKey))
                .response,
          );
          if (response.errors.isNotEmpty) {
            throw Exception(response.errors.first.message);
          }
          safePrint('🔄 Updated: $date');
        } else {
          safePrint('⏭ Skipped: $date');
        }
      }

      safePrint('✅ All assignments saved!');
      await loadAssignments(yearMonth);
      return savedAssignments;
    } on ApiException catch (e) {
      safePrint('Mutation failed: $e');
      rethrow;
    }
  }

  Future<void> loadAssignments(String yearMonth) async {
    final items = await _listAssignmentsForMonth(yearMonth);

    _assignments.clear();

    if (items.isNotEmpty) {
      _isFinalized = true;
      // populate _assignments map from DB
      for (final a in items) {
        if (a == null) continue;
        final date = DateTime.parse(a.date);
        _assignments[date] = Member(id: a.memberId, name: a.memberName);
      }
    } else {
      _isFinalized = false;
    }

    notifyListeners();
  }

  Future<List<Assignment?>> _listAssignmentsForMonth(String yearMonth) async {
    final items = <Assignment?>[];
    var request = ModelQueries.list(
      Assignment.classType,
      where: Assignment.YEARMONTH.eq(yearMonth),
      limit: 100,
    );

    while (true) {
      final response = await ApiLoadingController.instance.run(
        () => Amplify.API.query(request: request).response,
      );

      if (response.errors.isNotEmpty) {
        throw Exception(response.errors.first.message);
      }

      final page = response.data;
      if (page == null) break;

      items.addAll(page.items);

      final nextRequest = page.requestForNextResult;
      if (nextRequest == null) break;

      request = nextRequest;
    }

    return items;
  }
}
