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
import 'package:url_launcher/url_launcher_string.dart';

import '../../database/config.dart';
import '../../database/database.dart';
import '../../init_get_it.dart';
import '../../providers/auth_provider.dart';
import '../../providers/backup_restore_manager_provider.dart';
import '../../utils/theme.dart';
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
    const pages = [
      _WelcomePage(),
      _ProfilePage(),
      _NamePage(),
    ];

    return Scaffold(
      body: Theme(
        data: getLightTheme(heartryLightColorScheme),
        child: Consumer(
          builder: (_, ref, child) {
            ref.listen(
              authProvider,
              (prev, next) => _onUserAuthenticated(prev, next, ref),
            );
            ref.listen(restoreManagerProvider, _onRestoreResult);

            return child!;
          },
          child: LiquidSwipe(
            pages: pages,
            enableLoop: false,
            onPageChangeCallback: (activePageIndex) {
              setState(() {
                _enableSlideIcon = activePageIndex != pages.length - 1;
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
        ),
      ),
    );
  }

  Future<void> _onUserAuthenticated(
    AsyncAccount? previous,
    AsyncAccount next,
    WidgetRef ref,
  ) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    if (next.asData?.valueOrNull != null) {
      final name = next.value!.displayName ?? "User";
      _saveName(name);
      final backupRestoreManager = ref.read(backupRestoreManagerProvider);

      if (await backupRestoreManager.hasBackup()) {
        _showRestoreOptionDialog(ref);
      } else {
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text("Could not find backup")),
        );
        await _addDetailsInDB(name);
        navigator.pushReplacement<void, void>(
          CupertinoPageRoute(
            builder: (_) => const PoemScreen(),
          ),
        );
      }
      return;
    }

    if (next is AsyncError) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text(next.error.toString())),
      );
      return;
    }

    scaffoldMessenger.showSnackBar(
      const SnackBar(content: Text("Authentication failed")),
    );
  }

  _showRestoreOptionDialog(WidgetRef ref) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Restore from backup?"),
        content: const Text("We found a backup of your poems from Google Drive."
            " Do you want to restore it?"),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("No"),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(restoreManagerProvider.notifier).restore();
            },
            child: const Text("Yes"),
          ),
        ],
      ),
    );
  }

  void _onRestoreResult(BackupRestoreState? previous, BackupRestoreState next) {
    if (next == BackupRestoreState.restoring) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          title: Text("Restoring in progress..."),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 16),
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text("Please don't close the app"),
            ],
          ),
        ),
      );
    } else if (next == BackupRestoreState.success) {
      Navigator.of(context).pop();
      Navigator.of(context).pushReplacement(
        CupertinoPageRoute(builder: (_) => const PoemScreen()),
      );
    } else if (next == BackupRestoreState.error) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Restore failed, try again.")),
      );
    }
  }
}

class _NamePage extends ConsumerStatefulWidget {
  const _NamePage({Key? key}) : super(key: key);

  @override
  _NamePageState createState() => _NamePageState();
}

class _NamePageState extends ConsumerState<_NamePage> {
  final TextEditingController _nameController = TextEditingController();

  bool showingDialog = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.deepPurple.shade100,
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
              decoration: InputDecoration(
                hintText: "Your Name",
                labelText: "Name",
                border: const OutlineInputBorder(),
                suffixIcon: ValueListenableBuilder(
                  valueListenable: _nameController,
                  builder: (context, value, child) => IconButton(
                    color: Colors.deepPurple,
                    onPressed: value.text.isNotEmpty //
                        ? _onNameFeildSubmitted
                        : null,
                    icon: const Icon(Icons.chevron_right_rounded),
                  ),
                ),
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
            ElevatedButton(
              onPressed: () {
                ref.read(authProvider.notifier).signIn();
              },
              child: const Text("Continue with Google"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onNameFeildSubmitted() async {
    final navigator = Navigator.of(context);
    await _addDetailsInDB(_nameController.text);
    _saveName(_nameController.text);
    navigator.pushReplacement<void, void>(
      CupertinoPageRoute(
        builder: (_) => const PoemScreen(),
      ),
    );
  }
}

void _saveName(String name) {
  final config = locator<Config>();
  config.name = name;
}

Future<void> _addDetailsInDB(String name) async {
  final db = locator<Database>();

  StringBuffer buffer = StringBuffer();

  buffer.writeln("Hey $name, thanks for using Heartry. 🤗");
  buffer.writeln();
  buffer.writeln("Everything that you ✍ will be auto saved.");
  buffer.writeln();
  buffer.writeln("""Press and hold this card to access toolbar. 😊
You can access Reader Mode, Share and Edit from it.""");
  buffer.writeln();
  buffer.writeln("""**Reader Mode**
Sometimes keyboards can be annoying.
Press and hold on card, and click on eye button.
Now that keyboard will never disturb you. 😇""");
  buffer.writeln();
  buffer.writeln("""**Share**
You can share poem in 2 ways.
1. As Text 🆎 (For Messages)
2. As Photos 📷 (For Stories)""");

  await db.insertPoem(PoemModel(
    title: "Welcome!!🎉",
    poem: buffer.toString(),
  ));
}

class _ProfilePage extends ConsumerWidget {
  const _ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAndroid = Theme.of(context).platform == TargetPlatform.android;

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
              builder: (context, ref, child) {
                final imagePath = ref
                    .watch(configProvider)
                    .whenOrNull(data: (data) => data.profile);
                return CircleAvatar(
                  maxRadius: 100,
                  minRadius: 80,
                  backgroundImage: imagePath != null //
                      ? FileImage(File(imagePath))
                      : null,
                  child: isAndroid
                      ? FutureBuilder(
                          future: _retriveImage(ref, context),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              return imagePath == null
                                  ? const Icon(Icons.person, size: 100)
                                  : const SizedBox.shrink();
                            }
                            return const CircularProgressIndicator();
                          },
                        )
                      : imagePath == null
                          ? const Icon(Icons.person, size: 100)
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
                    onPressed: () =>
                        _updateImage(ref, context, ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    text: "Add from gallery",
                  ),
                  _buildDialogButton(
                    context,
                    onPressed: () =>
                        _updateImage(ref, context, ImageSource.camera),
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

  Future<void> _retriveImage(WidgetRef ref, BuildContext context) async {
    final config = ref.read(configProvider.notifier);
    final retrievedImage = await ImagePicker().retrieveLostData();

    if (retrievedImage.isEmpty) return;

    final image = retrievedImage.file;
    if (image == null) return;

    config.profile = await _saveImageInAppStorage(image);
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

  Future<void> _updateImage(
      WidgetRef ref, BuildContext context, ImageSource source) async {
    final config = ref.read(configProvider.notifier);
    final picker = ImagePicker();
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      final pickedImage = await picker.pickImage(
        source: source,
        requestFullMetadata: false,
      );
      if (pickedImage == null) return;

      config.profile = await _saveImageInAppStorage(pickedImage);
    } on PlatformException {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text("Permission denied")),
      );
    }
  }

  Future<String> _saveImageInAppStorage(XFile pickedImage) async {
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
