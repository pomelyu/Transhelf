import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transhelf/services/private_pin_store.dart';

void main() {
  test(
    'persists failed attempts, resets after success, and clears the PIN',
    () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final store = PrivatePinStore(preferences);

      await store.setPin('4826');
      expect(store.isConfigured, isTrue);
      expect(await store.verify('0000'), PinVerificationResult.incorrect);
      expect(PrivatePinStore(preferences).failedAttempts, 1);
      expect(await store.verify('4826'), PinVerificationResult.correct);
      expect(store.failedAttempts, 0);
      expect(await store.verify('0000'), PinVerificationResult.incorrect);
      expect(await store.verify('0000'), PinVerificationResult.incorrect);
      expect(store.failedAttempts, 2);
      await store.clearPin();
      expect(store.isConfigured, isFalse);
      expect(store.failedAttempts, 2);
    },
  );

  test('reports the configured attempt limit', () {
    expect(PrivatePinStore.failedAttemptLimit, 10);
  });
}
