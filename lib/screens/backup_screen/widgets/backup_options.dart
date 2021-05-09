import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/google_sign_in_provider.dart';

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
