import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/constants.dart';
import '../../../domain/entities/entities.dart';
import '../../../domain/validators.dart';
import '../../providers/providers.dart';
import '../../widgets/ui.dart';
import 'register_screen.dart';

final _roleProvider = StateProvider.autoDispose<Role>((ref) => Role.farmer);

final _districtProvider = StateProvider.autoDispose<String?>((ref) {
  final saved = ref.read(settingsControllerProvider).preferredDistrict;
  return districts.contains(saved) ? saved : null;
});

/// Last step of a Google sign-up: Google gives us an identity but no profile,
/// so the person picks a role and enters name, phone and district.
class CompleteProfileScreen extends ConsumerStatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  ConsumerState<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends ConsumerState<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final result = await ref.read(authControllerProvider.notifier).completeProfile(
          role: ref.read(_roleProvider),
          name: _name.text,
          phone: _phone.text,
          district: ref.read(_districtProvider) ?? '',
        );
    if (mounted && !result.ok) showToast(context, result.error!);
  }

  @override
  Widget build(BuildContext context) {
    final busy = ref.watch(authControllerProvider).busy;
    final role = ref.watch(_roleProvider);
    final district = ref.watch(_districtProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const TopBar('Complete Profile', back: false),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 22, 16, 28),
          children: [
            const Text('Almost there',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            const Text('Tell us how you will use NTIZA and how to reach you.',
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
                validator: Validators.fullName),
            const SizedBox(height: 16),
            LabeledField('Phone number (MoMo)',
                hint: '07X XXX XXXX',
                icon: Icons.smartphone_outlined,
                keyboard: TextInputType.phone,
                controller: _phone,
                textInputAction: TextInputAction.done,
                validator: Validators.phone),
            const SizedBox(height: 16),
            DistrictDropdown(
              value: district,
              onChanged: (v) => ref.read(_districtProvider.notifier).state = v,
            ),
            if (role.needsApproval) ...[
              const SizedBox(height: 14),
              const Text('Partner accounts are reviewed by the NTIZA team before you can use them.',
                  style: TextStyle(fontSize: 13.5, color: AppColors.muted)),
            ],
            const SizedBox(height: 22),
            PrimaryButton(busy ? 'Saving…' : 'Continue', height: 54, onPressed: busy ? null : _save),
            const SizedBox(height: 8),
            TextButton(
              onPressed: busy ? null : () => ref.read(authControllerProvider.notifier).signOut(),
              style: TextButton.styleFrom(minimumSize: const Size.fromHeight(48)),
              child: const Text('Use another account',
                  style: TextStyle(fontSize: 15, color: AppColors.primaryDark)),
            ),
          ],
        ),
      ),
    );
  }
}
