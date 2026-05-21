import 'package:flutter/material.dart';

import '../models/enums.dart';
import '../services/user_admin_service.dart';
import '../widgets/loading_state.dart';

class UsersPage extends StatelessWidget {
  const UsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final service = UserAdminService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Usuarios'),
      ),
      body: StreamBuilder(
        stream: service.watchUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingState();
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('Sin usuarios.'));
          }

          final docs = (snapshot.data as dynamic).docs as List;
          if (docs.isEmpty) {
            return const Center(child: Text('Sin usuarios.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = Map<String, dynamic>.from(doc.data() as Map<String, dynamic>);
              final uid = (data['uid'] ?? doc.id).toString();
              final name = (data['name'] ?? '').toString();
              final email = (data['email'] ?? '').toString();
              final role = UserRole.values.byName((data['role'] ?? 'auxiliar').toString());
              final status =
                  AccountStatus.values.byName((data['status'] ?? 'pendingApproval').toString());

              return _UserCard(
                uid: uid,
                name: name,
                email: email,
                role: role,
                status: status,
                onUpdate: (updatedRole, updatedStatus) async {
                  await service.updateUser(
                    uid: uid,
                    role: updatedRole,
                    status: updatedStatus,
                  );
                },
              );
            },
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemCount: docs.length,
          );
        },
      ),
    );
  }
}

class _UserCard extends StatefulWidget {
  const _UserCard({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.status,
    required this.onUpdate,
  });

  final String uid;
  final String name;
  final String email;
  final UserRole role;
  final AccountStatus status;
  final Future<void> Function(UserRole role, AccountStatus status) onUpdate;

  @override
  State<_UserCard> createState() => _UserCardState();
}

class _UserCardState extends State<_UserCard> {
  late UserRole _role;
  late AccountStatus _status;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _role = widget.role;
    _status = widget.status;
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
    });
    await widget.onUpdate(_role, _status);
    if (!mounted) {
      return;
    }
    setState(() {
      _saving = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.name.isEmpty ? widget.email : widget.name),
            const SizedBox(height: 4),
            Text(widget.email),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<UserRole>(
                    value: _role,
                    items: UserRole.values
                        .map(
                          (role) => DropdownMenuItem(
                            value: role,
                            child: Text(role.name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }
                      setState(() {
                        _role = value;
                      });
                    },
                    decoration: const InputDecoration(labelText: 'Rol'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<AccountStatus>(
                    value: _status,
                    items: AccountStatus.values
                        .map(
                          (status) => DropdownMenuItem(
                            value: status,
                            child: Text(status.name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }
                      setState(() {
                        _status = value;
                      });
                    },
                    decoration: const InputDecoration(labelText: 'Estado'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Guardar cambios'),
            ),
          ],
        ),
      ),
    );
  }
}
