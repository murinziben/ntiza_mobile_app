import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/app_settings.dart';
import '../providers/dependencies.dart';

/// Holds the user's preferences and saves every change to SharedPreferences.
/// The initial state is read synchronously from disk, so the app starts with
/// the last saved settings.
class SettingsController extends Notifier<AppSettings> {
  @override
  AppSettings build() => ref.watch(settingsRepositoryProvider).load();

  Future<void> _update(AppSettings next) async {
    state = next;
    await ref.read(settingsRepositoryProvider).save(next);
  }

  Future<void> setTextScale(double value) => _update(state.copyWith(textScale: value));

  Future<void> setNotificationsEnabled(bool value) =>
      _update(state.copyWith(notificationsEnabled: value));

  Future<void> setPreferredDistrict(String district) =>
      _update(state.copyWith(preferredDistrict: district));

  /// Pass an empty string to forget the address.
  Future<void> setRememberedEmail(String email) =>
      _update(state.copyWith(rememberedEmail: email.trim()));

  Future<void> markOnboardingSeen() => _update(state.copyWith(onboardingSeen: true));
}

final settingsControllerProvider =
    NotifierProvider<SettingsController, AppSettings>(SettingsController.new);
