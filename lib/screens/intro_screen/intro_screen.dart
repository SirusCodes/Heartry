import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:liquid_swipe/liquid_swipe.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../database/config.dart';
import '../../database/database.dart';
import '../../init_get_it.dart';
import '../../providers/shared_prefs_provider.dart';
import '../../widgets/privacy_statement.dart';
import '../poems_screen/poems_screen.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({Key? key}) : super(key: key);

  @override
  _IntroScreenState createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  bool _enableSlideIcon = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LiquidSwipe(
        pages: const [
          _WelcomePage(),
          _ProfilePage(),
          _NamePage(),
        ],
        enableLoop: false,
        onPageChangeCallback: (activePageIndex) {
          setState(() {
            _enableSlideIcon = activePageIndex != 2;
          });
        },
        positionSlideIcon: .5,
        ignoreUserGestureWhileAnimating: true,
        slideIconWidget: _enableSlideIcon
            ? const Icon(
                Icons.chevron_left_rounded,
                color: Colors.white,
                size: 40,
              )
            : null,
      ),
    );
  }
}

class _NamePage extends StatefulWidget {
  const _NamePage({Key? key}) : super(key: key);

  @override
  __NamePageState createState() => __NamePageState();
}

class __NamePageState extends State<_NamePage> {
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

class _ProfilePage extends StatelessWidget {
  const _ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.deepPurple.shade300,
      child: Center(
        child: Column(
          children: <Widget>[
            const Spacer(),
            const Text(
              "Let's update your profile...",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 50,
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontFamily: "Caveat",
              ),
            ),
            const SizedBox(height: 45),
            Consumer(
              builder: (context, watch, child) {
                final _imagePath = watch(configProvider).profile;
                return CircleAvatar(
                  maxRadius: 100,
                  minRadius: 80,
                  backgroundColor: Colors.deepPurple,
                  backgroundImage:
                      _imagePath != null ? FileImage(File(_imagePath)) : null,
                  child: _imagePath == null
                      ? const Icon(
                          Icons.person,
                          size: 100,
                          color: Colors.white,
                        )
                      : null,
                );
              },
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                children: <Widget>[
                  _buildDialogButton(
                    context,
                    onPressed: () async {
                      final picker = ImagePicker();
                      PickedFile? pickedImage;
                      try {
                        pickedImage =
                            await picker.getImage(source: ImageSource.gallery);
                      } on PlatformException {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Permission denied"),
                          ),
                        );
                      }

                      if (pickedImage == null) return;

                      await _setImage(context, pickedImage);
                    },
                    icon: const Icon(Icons.photo_library),
                    text: "Add from gallery",
                  ),
                  _buildDialogButton(
                    context,
                    onPressed: () async {
                      final picker = ImagePicker();
                      PickedFile? pickedImage;
                      try {
                        pickedImage =
                            await picker.getImage(source: ImageSource.camera);
                      } on PlatformException {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Permission denied"),
                          ),
                        );
                      }
                      if (pickedImage == null) return;

                      await _setImage(context, pickedImage);
                    },
                    icon: const Icon(Icons.camera_alt),
                    text: "Capture from camera",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  ElevatedButton _buildDialogButton(
    BuildContext context, {
    required VoidCallback onPressed,
    required Icon icon,
    required String text,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Row(
        children: <Widget>[
          icon,
          const Spacer(),
          Text(text),
          const Spacer(),
        ],
      ),
    );
  }

  Future<void> _setImage(BuildContext context, PickedFile pickedImage) async {
    imageCache!.clear();

    final directory = await getApplicationDocumentsDirectory();
    final file = p.basename(pickedImage.path);

    final imageSaved = p.join(directory.path, file);
    final image = await File(imageSaved).writeAsBytes(
      await pickedImage.readAsBytes(),
    );

    context.read(configProvider).profile = image.path;
  }
}

class _WelcomePage extends StatelessWidget {
  const _WelcomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.deepPurple.shade500,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text(
            "Welcome!",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 50,
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontFamily: "Caveat",
            ),
          ),
          const SizedBox(height: 100),
          CircleAvatar(
            minRadius: 80,
            maxRadius: 100,
            backgroundColor: Colors.white,
            child: Image.asset("assets/launcher_icon.png"),
          ),
          const SizedBox(height: 50),
          const Text(
            "Heart + Poetry = Heartry",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 25,
              color: Colors.white,
              fontFamily: "Caveat",
            ),
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }
}
