import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';

/// Stores [AppSettings] in SharedPreferences so they survive a restart.
class PrefsSettingsRepository implements SettingsRepository {
  PrefsSettingsRepository(this._prefs);

  final SharedPreferences _prefs;

  static const keyTextScale = 'text_scale';
  static const keyNotifications = 'notifications_enabled';
  static const keyDistrict = 'preferred_district';
  static const keyEmail = 'remembered_email';
  static const keyOnboarding = 'onboarding_seen';

  @override
  AppSettings load() => AppSettings(
        textScale: _prefs.getDouble(keyTextScale) ?? 1.0,
        notificationsEnabled: _prefs.getBool(keyNotifications) ?? true,
        preferredDistrict: _prefs.getString(keyDistrict) ?? '',
        rememberedEmail: _prefs.getString(keyEmail) ?? '',
        onboardingSeen: _prefs.getBool(keyOnboarding) ?? false,
      );

  @override
  Future<void> save(AppSettings s) async {
    await _prefs.setDouble(keyTextScale, s.textScale);
    await _prefs.setBool(keyNotifications, s.notificationsEnabled);
    await _prefs.setString(keyDistrict, s.preferredDistrict);
    await _prefs.setString(keyEmail, s.rememberedEmail);
    await _prefs.setBool(keyOnboarding, s.onboardingSeen);
  }
}
