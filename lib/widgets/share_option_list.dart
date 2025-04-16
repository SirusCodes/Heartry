import 'package:flutter/material.dart';

class ShareOptionList extends StatelessWidget {
  const ShareOptionList({
    super.key,
    required this.onShareAsImage,
    required this.onShareAsText,
  });

  final VoidCallback onShareAsImage, onShareAsText;

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: [
        const SizedBox(height: 8),
        ListTile(
          title: const Text("Share as Text"),
          trailing: const Icon(Icons.text_fields),
          onTap: () => onShareAsText.call(),
        ),
        ListTile(
          title: const Text("Share as Image"),
          trailing: const Icon(Icons.image),
          onTap: () => onShareAsImage.call(),
        ),
      ],
    );
  }
}
