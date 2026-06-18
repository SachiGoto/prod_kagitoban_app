import 'package:flutter/material.dart';
import 'package:prod_kagitoban_app/view_models/calendarViewModel.dart';
import 'package:prod_kagitoban_app/view_models/memberViewMode.dart';
import 'package:provider/provider.dart';

class MembersScreen extends StatefulWidget {
  static const routeName = '/members';
  final DateTime? selectedDate;

  const MembersScreen({super.key, this.selectedDate});

  @override
  State<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MemberViewModel>().loadMembers();
    });
  }

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final memberViewModel = context.watch<MemberViewModel>();
    debugPrint(memberViewModel.members.toString());
    final selectedDate = widget.selectedDate;
    return Scaffold(
      appBar: AppBar(
        title: const Text('メンバー一覧'),
      ),
      body: memberViewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : memberViewModel.error != null
              ? Center(child: Text(memberViewModel.error!))
              : memberViewModel.members.isEmpty
                  ? const Center(child: Text('No members found'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: memberViewModel.members.length +
                          (selectedDate == null ? 0 : 1),
                      itemBuilder: (context, index) {
                        if (selectedDate != null && index == 0) {
                          return Card(
                            child: ListTile(
                              leading: const CircleAvatar(
                                child: Icon(Icons.person_off),
                              ),
                              title: const Text('担当者なし'),
                              subtitle: const Text('この日の割り当てを外す'),
                              onTap: () {
                                context
                                    .read<CalendarViewModel>()
                                    .unassignSelectedDate(selectedDate);
                                Navigator.pop(context, '担当者なし');
                              },
                            ),
                          );
                        }

                        final memberIndex =
                            selectedDate == null ? index : index - 1;
                        final member = memberViewModel.members[memberIndex];
                        final name =
                            member.name.isNotEmpty ? member.name : 'No Name';
                        final avatar = member.avatar ?? '';
                        final VoidCallback? assignMember = selectedDate == null
                            ? null
                            : () {
                                context
                                    .read<CalendarViewModel>()
                                    .assignMemberToSelectedDate(
                                      member,
                                      selectedDate,
                                    );
                                Navigator.pop(context, name);
                              };

                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage: avatar.isNotEmpty
                                  ? NetworkImage(avatar)
                                  : null,
                              child: avatar.isEmpty
                                  ? Text(_getInitials(name))
                                  : null,
                            ),
                            title: Text(name),
                            trailing: member.active == 1
                                ? FilledButton(
                                    onPressed: () =>
                                        memberViewModel.toggleActive(member.id),
                                    child: const Text('On'),
                                  )
                                : OutlinedButton(
                                    onPressed: () =>
                                        memberViewModel.toggleActive(member.id),
                                    child: const Text('Off'),
                                  ),
                            onTap: assignMember,
                          ),
                        );
                      },
                    ),
    );
  }
}
