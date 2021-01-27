import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:liquid_swipe/liquid_swipe.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../database/config.dart';
import '../../init_get_it.dart';
import '../../widgets/privacy_policies.dart';
import '../poems_screen/poems_screen.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({Key key}) : super(key: key);

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
        enableSlideIcon: _enableSlideIcon,
        slideIconWidget: const Icon(
          Icons.arrow_back_ios,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _NamePage extends StatefulWidget {
  const _NamePage({Key key}) : super(key: key);

  @override
  __NamePageState createState() => __NamePageState();
}

class __NamePageState extends State<_NamePage> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Container(
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
                ),
              ),
              const SizedBox(height: 35),
              TextFormField(
                autovalidateMode: AutovalidateMode.onUserInteraction,
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
                  hintText: "Darshan",
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
                      text: "Privacy Policies",
                      style: TextStyle(
                        color: Colors.deepPurple.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const PrivacyPolicies(),
                            ),
                          );
                        },
                    )
                  ],
                ),
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    _formKey.currentState.save();
                    Navigator.pushReplacement(
                      context,
                      CupertinoPageRoute(
                        builder: (_) => const PoemScreen(),
                      ),
                    );
                  }
                },
                child: const Text("Let's Goooooo...."),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfilePage extends StatelessWidget {
  const _ProfilePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.deepPurple.shade300,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const Spacer(),
          _profileWidget(),
          const SizedBox(height: 15),
          const Spacer(),
          _buttonsWidget(context)
        ],
      ),
    );
  }

  Padding _buttonsWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15.0, 0, 15.0, 15.0),
      child: Column(
        children: <Widget>[
          _buildDialogButton(
            context,
            onPressed: () async {
              final picker = ImagePicker();
              final pickedImage =
                  await picker.getImage(source: ImageSource.gallery);
              await _setImage(context, pickedImage);
              Navigator.pop(context);
            },
            icon: const Icon(Icons.photo_library),
            text: "Add from gallery",
          ),
          _buildDialogButton(
            context,
            onPressed: () async {
              final picker = ImagePicker();
              final pickedImage =
                  await picker.getImage(source: ImageSource.camera);
              await _setImage(context, pickedImage);
              Navigator.pop(context);
            },
            icon: const Icon(Icons.camera_alt),
            text: "Capture from camera",
          ),
        ],
      ),
    );
  }

  Column _profileWidget() {
    return Column(
      children: <Widget>[
        const Text(
          "Let's update your profile...",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 50,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 15),
        Consumer(
          builder: (context, watch, child) {
            final _imagePath = watch(configProvider).profile;
            return CircleAvatar(
              maxRadius: 100,
              minRadius: 80,
              backgroundImage:
                  _imagePath != null ? FileImage(File(_imagePath)) : null,
              child: _imagePath == null
                  ? const Icon(
                      Icons.person_add,
                      size: 100,
                    )
                  : null,
            );
          },
        ),
      ],
    );
  }

  ElevatedButton _buildDialogButton(
    BuildContext context, {
    @required VoidCallback onPressed,
    @required Icon icon,
    @required String text,
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
    if (pickedImage == null) return;

    imageCache.clear();

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
  const _WelcomePage({Key key}) : super(key: key);

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
            ),
          ),
          const SizedBox(height: 95),
          CircleAvatar(
            minRadius: 80,
            maxRadius: 100,
            backgroundColor: Colors.white,
            child: Image.asset("assets/launcher_icon.png"),
          ),
          const SizedBox(height: 35),
          const Text(
            "Heart + Poetry = Heartry",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 25,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 80),
          const Text(
            "A PRIVACY FOCUSED APP FOR THE WRITERS",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
