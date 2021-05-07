import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/google_sign_in.dart';
import '../../widgets/c_screen_title.dart';
import 'widgets/backup_options.dart';
import 'widgets/sign_in_screen.dart';

class BackupScreen extends ConsumerWidget {
  const BackupScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final googleSignIn = watch(googleSignInProvider);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            const Align(
              alignment: Alignment.centerLeft,
              child: CScreenTitle(title: "Backup"),
            ),
            Expanded(
              child: googleSignIn == null //
                  ? const SignInScreen()
                  : const BackupOptions(),
            ),
          ],
        ),
      ),
    );
  }
}
