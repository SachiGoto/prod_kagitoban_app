import 'package:flutter/material.dart';
import 'package:prod_kagitoban_app/utils/japanese_holidays.dart';
import 'package:prod_kagitoban_app/view_models/calendarViewModel.dart';
import 'package:prod_kagitoban_app/view_models/memberViewMode.dart';
import 'package:provider/provider.dart';
import 'members.dart';
import 'package:amplify_flutter/amplify_flutter.dart';

class CalendarScreen extends StatefulWidget {
  static const routeName = '/calendar';

  const CalendarScreen({Key? key}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime _today = DateTime.now();

  String _keyForDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final session = await Amplify.Auth.fetchAuthSession();

      debugPrint('Calendar auth signed in: ${session.isSignedIn}');

      if (!mounted) return;

      if (!session.isSignedIn) {
        await Amplify.Auth.signInWithWebUI(
          provider: const AuthProvider.oidc('LINE', 'LINE'),
        );
        return;
      }

      await context.read<MemberViewModel>().loadMembers();

      if (!mounted) return;

      _loadCurrentMonth();
    });
  }

  void _loadCurrentMonth() {
    final calendarVM = context.read<CalendarViewModel>();
    final yearMonth =
        '${_focusedMonth.year}-${_focusedMonth.month.toString().padLeft(2, '0')}';
    calendarVM.loadAssignments(yearMonth);
  }

  void _previousMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
    });
    _loadCurrentMonth();
  }

  void _nextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
    });
    _loadCurrentMonth();
  }

  Future<void> _confirmFinalize(CalendarViewModel calendarVM) async {
    final shouldFinalize = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('スケジュールを確定しますか？'),
        content: Text('$_monthLabel の鍵当番を確定して、担当者にLINE通知を送ります。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('いいえ'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('はい'),
          ),
        ],
      ),
    );

    if (shouldFinalize != true) return;

    await calendarVM.finalizeAssignments(month: _focusedMonth);
  }

  Future<void> _confirmUpdate(CalendarViewModel calendarVM) async {
    final shouldUpdate = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('スケジュールを変更しますか？'),
        content: Text('$_monthLabel の鍵当番を更新して、変更がある担当者にLINE通知を送ります。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('いいえ'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('はい'),
          ),
        ],
      ),
    );

    if (shouldUpdate != true) return;

    await calendarVM.updateAssignments(month: _focusedMonth);
  }

  List<String> get _weekdayLabels =>
      ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  String get _monthLabel {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${months[_focusedMonth.month - 1]} ${_focusedMonth.year}';
  }

  bool get _isPastMonth {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);
    final focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month);
    return focusedMonth.isBefore(currentMonth);
  }

  @override
  Widget build(BuildContext context) {
    final firstOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final calendarVM = context.watch<CalendarViewModel>();
    final assignments = calendarVM.assignments;
    final hasAssignmentsForFocusedMonth = assignments.keys.any(
      (date) =>
          date.year == _focusedMonth.year && date.month == _focusedMonth.month,
    );
    debugPrint("loaded assignments: ${assignments.length}");
    debugPrint(
        "loaded assignments: ${assignments.keys.map((d) => _keyForDate(d)).join(', ')}");
    final startOffset = firstOfMonth.weekday - 1;
    final daysInMonth =
        DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;

    final cells = List<Widget>.generate(42, (index) {
      final dayNumber = index - startOffset + 1;
      if (dayNumber < 1 || dayNumber > daysInMonth) {
        return Container();
      }

      final date = DateTime(_focusedMonth.year, _focusedMonth.month, dayNumber);
      final isToday = date.year == _today.year &&
          date.month == _today.month &&
          date.day == _today.day;
      final isSaturday = date.weekday == DateTime.saturday;
      final isSunday = date.weekday == DateTime.sunday;
      final isHoliday = JapaneseHolidays.isHoliday(date);
      final isNonWorkingDay = isSaturday || isSunday || isHoliday;
      final backgroundColor = isToday
          ? Theme.of(context).colorScheme.primary.withOpacity(0.15)
          : isHoliday || isSunday
              ? Colors.red.withOpacity(0.10)
              : isSaturday
                  ? Colors.blue.withOpacity(0.10)
                  : null;
      final dayTextColor = isToday
          ? Theme.of(context).colorScheme.primary
          : isHoliday || isSunday
              ? Colors.red
              : isSaturday
                  ? Colors.blue
                  : null;

      return AspectRatio(
        aspectRatio: 1.0,
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () async {
              final selected = await Navigator.push<String>(
                context,
                MaterialPageRoute(
                  builder: (context) => MembersScreen(selectedDate: date),
                ),
              );

              if (selected != null && selected.isNotEmpty) {
                setState(() {});
                final dateLabel =
                    date.toLocal().toIso8601String().split('T').first;
                final message = selected == '担当者なし'
                    ? '$dateLabel の担当者を外しました'
                    : 'Assigned "$selected" to $dateLabel';
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(message),
                  ),
                );
              }
            },
            child: Container(
              alignment: Alignment.topCenter,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '$dayNumber',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: dayTextColor,
                      ),
                    ),
                    if (isNonWorkingDay)
                      Text(
                        isHoliday ? '祝日' : '休み',
                        style: TextStyle(
                          fontSize: 10,
                          color:
                              isHoliday || isSunday ? Colors.red : Colors.blue,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (assignments.containsKey(date))
                      Text(
                        assignments[date]?.name ?? 'No assignment',
                        style: const TextStyle(fontSize: 11),
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('鍵当番スケジュール'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 820),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final monthTitle = Text(
                      _monthLabel,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge,
                    );

                    final actionButtons = Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: _isPastMonth
                              ? null
                              : () {
                                  final yyyyMM =
                                      '${_focusedMonth.year}${_focusedMonth.month.toString().padLeft(2, '0')}';

                                  calendarVM.autoAssignMembersForMonth(
                                    yyyyMM: yyyyMM,
                                    members: context
                                        .read<MemberViewModel>()
                                        .activeMembers,
                                  );
                                },
                          child: const Text('自動割り当て'),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: _isPastMonth ||
                                  (!calendarVM.isFinalized &&
                                      !hasAssignmentsForFocusedMonth)
                              ? null
                              : () => calendarVM.isFinalized
                                  ? _confirmUpdate(calendarVM)
                                  : _confirmFinalize(calendarVM),
                          child: Text(calendarVM.isFinalized ? '更新' : '確定'),
                        ),
                      ],
                    );

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              onPressed: _previousMonth,
                              icon: const Icon(Icons.chevron_left),
                              tooltip: 'Previous month',
                            ),
                            Expanded(
                              child: Center(child: monthTitle),
                            ),
                            IconButton(
                              onPressed: _nextMonth,
                              icon: const Icon(Icons.chevron_right),
                              tooltip: 'Next month',
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Center(child: actionButtons),
                      ],
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: _weekdayLabels
                  .map(
                    (label) => Expanded(
                      child: Center(
                        child: Text(
                          label,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: GridView.count(
                padding: EdgeInsets.only(
                  bottom: kBottomNavigationBarHeight +
                      MediaQuery.of(context).padding.bottom +
                      12,
                ),
                crossAxisCount: 7,
                childAspectRatio: 1,
                children: cells,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.restorablePushNamed(context, MembersScreen.routeName);
          }
        },
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month), label: 'スケジュール'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'メンバー'),
        ],
      ),
    );
  }
}
