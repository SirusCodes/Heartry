import 'dart:convert';
import 'package:flutter/material.dart';
import '../database/database.dart';
import '../image_builder/core/image_layer.dart';
import '../init_get_it.dart';

class SaveTemplateDialog extends StatefulWidget {
  final ImageLayer rootLayer;
  final VoidCallback onSaved;

  const SaveTemplateDialog({
    super.key,
    required this.rootLayer,
    required this.onSaved,
  });

  @override
  State<SaveTemplateDialog> createState() => _SaveTemplateDialogState();
}

class _SaveTemplateDialogState extends State<SaveTemplateDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Save Custom Template"),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(
          labelText: "Template Name",
          hintText: "e.g., Cool Blur Vignette",
        ),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () async {
            final name = _controller.text.trim();
            if (name.isNotEmpty) {
              final serialized = widget.rootLayer.toJson();
              if (serialized != null) {
                await locator<Database>().insertTemplate(
                  TemplateModel(
                    name: name,
                    data: json.encode(serialized),
                    isDefault: false,
                  ),
                );

                widget.onSaved();

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Template "$name" saved successfully!'),
                    ),
                  );
                }
              }
            }
          },
          child: const Text("Save"),
        ),
      ],
    );
  }
}
