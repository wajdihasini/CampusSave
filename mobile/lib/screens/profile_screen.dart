import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/user_role.dart';
import '../services/auth_service.dart';
import '../utils/validators.dart';

class ProfileScreen extends StatelessWidget {
  final User user; final UserRole? role;
  const ProfileScreen({super.key, required this.user, this.role});

  Future<void> _editName(BuildContext c, String cur) async {
    final msg = ScaffoldMessenger.of(c);
    final n = await showDialog<String>(context: c,
      builder: (_) => _EditNameDialog(initial: cur));
    if (n == null) return;
    try { await AuthService().updateDisplayName(n);
      msg.showSnackBar(const SnackBar(content: Text('Name updated.'))); }
    on AuthException catch (e) { msg.showSnackBar(SnackBar(content: Text(e.message))); }
  }

  Future<void> _resetPwd(BuildContext c, String email) async {
    final msg = ScaffoldMessenger.of(c);
    try { await AuthService().sendPasswordReset(email);
      msg.showSnackBar(SnackBar(content: Text('Reset link sent to $email.'))); }
    on AuthException catch (e) { msg.showSnackBar(SnackBar(content: Text(e.message))); }
  }

  Future<void> _signOut(BuildContext c) async {
    final nav = Navigator.of(c);
    final ok = await showDialog<bool>(context: c, builder: (ctx) => AlertDialog(
      title: const Text('Sign out'),
      content: const Text('Do you want to sign out?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
        TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Sign out')),
      ]));
    if (ok != true) return;
    nav.popUntil((r) => r.isFirst);
    await AuthService().signOut();
  }

  @override Widget build(BuildContext c) => Scaffold(
    appBar: AppBar(title: const Text('My Profile')),
    body: StreamBuilder<User?>(stream: AuthService().userChanges, initialData: user,
      builder: (c, snap) {
        final u = snap.data ?? user;
        final name = (u.displayName ?? '').trim();
        final email = u.email ?? '';
        final init = (name.isNotEmpty ? name : email).isNotEmpty
          ? (name.isNotEmpty ? name : email)[0].toUpperCase() : '?';
        final s = Theme.of(c).colorScheme;
        return ListView(padding: const EdgeInsets.all(24), children: [
          Center(child: CircleAvatar(radius: 44, backgroundColor: s.primaryContainer,
            child: Text(init, style: TextStyle(fontSize: 32, color: s.onPrimaryContainer,
              fontWeight: FontWeight.bold)))),
          const SizedBox(height: 14),
          Text(name.isEmpty ? 'No name set' : name, textAlign: TextAlign.center,
            style: Theme.of(c).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(email, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 10),
          if (role != null) Center(child: Chip(
            avatar: Icon(role == UserRole.admin ? Icons.admin_panel_settings
              : role == UserRole.merchant ? Icons.storefront : Icons.school, size: 16),
            label: Text(role!.label))),
          const SizedBox(height: 24),
          Card(child: Column(children: [
            ListTile(leading: const Icon(Icons.edit_outlined), title: const Text('Edit name'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _editName(c, name)),
            const Divider(height: 1),
            ListTile(leading: const Icon(Icons.lock_reset), title: const Text('Reset password'),
              subtitle: const Text('Receive a link by email'),
              trailing: const Icon(Icons.chevron_right),
              onTap: email.isEmpty ? null : () => _resetPwd(c, email)),
          ])),
          const SizedBox(height: 24),
          OutlinedButton.icon(onPressed: () => _signOut(c),
            icon: const Icon(Icons.logout, color: Colors.red),
            label: const Text('Sign out', style: TextStyle(color: Colors.red)),
            style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red))),
        ]);
      }));
}

class _EditNameDialog extends StatefulWidget {
  final String initial;
  const _EditNameDialog({required this.initial});
  @override State<_EditNameDialog> createState() => _EditNameDialogState();
}
class _EditNameDialogState extends State<_EditNameDialog> {
  final _fk = GlobalKey<FormState>();
  late final TextEditingController _c;
  @override void initState() { super.initState(); _c = TextEditingController(text: widget.initial); }
  @override void dispose() { _c.dispose(); super.dispose(); }
  void _save() { if (_fk.currentState!.validate()) Navigator.pop(context, _c.text.trim()); }
  @override Widget build(BuildContext c) => AlertDialog(
    title: const Text('Edit name'),
    content: Form(key: _fk, child: TextFormField(controller: _c, autofocus: true,
      textCapitalization: TextCapitalization.words,
      decoration: const InputDecoration(labelText: 'Full name'),
      validator: (v) => Validators.required(v, label: 'Name'),
      onFieldSubmitted: (_) => _save())),
    actions: [
      TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancel')),
      TextButton(onPressed: _save, child: const Text('Save')),
    ]);
}
