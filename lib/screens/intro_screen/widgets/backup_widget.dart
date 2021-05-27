import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../providers/google_sign_in_provider.dart';
import '../../../providers/retrieve_backup_provider.dart';

class BackupOrRestoreWidget extends ConsumerWidget {
  const BackupOrRestoreWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final _googleSignIn = watch(googleSignInProvider);
    return ProviderListener(
      provider: googleSignInProvider,
      onChange: (context, value) async {
        if (value is AsyncData<GoogleSignInAccount?>) {
          context
              .read(retrieveBackupProvider)
              .saveToDB(await value.data!.value!.authHeaders);
        } else if (value is AsyncError) {
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
      child: Container(
        color: Colors.deepPurple.shade400,
        child: _googleSignIn.data?.value != null
            ? const _CompletedWidget(
                msg:
                    '''Now we take backup periodically to change go to settings>backup''',
              )
            : const _SignInIntroWidget(),
      ),
    );
  }
}

class _CompletedWidget extends StatelessWidget {
  const _CompletedWidget({Key? key, required this.msg}) : super(key: key);
  final String msg;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(25.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const Icon(
            Icons.check_circle_outline,
            size: 100,
          ),
          const SizedBox(height: 10),
          Text(
            msg,
            style: const TextStyle(fontSize: 20),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SignInIntroWidget extends StatelessWidget {
  const _SignInIntroWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                  text:
                      '''Please sign in to start back-up or restore previous data.\n''',
                  style: TextStyle(fontSize: 20),
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
            primary: Colors.white,
            onPrimary: Colors.black,
            padding: EdgeInsets.zero.copyWith(right: 8),
          ),
          onPressed: () {
            context.read(googleSignInProvider.notifier).signIn();
          },
          label: const Text("Sign in with Google"),
        ),
      ],
    );
  }
}
