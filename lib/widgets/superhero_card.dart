import 'package:flutter/material.dart';

import '../resources/superheroes_colors.dart';

class SuperheroCard extends StatelessWidget {
  final String name, realName, imageUrl;
  final VoidCallback onTap;
  const SuperheroCard({
    Key? key,
    required this.name,
    required this.realName,
    required this.imageUrl,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 70,
        color: SuperheroesColors.superheroCardBG,
        child: Row(
          children: [
            Image.network(
              imageUrl,
              height: 70,
              width: 70,
              fit: BoxFit.cover,
            ),
            const SizedBox(
              width: 12,
            ),
            Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name.toUpperCase(),
                      style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w700),
                    ),
                    Text(
                      realName,
                      style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.w400),
                    ),
                  ],
                ))
          ],
        ),
      ),
    );
  }
}