import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

class LockHelper {
  static Future<bool> validateLock(
    BuildContext context, {
    required String reason,
    bool persistAcrossBackgrounding = false,
  }) async {
    final auth = LocalAuthentication();
    try {
      final didAuthenticate = await auth.authenticate(
        localizedReason: reason,
        persistAcrossBackgrounding: persistAcrossBackgrounding,
      );
      return didAuthenticate;
    } on LocalAuthException catch (e) {
      if (!context.mounted) return false;

      final (String? title, String? message) = switch (e.code) {
        LocalAuthExceptionCode.authInProgress => (
          "Authentication in Progress",
          "An authentication process is already in progress."
              " Please wait for it to complete.",
        ),
        LocalAuthExceptionCode.uiUnavailable => (
          "UI Unavailable",
          "The authentication UI is not available at this moment."
              " Please try again later.",
        ),
        LocalAuthExceptionCode.userCanceled => (null, null),
        LocalAuthExceptionCode.timeout => (
          "Authentication Timeout",
          "The authentication request timed out. Please try again.",
        ),
        LocalAuthExceptionCode.systemCanceled => (
          "Authentication Canceled",
          "The authentication was canceled by the system.",
        ),
        LocalAuthExceptionCode.noCredentialsSet => (
          "No Credentials Set",
          "No device credentials are set. Please set up a PIN, pattern,"
              " or password in your device settings.",
        ),
        LocalAuthExceptionCode.noBiometricsEnrolled => (
          "No Biometrics Enrolled",
          "No biometric authentication is enrolled. Please set up fingerprint"
              " or face recognition in your device settings.",
        ),
        LocalAuthExceptionCode.noBiometricHardware => (
          "Biometric Hardware Not Available",
          "Your device does not support biometric authentication.",
        ),
        LocalAuthExceptionCode.biometricHardwareTemporarilyUnavailable => (
          "Biometric Hardware Unavailable",
          "Biometric authentication is temporarily unavailable."
              " Please try again later.",
        ),
        LocalAuthExceptionCode.temporaryLockout => (
          "Temporary Lockout",
          "Too many failed authentication attempts."
              " Please try again in a few seconds.",
        ),
        LocalAuthExceptionCode.biometricLockout => (
          "Biometric Lockout",
          "Too many failed biometric attempts. Please use your device PIN,"
              " pattern, or password to unlock and try again.",
        ),
        LocalAuthExceptionCode.userRequestedFallback => (null, null),
        LocalAuthExceptionCode.deviceError => (
          "Device Error",
          "A device error occurred during authentication. Please try again.",
        ),
        LocalAuthExceptionCode.unknownError => (
          "Unknown Error",
          "An unknown error occurred during authentication. Please try again.",
        ),
      };

      // User intentionally canceled, no need to show error dialog
      if (title == null || message == null) return false;

      await _showErrorDialog(context, title, message);
      return false;
    }
  }

  static Future<void> _showErrorDialog(
    BuildContext context,
    String title,
    String message,
  ) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}
