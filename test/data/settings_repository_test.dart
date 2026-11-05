import 'package:flutter_test/flutter_test.dart';
import 'package:ntiza/data/repositories/prefs_settings_repository.dart';
import 'package:ntiza/domain/entities/app_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('defaults when nothing has been saved', () async {
    SharedPreferences.setMockInitialValues({});
    final repo = PrefsSettingsRepository(await SharedPreferences.getInstance());
    final s = repo.load();
    expect(s.textScale, 1.0);
    expect(s.notificationsEnabled, isTrue);
    expect(s.preferredDistrict, isEmpty);
    expect(s.rememberedEmail, isEmpty);
    expect(s.onboardingSeen, isFalse);
  });

  test('saved preferences are restored after a restart', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await PrefsSettingsRepository(prefs).save(const AppSettings(
      textScale: 1.15,
      notificationsEnabled: false,
      preferredDistrict: 'Huye',
      rememberedEmail: 'esperance@example.com',
      onboardingSeen: true,
    ));

    // A new repository over the same storage simulates relaunching the app.
    final restored = PrefsSettingsRepository(prefs).load();
    expect(restored.textScale, 1.15);
    expect(restored.notificationsEnabled, isFalse);
    expect(restored.preferredDistrict, 'Huye');
    expect(restored.rememberedEmail, 'esperance@example.com');
    expect(restored.onboardingSeen, isTrue);
  });

  test('copyWith changes only the given fields', () {
    const base = AppSettings(preferredDistrict: 'Huye');
    final next = base.copyWith(textScale: 0.9);
    expect(next.textScale, 0.9);
    expect(next.preferredDistrict, 'Huye');
  });
}
