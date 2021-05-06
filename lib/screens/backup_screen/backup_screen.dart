import 'package:flutter/material.dart';
import 'package:heartry/providers/google_sign_in.dart';
import 'package:heartry/widgets/c_screen_title.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class BackupScreen extends ConsumerWidget {
  const BackupScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final googleSignIn = watch(googleSignInProvider);
    return Scaffold(
      body: SafeArea(
        child: ListView(
          children: <Widget>[
            const CScreenTitle(title: "Backup"),
            googleSignIn == null ? const SignInScreen() : const BackupOptions(),
          ],
        ),
      ),
    );
  }
}

class SignInScreen extends StatelessWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          context.read(googleSignInProvider.notifier).signIn();
        },
        child: const Text("Login"),
      ),
    );
  }
}

class BackupOptions extends StatelessWidget {
  const BackupOptions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          context.read(googleSignInProvider.notifier).signOut();
        },
        child: const Text("Logout"),
      ),
    );
  }
}
