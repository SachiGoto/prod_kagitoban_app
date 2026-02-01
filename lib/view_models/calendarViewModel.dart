import 'package:flutter/material.dart';
import 'package:prod_kagitoban_app/models/member.dart';

class CalendarViewModel extends ChangeNotifier {
  DateTime? _selectedDate;

  final Map<DateTime, Member> _assignments = {};
  get assignments => _assignments;

  DateTime? get selectedDate => _selectedDate;

  Member? memberForDate(DateTime date) {
    final key = DateTime(date.year, date.month, date.day);
    return _assignments[key];
  }

  void selectDate(DateTime date) {
    _selectedDate = DateTime(date.year, date.month, date.day);
    notifyListeners();
  }

  void assignMemberToSelectedDate(Member member, date) {
    if (date == null) return;

    _assignments[date!] = member;
    notifyListeners();
  }
}
