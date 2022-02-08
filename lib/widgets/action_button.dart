import 'package:flutter/material.dart';

import '../resources/superheroes_colors.dart';

class ActionButton extends StatelessWidget {
  final VoidCallback onTap;
  final String text;

  const ActionButton({Key? key, required this.text, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: const BoxDecoration(
          color: SuperheroesColors.blue,
          borderRadius: BorderRadius.all(
            Radius.circular(8),
          ),
        ),
        child: Text(
          text.toUpperCase(),
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}
