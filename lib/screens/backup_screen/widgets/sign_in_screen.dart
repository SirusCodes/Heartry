import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/google_sign_in_provider.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: Theme.of(context).textTheme.bodyText2,
              children: const <TextSpan>[
                TextSpan(
                  text: "Please sign in to start back-up.\n",
                  style: TextStyle(fontSize: 20, height: 3),
                ),
                TextSpan(text: '''
We will use your Google drive to save your data.
But rest assured, we won't be able to access any other data.
'''),
              ],
            ),
          ),
        ),
        ElevatedButton.icon(
          icon: Padding(
            padding: const EdgeInsets.all(2.0),
            child: Image.asset(
              "assets/logos/google_signin_btn.png",
              height: 35,
              width: 35,
            ),
          ),
          style: ElevatedButton.styleFrom(
            primary: isDark ? const Color(0xFF4285F4) : Colors.white,
            padding: EdgeInsets.zero.copyWith(right: 8),
          ),
          onPressed: () {
            context.read(googleSignInProvider.notifier).signIn();
          },
          label: Text(
            "Sign in with Google",
            style: Theme.of(context).textTheme.button,
          ),
        ),
      ],
    );
  }
}
