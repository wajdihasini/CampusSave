import 'package:flutter/material.dart';
import '../../models/user_role.dart';
import '../../services/auth_service.dart';
import '../../utils/validators.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _fk  = GlobalKey<FormState>();
  final _nc  = TextEditingController();
  final _ec  = TextEditingController();
  final _pc  = TextEditingController();
  final _cc  = TextEditingController();
  final _bc  = TextEditingController();
  UserRole _role = UserRole.student;
  bool _load = false, _obs = true;

  @override
  void dispose() {
    _nc.dispose(); _ec.dispose(); _pc.dispose();
    _cc.dispose(); _bc.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_fk.currentState!.validate()) return;
    setState(() => _load = true);
    try {
      await AuthService().register(
        name: _nc.text,
        email: _ec.text,
        password: _pc.text,
        role: _role,
        businessName: _bc.text,
      );
      if (!mounted) return;
      Navigator.of(context).pop();
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _load = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _fk,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Who are you?',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _RoleChip(
                            label: 'Student',
                            icon: Icons.school,
                            selected: _role == UserRole.student,
                            onTap: () => setState(() => _role = UserRole.student),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _RoleChip(
                            label: 'Merchant',
                            icon: Icons.storefront,
                            selected: _role == UserRole.merchant,
                            onTap: () => setState(() => _role = UserRole.merchant),
                          ),
                        ),
                      ],
                    ),
                    if (_role == UserRole.merchant) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: s.secondaryContainer,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline,
                                size: 16, color: s.onSecondaryContainer),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Your account will be reviewed by admin '
                                'before activation.',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: s.onSecondaryContainer),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nc,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Full name',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (v) =>
                          Validators.required(v, label: 'Name'),
                    ),
                    if (_role == UserRole.merchant) ...[
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _bc,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Business name',
                          prefixIcon: Icon(Icons.storefront_outlined),
                        ),
                        validator: (v) => _role == UserRole.merchant
                            ? Validators.required(v, label: 'Business name')
                            : null,
                      ),
                    ],
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _ec,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: Validators.email,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _pc,
                      obscureText: _obs,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(_obs
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined),
                          onPressed: () => setState(() => _obs = !_obs),
                        ),
                      ),
                      validator: Validators.password,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _cc,
                      obscureText: _obs,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                      decoration: const InputDecoration(
                        labelText: 'Confirm password',
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                      validator: (v) =>
                          Validators.confirmPassword(v, _pc.text),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _load ? null : _submit,
                      child: _load
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Register'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _RoleChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? s.primary : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: selected ? s.primary : Colors.grey.shade300, width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: selected ? Colors.white : Colors.grey, size: 28),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
