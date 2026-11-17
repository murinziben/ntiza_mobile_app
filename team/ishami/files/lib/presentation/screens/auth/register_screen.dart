import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/constants.dart';
import '../../../domain/entities/entities.dart';
import '../../../domain/validators.dart';
import '../../providers/providers.dart';
import '../../widgets/ui.dart';

/// Role chosen on the sign-up screen.
final _roleProvider = StateProvider.autoDispose<Role>((ref) => Role.farmer);

/// District chosen on the sign-up screen; starts at the saved preference.
final _districtProvider = StateProvider.autoDispose<String?>((ref) {
  final saved = ref.read(settingsControllerProvider).preferredDistrict;
  return districts.contains(saved) ? saved : null;
});

/// The four roles a person can sign up as, with a one-line description.
const registerRoles = <(Role, String, IconData)>[
  (Role.farmer, 'Book equipment & experts, take training', Icons.eco_outlined),
  (Role.owner, 'List machines and earn from bookings', Icons.agriculture_outlined),
  (Role.expert, 'Offer paid consultations', Icons.groups_2_outlined),
  (Role.agent, 'Book on behalf of farmers, earn commission', Icons.smartphone_outlined),
];

/// E-mail/password sign-up. Partner roles are created as "pending" until an
/// admin approves them; the router sends everyone to e-mail verification next.
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final result = await ref.read(authControllerProvider.notifier).register(
          role: ref.read(_roleProvider),
          name: _name.text,
          email: _email.text,
          phone: _phone.text,
          district: ref.read(_districtProvider) ?? '',
          password: _password.text,
          confirmPassword: _confirm.text,
        );
    if (!mounted) return;
    showToast(context, result.ok
        ? 'Account created. Check your e-mail to verify it.'
        : result.error!);
  }

  Future<void> _google() async {
    final result = await ref.read(authControllerProvider.notifier).signInWithGoogle();
    if (mounted && !result.ok) showToast(context, result.error!);
  }

  @override
  Widget build(BuildContext context) {
    final busy = ref.watch(authControllerProvider).busy;
    final role = ref.watch(_roleProvider);
    final district = ref.watch(_districtProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const TopBar('Create Account'),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 22, 16, 28),
          children: [
            const Text('How will you use NTIZA?',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            const Text('Choose your role — you can apply for more roles later.',
                style: TextStyle(fontSize: 16, height: 1.4, color: AppColors.muted)),
            const SizedBox(height: 18),
            for (final r in registerRoles) ...[
              RoleTile(
                title: r.$1.label,
                subtitle: r.$2,
                icon: r.$3,
                selected: role == r.$1,
                onTap: () => ref.read(_roleProvider.notifier).state = r.$1,
              ),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 8),
            LabeledField('Full name',
                hint: 'e.g. Uwase Esperance',
                icon: Icons.person_outline,
                controller: _name,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.name],
                validator: Validators.fullName),
            const SizedBox(height: 16),
            LabeledField('E-mail',
                hint: 'you@example.com',
                icon: Icons.mail_outline,
                controller: _email,
                keyboard: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                validator: Validators.email),
            const SizedBox(height: 16),
            LabeledField('Phone number (MoMo)',
                hint: '07X XXX XXXX',
                icon: Icons.smartphone_outlined,
                keyboard: TextInputType.phone,
                controller: _phone,
                textInputAction: TextInputAction.next,
                validator: Validators.phone),
            const SizedBox(height: 16),
            DistrictDropdown(
              value: district,
              onChanged: (v) => ref.read(_districtProvider.notifier).state = v,
            ),
            const SizedBox(height: 16),
            LabeledField('Password',
                hint: 'At least 8 characters',
                icon: Icons.shield_outlined,
                obscure: true,
                controller: _password,
                textInputAction: TextInputAction.next,
                validator: Validators.password),
            const Padding(
              padding: EdgeInsets.only(top: 6),
              child: Text('At least 8 characters with a letter and a number.',
                  style: TextStyle(fontSize: 13, color: AppColors.muted)),
            ),
            const SizedBox(height: 16),
            LabeledField('Confirm password',
                hint: 'Re-enter your password',
                icon: Icons.shield_outlined,
                obscure: true,
                controller: _confirm,
                textInputAction: TextInputAction.done,
                validator: (v) => Validators.confirmPassword(v, _password.text)),
            if (role.needsApproval) ...[
              const SizedBox(height: 14),
              const Text('Partner accounts are reviewed by the NTIZA team before you can log in.',
                  style: TextStyle(fontSize: 13.5, color: AppColors.muted)),
            ],
            const SizedBox(height: 22),
            PrimaryButton(busy ? 'Please wait…' : 'Continue',
                height: 54, onPressed: busy ? null : _submit),
            const SizedBox(height: 12),
            OutlineButtonX('Continue with Google',
                height: 54, onPressed: busy ? null : _google),
          ],
        ),
      ),
    );
  }
}

/// District picker shared by the sign-up and profile forms.
class DistrictDropdown extends StatelessWidget {
  const DistrictDropdown({super.key, required this.value, required this.onChanged});

  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('District',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.body)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: value,
            isExpanded: true,
            icon: const Icon(Icons.keyboard_arrow_down),
            validator: Validators.district,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: const InputDecoration(
              hintText: 'Select district',
              hintStyle: TextStyle(color: AppColors.faint),
              prefixIcon: Icon(Icons.location_on_outlined, color: AppColors.muted),
            ),
            items: [for (final d in districts) DropdownMenuItem(value: d, child: Text(d))],
            onChanged: onChanged,
          ),
        ],
      );
}

/// Selectable card for one role (used on sign-up and "complete profile").
class RoleTile extends StatelessWidget {
  const RoleTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => AppCard(
        onTap: onTap,
        color: selected ? AppColors.green50 : Colors.white,
        borderColor: selected ? AppColors.primary : AppColors.border,
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            IconTile(icon,
                size: 58,
                radius: 16,
                bg: selected ? AppColors.primary : AppColors.neutral,
                fg: selected ? Colors.white : AppColors.body),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 3),
                  Text(subtitle,
                      style: const TextStyle(fontSize: 13.5, height: 1.35, color: AppColors.muted)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? AppColors.primary : Colors.white,
                border: Border.all(
                    color: selected ? AppColors.primary : AppColors.faint, width: 1.6),
              ),
              child: selected ? const Icon(Icons.circle, size: 10, color: Colors.white) : null,
            ),
          ],
        ),
      );
}
