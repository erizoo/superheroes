import 'package:flutter/material.dart';
import 'package:superheroes/widgets/action_button.dart';

import '../resources/superheroes_colors.dart';

class InfoWithButton extends StatelessWidget {
  final String title, subtitle, buttonText, assetImage;
  final double imageHeight, imageWidth, imageTopPadding;
  const InfoWithButton(
      {Key? key,
        required this.title,
        required this.subtitle,
        required this.buttonText,
        required this.assetImage,
        required this.imageHeight,
        required this.imageWidth,
        required this.imageTopPadding})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          // ignore: prefer_const_literals_to_create_immutables
          children: [
            Stack(
              children: [
                Container(
                  height: 108,
                  width: 108,
                  decoration: const BoxDecoration(
                    color: SuperheroesColors.blue,
                    shape: BoxShape.circle,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: imageTopPadding),
                  child: Image.asset(
                    assetImage,
                    height: imageHeight,
                    width: imageWidth,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 32,
                  color: Colors.white,
                  fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 20),
            Text(
              subtitle.toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            ActionButton(onTap: () {}, text: buttonText)
          ],
        ));
  }
}