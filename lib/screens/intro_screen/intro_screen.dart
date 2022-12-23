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
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../database/config.dart';
import '../../database/database.dart';
import '../../init_get_it.dart';
import '../poems_screen/poems_screen.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({Key? key}) : super(key: key);

  @override
  State<IntroScreen> createState() => _IntroScreenState();
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
                    locator<Config>().name = newValue;
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
                            launchUrlString(
                              "https://heartry.darshanrander.com/policy",
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
                          final navigator = Navigator.of(context);
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            setState(() {
                              _showButton = false;
                            });
                            await _addDetailsInDB();
                            navigator.pushReplacement<void, void>(
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
    final db = locator<Database>();

    await _insertPoem(
      db,
      title: "Welcome",
      poem: "Hey ${_nameController.text}, thanks for using Heartry. 🤗",
    );

    await _insertPoem(
      db,
      title: "Writing",
      poem: "Everything that you ✍ will be auto saved.",
    );

    await _insertPoem(
      db,
      title: "Tool bar",
      poem: """
Press and hold this card to access toolbar. 😊
You can access Reader Mode, Share and Edit from it.""",
    );

    await _insertPoem(
      db,
      title: "Reader Mode",
      poem: """
Sometimes keyboards can be annoying.
Press and hold on card, and click on eye button.
Now that keyboard will never disturb you. 😇""",
    );

    await _insertPoem(
      db,
      title: "Share",
      poem: """
You can share poem in 2 ways.
1. As Text 🆎 (For Messages)
2. As Photos 📷 (For Stories)""",
    );

    await _insertPoem(
      db,
      title: "Share as Image",
      poem: "It will open a new screen, you can select each image and add "
          "them to your story one by one. ❤",
    );

    await _insertPoem(
      db,
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
                final imagePath = watch(configProvider).profile;
                return CircleAvatar(
                  maxRadius: 100,
                  minRadius: 80,
                  backgroundColor: Colors.deepPurple,
                  backgroundImage:
                      imagePath != null ? FileImage(File(imagePath)) : null,
                  child: imagePath == null
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
                    onPressed: () => _updateImage(context, ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    text: "Add from gallery",
                  ),
                  _buildDialogButton(
                    context,
                    onPressed: () => _updateImage(context, ImageSource.camera),
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

  Future<void> _updateImage(BuildContext context, ImageSource source) async {
    final navigator = Navigator.of(context);
    final config = context.read(configProvider.notifier);
    final picker = ImagePicker();
    try {
      final pickedImage = await picker.getImage(source: source);
      if (pickedImage == null) return;

      config.profile = await _saveImageInAppStorage(pickedImage);
      navigator.pop();
    } on PlatformException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Permission denied")),
      );
    }
  }

  Future<String> _saveImageInAppStorage(PickedFile pickedImage) async {
    imageCache.clear();

    final directory = await getApplicationDocumentsDirectory();
    final file = p.basename(pickedImage.path);

    final imageSaved = p.join(directory.path, file);
    final image = await File(imageSaved).writeAsBytes(
      await pickedImage.readAsBytes(),
    );

    return image.path;
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
