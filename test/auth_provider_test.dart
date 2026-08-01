// ignore_for_file: depend_on_referenced_packages

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';
import 'package:heartry/providers/auth_provider.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockGoogleSignInPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements GoogleSignInPlatform {
  @override
  Stream<AuthenticationEvent>? get authenticationEvents => const Stream.empty();

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #initWithParams ||
        invocation.memberName == #init) {
      return Future<void>.value();
    }
    if (invocation.memberName == #attemptLightweightAuthentication) {
      return Future<Object?>.value(null);
    }
    return super.noSuchMethod(invocation);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    GoogleSignInPlatform.instance = MockGoogleSignInPlatform();
  });

  group('AuthProvider Tests', () {
    test('Initial state of AuthProvider is null when not signed in', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = await container.read(authProvider.future);
      expect(state, isNull);
    });

    test(
      'AuthProvider state evaluates to AsyncData when unauthenticated',
      () async {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        await container.read(authProvider.future);
        final asyncValue = container.read(authProvider);

        expect(asyncValue.hasValue, isTrue);
        expect(asyncValue.value, isNull);
      },
    );
  });
}
