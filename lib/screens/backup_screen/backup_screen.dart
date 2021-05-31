import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../providers/google_sign_in_provider.dart';
import '../../widgets/c_screen_title.dart';
import 'widgets/backup_options.dart';
import 'widgets/sign_in_screen.dart';

final googleUserInfoProvider = ScopedProvider<GoogleSignInAccount>(null);

class BackupScreen extends ConsumerWidget {
  const BackupScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final googleSignIn = watch(googleSignInProvider);
    return ProviderListener(
      provider: googleSignInProvider,
      onChange: (context, value) {
        if (value is AsyncError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(value.error.toString()),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(8.0),
          ));
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: <Widget>[
              const Align(
                alignment: Alignment.centerLeft,
                child: CScreenTitle(title: "Backup"),
              ),
              Expanded(
                child: googleSignIn.data?.value == null
                    ? const SignInScreen()
                    : ProviderScope(
                        overrides: [
                          googleUserInfoProvider
                              .overrideWithValue(googleSignIn.data!.value!)
                        ],
                        child: const BackupOptions(),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
