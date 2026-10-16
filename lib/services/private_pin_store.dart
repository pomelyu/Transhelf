import 'package:shared_preferences/shared_preferences.dart';

enum PinVerificationResult { correct, incorrect, limitReached, notConfigured }

class PrivatePinStore {
  PrivatePinStore(this._preferences);

  static const failedAttemptLimit = 10;
  static const pinKey = 'private_article_pin';
  static const failedAttemptsKey = 'private_pin_failed_attempts';

  final SharedPreferences? _preferences;
  String? _memoryPin;
  int _memoryFailedAttempts = 0;

  String? get pin => _preferences?.getString(pinKey) ?? _memoryPin;
  bool get isConfigured => pin != null;
  int get failedAttempts =>
      _preferences?.getInt(failedAttemptsKey) ?? _memoryFailedAttempts;

  Future<void> setPin(String value) async {
    if (!RegExp(r'^\d{4}$').hasMatch(value)) {
      throw ArgumentError.value(value, 'value', 'PIN must be four digits');
    }
    if (_preferences == null) {
      _memoryPin = value;
      _memoryFailedAttempts = 0;
      return;
    }
    await _preferences.setString(pinKey, value);
    await resetFailedAttempts();
  }

  Future<void> clearPin() async {
    _memoryPin = null;
    await _preferences?.remove(pinKey);
  }

  Future<PinVerificationResult> verify(String value) async {
    final savedPin = pin;
    if (savedPin == null) return PinVerificationResult.notConfigured;
    if (value == savedPin) {
      await resetFailedAttempts();
      return PinVerificationResult.correct;
    }
    final nextAttempts = failedAttempts + 1;
    if (_preferences == null) {
      _memoryFailedAttempts = nextAttempts;
    } else {
      await _preferences.setInt(failedAttemptsKey, nextAttempts);
    }
    return nextAttempts >= failedAttemptLimit
        ? PinVerificationResult.limitReached
        : PinVerificationResult.incorrect;
  }

  Future<void> resetFailedAttempts() async {
    _memoryFailedAttempts = 0;
    await _preferences?.setInt(failedAttemptsKey, 0);
  }
}
