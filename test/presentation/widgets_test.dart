import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ntiza/domain/entities/entities.dart';
import 'package:ntiza/presentation/providers/dependencies.dart';
import 'package:ntiza/presentation/screens/auth/login_screen.dart';
import 'package:ntiza/presentation/screens/common/settings_screen.dart';
import 'package:ntiza/presentation/widgets/ui.dart';

import '../helpers/fakes.dart';

/// Wraps [child] with in-memory fakes. A plain [ThemeData] is used on purpose:
/// the real theme downloads fonts, which a test must not do.
Widget _app(Widget child, {FakeAuthRepository? auth, FakeSettingsRepository? settings}) =>
    ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(auth ?? FakeAuthRepository()),
        settingsRepositoryProvider.overrideWithValue(settings ?? FakeSettingsRepository()),
      ],
      child: MaterialApp(home: child),
    );

void main() {
  group('LoginScreen', () {
    testWidgets('shows validation errors for empty fields and does not sign in', (tester) async {
      final auth = FakeAuthRepository();
      await tester.pumpWidget(_app(const LoginScreen(), auth: auth));

      await tester.ensureVisible(find.text('Log In'));
      await tester.tap(find.text('Log In'));
      await tester.pump();

      expect(find.text('Enter your e-mail address.'), findsOneWidget);
      expect(find.text('Enter your password.'), findsOneWidget);
      expect(auth.calls, isEmpty);
    });

    testWidgets('rejects a malformed e-mail', (tester) async {
      await tester.pumpWidget(_app(const LoginScreen()));

      await tester.enterText(find.byType(TextFormField).first, 'not-an-email');
      await tester.ensureVisible(find.text('Log In'));
      await tester.tap(find.text('Log In'));
      await tester.pump();

      expect(find.text('Enter a valid e-mail, e.g. name@example.com.'), findsOneWidget);
    });

    testWidgets('signs in with valid input', (tester) async {
      final auth = FakeAuthRepository();
      await tester.pumpWidget(_app(const LoginScreen(), auth: auth));

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'jean@example.rw');
      await tester.enterText(fields.at(1), 'secret123');
      await tester.ensureVisible(find.text('Log In'));
      await tester.tap(find.text('Log In'));
      await tester.pumpAndSettle();

      expect(auth.calls, contains('signIn:jean@example.rw'));
    });

    testWidgets('password visibility toggle reveals the text', (tester) async {
      await tester.pumpWidget(_app(const LoginScreen()));

      EditableText password() =>
          tester.widget<EditableText>(find.byType(EditableText).at(1));
      expect(password().obscureText, isTrue);

      await tester.tap(find.byTooltip('Show password'));
      await tester.pump();
      expect(password().obscureText, isFalse);
    });
  });

  group('SettingsScreen', () {
    testWidgets('toggling notifications is saved to the settings repository', (tester) async {
      final settings = FakeSettingsRepository();
      await tester.pumpWidget(_app(const SettingsScreen(), settings: settings));

      expect(settings.stored.notificationsEnabled, isTrue);
      await tester.tap(find.byType(Switch));
      await tester.pump();

      expect(settings.stored.notificationsEnabled, isFalse);
      expect(settings.saves, 1);
    });

    testWidgets('choosing a text size is saved', (tester) async {
      final settings = FakeSettingsRepository();
      await tester.pumpWidget(_app(const SettingsScreen(), settings: settings));

      await tester.tap(find.text('Large'));
      await tester.pump();

      expect(settings.stored.textScale, 1.15);
    });

    testWidgets('restores previously saved preferences', (tester) async {
      final settings = FakeSettingsRepository()
        ..stored = const AppSettings(notificationsEnabled: false, textScale: 0.9);
      await tester.pumpWidget(_app(const SettingsScreen(), settings: settings));

      expect(tester.widget<Switch>(find.byType(Switch)).value, isFalse);
    });
  });

  group('shared widgets', () {
    testWidgets('StatusChip shows its label', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: StatusChip('Confirmed'))));
      expect(find.text('Confirmed'), findsOneWidget);
    });

    testWidgets('primary and outline buttons meet the 48dp minimum tap size', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Column(children: [
            PrimaryButton('Go', height: 30, onPressed: () {}),
            OutlineButtonX('Back', height: 30, onPressed: () {}),
            SoftButton('Book', onPressed: () {}),
          ]),
        ),
      ));

      expect(tester.getSize(find.byType(SoftButton)).height, greaterThanOrEqualTo(48));
      expect(tester.getSize(find.byType(FilledButton)).height, greaterThanOrEqualTo(48));
      expect(tester.getSize(find.byType(OutlinedButton)).height, greaterThanOrEqualTo(48));
    });

    testWidgets('ChipRow reports the tapped label', (tester) async {
      String? picked;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ChipRow(labels: const ['All', 'Crops'], selected: 'All', onSelected: (v) => picked = v),
        ),
      ));

      await tester.tap(find.text('Crops'));
      expect(picked, 'Crops');
    });

    testWidgets('layout does not overflow on a small landscape screen', (tester) async {
      tester.view.physicalSize = const Size(640, 360);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(_app(const LoginScreen()));
      expect(tester.takeException(), isNull);
    });
  });
}
