import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/google_sign_in.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        RichText(
          textAlign: TextAlign.center,
          text: const TextSpan(
            children: <TextSpan>[
              TextSpan(
                text: "Please sign in to start back-up.\n",
                style: TextStyle(fontSize: 20, height: 3),
              ),
              TextSpan(text: "We will use your Google drive to save you data."),
            ],
          ),
        ),
        const SizedBox(height: 15),
        ElevatedButton.icon(
          icon: Image.asset(
            "assets/logos/google_signin_btn.png",
            height: 40,
            width: 40,
          ),
          style: ElevatedButton.styleFrom(
            primary: isDark ? const Color(0xFF4285F4) : Colors.white,
            padding: EdgeInsets.zero.copyWith(right: 8),
          ),
          onPressed: () {
            context.read(googleSignInProvider.notifier).signIn();
          },
          label: const Text(
            "Sign in with Google",
            style: TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }
}
