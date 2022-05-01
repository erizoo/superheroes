import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:superheroes/blocs/main_bloc.dart';
import 'package:superheroes/resources/superhoroes_colors.dart';

class ActionButton extends StatelessWidget {
  final VoidCallback onTap;
  final String text;
  const ActionButton({
    Key? key,
    required this.onTap,
    required this.text,
  }) : super(key: key);

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
          style: const TextStyle(
            fontSize: 14,
            color: SuperheroesColors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
