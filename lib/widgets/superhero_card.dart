// ignore_for_file: prefer_const_constructors

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:superheroes/blocs/main_bloc.dart';
import 'package:superheroes/resources/superheroes_images.dart';
import 'package:superheroes/resources/superhoroes_colors.dart';

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
            Container(
              width: 70,
              height: 70,
              color: Colors.white24,
              child: CachedNetworkImage(
                imageUrl: superheroInfo.imageUrl,
                height: 70,
                width: 70,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) {
                  return Center(
                    child: Image.asset(
                      SuperheroesImages.unknown,
                      width: 20,
                      height: 62,
                      fit: BoxFit.cover,
                    ),
                  );
                },
                progressIndicatorBuilder: (context, url, progress) {
                  return Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: progress.progress == null
                          ? CircularProgressIndicator(
                              color: SuperheroesColors.blue,
                            )
                          : CircularProgressIndicator(
                              value: progress.progress,
                              color: SuperheroesColors.blue,
                            ),
                    ),
                  );
                },
              ),
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
