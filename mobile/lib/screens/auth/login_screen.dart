import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../services/auth_service.dart';
import '../../utils/validators.dart';
import '../../widgets/geometric_background.dart';
import '../../widgets/neo_widgets.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _fk = GlobalKey<FormState>();
  final _ec = TextEditingController();
  final _pc = TextEditingController();
  bool _load = false, _obs = true;

  @override
  void dispose() {
    _ec.dispose();
    _pc.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_fk.currentState!.validate()) return;
    setState(() => _load = true);
    try {
      await AuthService().signIn(email: _ec.text, password: _pc.text);
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _load = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GeometricBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: AppColors.yellow,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.black, width: 2.5),
                            boxShadow: const [
                              BoxShadow(color: AppColors.black, offset: Offset(3, 3), blurRadius: 0),
                            ],
                          ),
                          child: const Icon(Icons.eco, color: AppColors.black, size: 32),
                        ),
                        const SizedBox(width: 14),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'CAMPUS\nSAVE',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: AppColors.black,
                                height: 1.1,
                                letterSpacing: -1,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    // Form card
                    NeoCard(
                      color: Colors.white,
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _fk,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Sign in',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: AppColors.black,
                              ),
                            ),
                            const SizedBox(height: 20),
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
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _submit(),
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
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: _load
                                    ? null
                                    : () => Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (_) => const ForgotPasswordScreen()),
                                        ),
                                child: const Text(
                                  'Forgot password?',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.black),
                                ),
                              ),
                            ),
                            NeoButton(
                              label: 'Sign in',
                              onPressed: _load ? null : _submit,
                              isLoading: _load,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    NeoCard(
                      color: AppColors.cardGreen,
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      onTap: _load
                          ? null
                          : () => Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const RegisterScreen()),
                              ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Text(
                            'Register →',
                            style: TextStyle(
                                fontWeight: FontWeight.w900, color: AppColors.black),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.cardYellow,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.black26),
                        ),
                        child: const Text(
                          '🔑 Admin: admin@campussave.tn',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ),
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
