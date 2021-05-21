
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:heartry/database/database.dart';
import 'package:heartry/providers/shared_prefs_provider.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heartry/screens/poems_screen/poems_screen.dart';
import 'package:heartry/widgets/privacy_statement.dart';

import '../../../init_get_it.dart';

class NameWidget extends StatefulWidget {
  const NameWidget({Key? key}) : super(key: key);

  @override
  _NameWidgetState createState() => _NameWidgetState();
}

class _NameWidgetState extends State<NameWidget> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final TextEditingController _nameController = TextEditingController();

  bool _showButton = true;
  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(primarySwatch: Colors.deepPurple),
      child: Container(
        color: Colors.deepPurple.shade100,
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Spacer(),
                const Text(
                  "Write your name",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 50,
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.w600,
                    fontFamily: "Caveat",
                  ),
                ),
                const SizedBox(height: 35),
                TextFormField(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  controller: _nameController,
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return "Please enter your name";

                    return null;
                  },
                  onSaved: (newValue) {
                    context.read(sharedPrefsProvider).name = newValue;
                  },
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    hintText: "Your Name",
                    labelText: "Name",
                    border: OutlineInputBorder(),
                  ),
                ),
                const Spacer(),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(
                      color: Colors.deepPurple.shade400,
                      fontSize: 10,
                    ),
                    children: <InlineSpan>[
                      const TextSpan(text: "By continuing you accept our "),
                      TextSpan(
                        text: "Privacy Statement",
                        style: TextStyle(
                          color: Colors.deepPurple.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.push<void>(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const PrivacyStatement(),
                              ),
                            );
                          },
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                _showButton
                    ? ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      setState(() {
                        _showButton = false;
                      });
                      await _addDetailsInDB();
                      Navigator.pushReplacement<void, void>(
                        context,
                        CupertinoPageRoute(
                          builder: (_) => const PoemScreen(),
                        ),
                      );
                    }
                  },
                  child: const Text("Let's Go!"),
                )
                    : const Center(
                  child: CircularProgressIndicator(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _addDetailsInDB() async {
    final _db = locator<Database>();

    await _insertPoem(
      _db,
      title: "Welcome",
      poem: "Hey ${_nameController.text}, thanks for using Heartry. 🤗",
    );

    await _insertPoem(
      _db,
      title: "Writing",
      poem: "Everything that you ✍ will be auto saved.",
    );

    await _insertPoem(
      _db,
      title: "Tool bar",
      poem: """
Press and hold this card to access toolbar. 😊
You can access Reader Mode, Share and Edit from it.""",
    );

    await _insertPoem(
      _db,
      title: "Reader Mode",
      poem: """
Sometimes keyboards can be annoying.
Press and hold on card, and click on eye button.
Now that keyboard will never disturb you. 😇""",
    );

    await _insertPoem(
      _db,
      title: "Share",
      poem: """
You can share poem in 2 ways.
1. As Text 🆎 (For Messages)
2. As Photos 📷 (For Stories)""",
    );

    await _insertPoem(
      _db,
      title: "Share as Image",
      poem: "It will open a new screen, you can select each image and add "
          "them to your story one by one. ❤",
    );

    await _insertPoem(
      _db,
      title: "About",
      poem: "You can know more about us by going in About in Settings. 🙈",
    );
  }

  Future<void> _insertPoem(
      Database db, {
        required String title,
        required String poem,
      }) async {
    await db.insertPoem(
      PoemModel(
        title: title,
        poem: poem,
      ),
    );
  }
}