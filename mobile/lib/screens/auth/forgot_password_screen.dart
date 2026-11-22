import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../utils/validators.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _fk = GlobalKey<FormState>();
  final _ec = TextEditingController();
  bool _load = false;

  @override
  void dispose() {
    _ec.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_fk.currentState!.validate()) return;
    setState(() => _load = true);
    final msg = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);
    try {
      await AuthService().sendPasswordReset(_ec.text);
      msg.showSnackBar(const SnackBar(
          content: Text('If this email exists, a reset link has been sent.')));
      nav.pop();
    } on AuthException catch (e) {
      msg.showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _load = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
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
                    const Icon(Icons.lock_reset, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text(
                      "Enter your email and we'll send a reset link.",
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _ec,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: Validators.email,
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
                          : const Text('Send reset link'),
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
