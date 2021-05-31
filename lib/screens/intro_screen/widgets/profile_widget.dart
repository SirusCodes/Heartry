import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../database/config.dart';

class ProfileWidget extends StatelessWidget {
  const ProfileWidget({Key? key}) : super(key: key);

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

    context
        .read(configProvider)
        .setProfile(pickedImage.path, await pickedImage.readAsBytes());
  }
}
