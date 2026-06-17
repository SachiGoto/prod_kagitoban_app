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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Members'),
      ),
      body: memberViewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : memberViewModel.error != null
              ? Center(child: Text(memberViewModel.error!))
              : memberViewModel.members.isEmpty
                  ? const Center(child: Text('No members found'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: memberViewModel.members.length,
                      itemBuilder: (context, index) {
                        final member = memberViewModel.members[index];
                        final name =
                            member.name.isNotEmpty ? member.name : 'No Name';
                        final avatar = member.avatar ?? '';
                        final selectedDate = widget.selectedDate;
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
                            subtitle: Text(member.email ?? ''),
                            trailing: FilledButton(
                              onPressed: () =>
                                  memberViewModel.toggleActive(member.id),
                              child: Text(member.active == 1 ? 'On' : 'Off'),
                            ),
                            onTap: assignMember,
                          ),
                        );
                      },
                    ),
    );
  }
}
