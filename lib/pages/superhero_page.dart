import 'package:flutter/material.dart';
import 'package:superheroes/widgets/action_button.dart';

import '../resources/superheroes_colors.dart';

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
            const Expanded(child: SizedBox()),
            Center(
                child: Text(
              name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            )),
            const Expanded(child: SizedBox()),
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
