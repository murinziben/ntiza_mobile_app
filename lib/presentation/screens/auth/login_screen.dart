import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/validators.dart';
import '../../providers/providers.dart';
import '../../widgets/ui.dart';

/// "Remember me" checkbox state (ephemeral UI state, kept out of setState).
final _rememberProvider = StateProvider.autoDispose<bool>((ref) => true);

/// E-mail + password login with Google as the second sign-in method.
/// After a successful sign-in the router redirect moves the user to their home.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _email;
  final _password = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-fill the address saved by "Remember me" on the previous login.
    _email = TextEditingController(text: ref.read(settingsControllerProvider).rememberedEmail);
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final result = await ref.read(authControllerProvider.notifier).signIn(
          _email.text,
          _password.text,
          remember: ref.read(_rememberProvider),
        );
    if (mounted && !result.ok) showToast(context, result.error!);
  }

  Future<void> _google() async {
    final result = await ref.read(authControllerProvider.notifier).signInWithGoogle();
    if (mounted && !result.ok) showToast(context, result.error!);
  }

  @override
  Widget build(BuildContext context) {
    final busy = ref.watch(authControllerProvider).busy;
    final remember = ref.watch(_rememberProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
            children: [
              const Align(alignment: Alignment.centerLeft, child: LogoLockup()),
              const SizedBox(height: 26),
              const Text('Welcome back',
                  style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              const Text('Log in to manage your bookings, equipment and consultations.',
                  style: TextStyle(fontSize: 17, height: 1.4, color: AppColors.muted)),
              const SizedBox(height: 26),
              LabeledField('E-mail',
                  hint: 'you@example.com',
                  icon: Icons.mail_outline,
                  controller: _email,
                  keyboard: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  validator: Validators.email),
              const SizedBox(height: 18),
              LabeledField('Password',
                  hint: '••••••••',
                  icon: Icons.shield_outlined,
                  obscure: true,
                  controller: _password,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.password],
                  validator: Validators.loginPassword,
                  onSubmitted: (_) => busy ? null : _login()),
              const SizedBox(height: 6),
              Row(
                children: [
                  Flexible(
                    child: InkWell(
                      onTap: () => ref.read(_rememberProvider.notifier).state = !remember,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 48),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                color: remember ? AppColors.primary : Colors.white,
                                borderRadius: BorderRadius.circular(7),
                                border: Border.all(color: AppColors.primary),
                              ),
                              child: remember
                                  ? const Icon(Icons.check, size: 18, color: Colors.white)
                                  : null,
                            ),
                            const SizedBox(width: 10),
                            const Text('Remember me',
                                style: TextStyle(fontSize: 15, color: AppColors.body)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => context.push('/forgot-password'),
                    style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
                    child: const Text('Forgot password?',
                        style: TextStyle(fontSize: 15, color: AppColors.primaryDark)),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              PrimaryButton(busy ? 'Please wait…' : 'Log In',
                  height: 54, onPressed: busy ? null : _login),
              const SizedBox(height: 14),
              OutlineButtonX('Continue with Google',
                  height: 54, onPressed: busy ? null : _google),
              const SizedBox(height: 18),
              const Row(children: [
                Expanded(child: Divider()),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text('New to NTIZA?',
                      style: TextStyle(fontSize: 14, color: AppColors.faint)),
                ),
                Expanded(child: Divider()),
              ]),
              const SizedBox(height: 18),
              OutlineButtonX('Create an Account',
                  height: 54, onPressed: () => context.push('/register')),
              const SizedBox(height: 22),
              AppCard(
                color: AppColors.green50,
                borderColor: AppColors.green50,
                onTap: () => context.push('/register'),
                child: const Row(
                  children: [
                    Icon(Icons.agriculture_outlined, color: AppColors.primaryDark),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Own equipment or offer advice?',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                          Text('Apply to become a partner',
                              style: TextStyle(fontSize: 14, color: AppColors.primaryDark)),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: AppColors.primaryDark),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
