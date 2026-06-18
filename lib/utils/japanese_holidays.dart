class JapaneseHolidays {
  static bool isWeekend(DateTime date) {
    return date.weekday == DateTime.saturday ||
        date.weekday == DateTime.sunday;
  }

  static bool isHoliday(DateTime date) {
    return _holidaysForYear(date.year).contains(_key(date));
  }

  static bool isNonWorkingDay(DateTime date) {
    return isWeekend(date) || isHoliday(date);
  }

  static Set<String> _holidaysForYear(int year) {
    final holidays = <String>{};

    void add(int month, int day) {
      holidays.add(_key(DateTime(year, month, day)));
    }

    add(1, 1);
    holidays.add(_key(_nthMonday(year, 1, 2)));
    add(2, 11);
    add(2, 23);
    add(3, _vernalEquinoxDay(year));
    add(4, 29);
    add(5, 3);
    add(5, 4);
    add(5, 5);
    holidays.add(_key(_nthMonday(year, 7, 3)));
    add(8, 11);
    holidays.add(_key(_nthMonday(year, 9, 3)));
    add(9, _autumnalEquinoxDay(year));
    holidays.add(_key(_nthMonday(year, 10, 2)));
    add(11, 3);
    add(11, 23);

    _addSubstituteHolidays(year, holidays);
    _addCitizensHolidays(year, holidays);

    return holidays;
  }

  static void _addSubstituteHolidays(int year, Set<String> holidays) {
    final originalHolidays = holidays.toList();

    for (final holidayKey in originalHolidays) {
      final holiday = DateTime.parse(holidayKey);
      if (holiday.weekday != DateTime.sunday) continue;

      var substitute = holiday.add(const Duration(days: 1));
      while (holidays.contains(_key(substitute))) {
        substitute = substitute.add(const Duration(days: 1));
      }

      if (substitute.year == year) {
        holidays.add(_key(substitute));
      }
    }
  }

  static void _addCitizensHolidays(int year, Set<String> holidays) {
    final lastDay = DateTime(year, 12, 31);
    var date = DateTime(year, 1, 2);

    while (date.isBefore(lastDay)) {
      final key = _key(date);
      final previousKey = _key(date.subtract(const Duration(days: 1)));
      final nextKey = _key(date.add(const Duration(days: 1)));

      if (!holidays.contains(key) &&
          date.weekday != DateTime.sunday &&
          holidays.contains(previousKey) &&
          holidays.contains(nextKey)) {
        holidays.add(key);
      }

      date = date.add(const Duration(days: 1));
    }
  }

  static DateTime _nthMonday(int year, int month, int nth) {
    var date = DateTime(year, month, 1);
    while (date.weekday != DateTime.monday) {
      date = date.add(const Duration(days: 1));
    }
    return date.add(Duration(days: 7 * (nth - 1)));
  }

  static int _vernalEquinoxDay(int year) {
    return (20.8431 + 0.242194 * (year - 1980) - ((year - 1980) ~/ 4))
        .floor();
  }

  static int _autumnalEquinoxDay(int year) {
    return (23.2488 + 0.242194 * (year - 1980) - ((year - 1980) ~/ 4))
        .floor();
  }

  static String _key(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
