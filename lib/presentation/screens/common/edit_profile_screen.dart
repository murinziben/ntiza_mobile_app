import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/constants.dart';
import '../../../domain/validators.dart';
import '../../providers/providers.dart';
import '../../widgets/ui.dart';

/// District picked while editing (`null` until the profile has loaded).
final _districtProvider = StateProvider.autoDispose<String?>((ref) => null);

/// Lets a signed-in user change name, phone and district. E-mail is shown
/// read-only because it identifies the Firebase account.
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _phone;

  @override
  void initState() {
    super.initState();
    // Start from the stored profile (the stream is normally already loaded).
    final me = ref.read(profileProvider).valueOrNull;
    _name = TextEditingController(text: me?.name ?? '');
    _phone = TextEditingController(text: me?.phone ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final me = ref.read(profileProvider).valueOrNull;
    final result = await ref.read(authControllerProvider.notifier).updateProfile(
          name: _name.text,
          phone: _phone.text,
          district: ref.read(_districtProvider) ?? me?.district ?? '',
        );
    if (!mounted) return;
    if (result.ok) {
      showToast(context, 'Profile updated.');
      context.pop();
    } else {
      showToast(context, result.error!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final me = ref.watch(profileProvider).valueOrNull;
    final busy = ref.watch(authControllerProvider).busy;
    final chosen = ref.watch(_districtProvider) ?? me?.district;
    final district = districts.contains(chosen) ? chosen : null;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const TopBar('Personal Information'),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
          children: [
            Center(
              child: InitialsAvatar(initialsOf(me?.name ?? 'N'),
                  size: 84, bg: AppColors.primary, fg: Colors.white),
            ),
            const SizedBox(height: 22),
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
            const Text('District',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.body)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              // Re-created when the profile arrives so the stored district shows.
              key: ValueKey('district-${district ?? 'none'}'),
              initialValue: district,
              isExpanded: true,
              validator: Validators.district,
              decoration: const InputDecoration(
                hintText: 'Select district',
                prefixIcon: Icon(Icons.location_on_outlined, color: AppColors.muted),
              ),
              items: [for (final d in districts) DropdownMenuItem(value: d, child: Text(d))],
              onChanged: (v) => ref.read(_districtProvider.notifier).state = v,
            ),
            const SizedBox(height: 16),
            AppCard(
              color: AppColors.neutral,
              borderColor: AppColors.neutral,
              child: Row(
                children: [
                  const Icon(Icons.mail_outline, color: AppColors.muted),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(me?.email.isNotEmpty == true ? me!.email : 'No e-mail on file',
                        style: const TextStyle(fontSize: 15, color: AppColors.body)),
                  ),
                  const Text('Read-only',
                      style: TextStyle(fontSize: 12.5, color: AppColors.muted)),
                ],
              ),
            ),
            const SizedBox(height: 22),
            PrimaryButton(busy ? 'Saving…' : 'Save Changes',
                height: 54, onPressed: busy ? null : _save),
          ],
        ),
      ),
    );
  }
}
