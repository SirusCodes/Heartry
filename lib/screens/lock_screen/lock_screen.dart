import 'package:flutter/material.dart';
import 'package:heartry/screens/poems_screen/poems_screen.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../utils/lock_helper.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  @override
  void initState() {
    super.initState();
    _validateUser(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Spacer(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Authenticate to proceed',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
          ),
          Spacer(),
          GestureDetector(
            child: Icon(Symbols.fingerprint, size: 80),
            onTap: () => _validateUser(context),
          ),
          Spacer(flex: 3),
        ],
      ),
    );
  }

  Future<void> _validateUser(BuildContext context) async {
    final navigator = Navigator.of(context);

    final isValidated = await LockHelper.validateLock(
      context,
      reason: 'Please authenticate to unlock the app',
    );

    if (isValidated) {
      navigator.pushReplacement(
        MaterialPageRoute(builder: (_) => PoemScreen()),
      );
    }
  }
}
