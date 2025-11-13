import 'package:flutter/material.dart';

import '../../../database/database.dart';
import '../../../utils/theme.dart';

extension on ThemeData {
  PoemCardTheme get poemCardTheme => extension<PoemCardTheme>()!;
  SelectedPoemCardTheme get selectedPoemCardTheme =>
      extension<SelectedPoemCardTheme>()!;
}

class PoemCard extends StatelessWidget {
  const PoemCard({
    super.key,
    required this.model,
    required this.onPressed,
    this.onLongPress,
    this.isSelected = false,
  });

  final PoemModel model;
  final bool isSelected;
  final VoidCallback onPressed;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final poemCardTheme = themeData.poemCardTheme;
    final selectedPoemCardTheme = themeData.selectedPoemCardTheme;

    return GestureDetector(
      onTap: onPressed,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: isSelected
              ? selectedPoemCardTheme.backgroundColor
              : poemCardTheme.backgroundColor,
          border: isSelected
              ? Border.all(color: selectedPoemCardTheme.borderColor)
              : Border.all(color: poemCardTheme.borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (model.title.isNotEmpty)
              Text(
                model.title,
                textAlign: TextAlign.start,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: isSelected
                      ? selectedPoemCardTheme.textColor
                      : poemCardTheme.textColor,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 5),
            if (model.poem.isNotEmpty)
              Text(
                model.poem,
                overflow: TextOverflow.ellipsis,
                maxLines: 10,
                textAlign: TextAlign.start,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: isSelected
                      ? selectedPoemCardTheme.textColor
                      : poemCardTheme.textColor,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
