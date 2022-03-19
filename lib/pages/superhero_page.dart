// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:superheroes/resources/superhoroes_colors.dart';
import 'package:superheroes/widgets/action_button.dart';

class SuperheroPage extends StatelessWidget {
  final String name;

  const SuperheroPage({Key? key, required this.name}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SuperheroesColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: SizedBox()),
            Center(
                child: Text(
              name,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: SuperheroesColors.white,
              ),
            )),
            Expanded(child: SizedBox()),
            Align(
                alignment: Alignment.bottomCenter,
                child: ActionButton(
                    onTap: () => Navigator.of(context).pop(), text: "Back"))
          ],
        ),
      ),
    );
  }
}
