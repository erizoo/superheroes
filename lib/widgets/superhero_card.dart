import 'package:flutter/material.dart';

import '../blocs/main_bloc.dart';
import '../resources/superheroes_colors.dart';

class SuperheroCard extends StatelessWidget {
  final SuperheroInfo superheroInfo;
  final VoidCallback onTap;
  const SuperheroCard({
    Key? key,
    required this.superheroInfo,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 70,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
            color: SuperheroesColors.superheroCardBG,
            borderRadius: BorderRadius.circular(8)),
        child: Row(
          children: [
            Image.network(
              superheroInfo.imageUrl,
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
                      superheroInfo.name.toUpperCase(),
                      style: const TextStyle(
                          fontSize: 16,
                          color: SuperheroesColors.white,
                          fontWeight: FontWeight.w700),
                    ),
                    Text(
                      superheroInfo.realName,
                      style: const TextStyle(
                          fontSize: 14,
                          color: SuperheroesColors.white,
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