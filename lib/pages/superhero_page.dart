// ignore_for_file: prefer_const_constructors

import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'package:superheroes/blocs/superhero_bloc.dart';
import 'package:superheroes/model/biography.dart';
import 'package:superheroes/model/powerstats.dart';
import 'package:superheroes/model/superhero.dart';
import 'package:superheroes/resources/superheroes_icons.dart';
import 'package:superheroes/resources/superheroes_images.dart';
import 'package:superheroes/resources/superhoroes_colors.dart';
import 'package:superheroes/widgets/alignment_widget.dart';
import 'package:superheroes/widgets/info_with_button.dart';

class SuperheroPage extends StatefulWidget {
  final http.Client? client;
  final String id;

  const SuperheroPage({
    Key? key,
    this.client,
    required this.id,
  }) : super(key: key);

  @override
  State<SuperheroPage> createState() => _SuperheroPageState();
}

class _SuperheroPageState extends State<SuperheroPage> {
  late SuperheroBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = SuperheroBloc(client: widget.client, id: widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: bloc,
      child: Scaffold(
        backgroundColor: SuperheroesColors.background,
        body: SuperheroStateWidget(),
      ),
    );
  }

  @override
  void dispose() {
    bloc.dispose();
    super.dispose();
  }
}

class SuperheroStateWidget extends StatelessWidget {
  const SuperheroStateWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<SuperheroBloc>(context, listen: false);
    return StreamBuilder<SuperheroPageState>(
      stream: bloc.observeSuperheroPageState(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }
        final SuperheroPageState? state = snapshot.data;
        switch (state) {
          case SuperheroPageState.loading:
            return AppBar(
              backgroundColor: SuperheroesColors.background,
              flexibleSpace: LoadingIndicator(),
            );
          case SuperheroPageState.error:
            return AppBar(
              backgroundColor: SuperheroesColors.background,
              flexibleSpace: InfoWithButton(
                  title: "Error happened",
                  subtitle: "Please, try again",
                  buttonText: "Retry",
                  assetImage: SuperheroesImages.superman,
                  imageHeight: 106,
                  imageWidth: 126,
                  imageTopPadding: 22,
                  onTap: bloc.retry),
            );
          case null:
          case SuperheroPageState.loaded:
        }
        return SuperheroContentPage();
      },
    );
  }
}

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: EdgeInsets.only(top: 139),
        child: CircularProgressIndicator(
          color: SuperheroesColors.blue,
          strokeWidth: 4,
        ),
      ),
    );
  }
}

class SuperheroContentPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<SuperheroBloc>(context, listen: false);
    return StreamBuilder<Superhero>(
      stream: bloc.observeSuperhero(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot == null) {
          return const SizedBox.shrink();
        }
        final superhero = snapshot.data!;
        return CustomScrollView(
          slivers: [
            SuperheroAppBar(superhero: superhero),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  SizedBox(
                    height: 30,
                  ),
                  if (superhero.powerstats.isNotNull())
                    PowerstatsWidget(powerstats: superhero.powerstats),
                  BiographyWidget(biography: superhero.biography)
                ],
              ),
            )
          ],
        );
      },
    );
  }
}

class BiographyWidget extends StatelessWidget {
  final Biography biography;
  const BiographyWidget({
    Key? key,
    required this.biography,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(left: 16, right: 16),
        child: BiographyCard(biography: biography));
  }
}

class PowerstatsWidget extends StatelessWidget {
  final Powerstats powerstats;
  const PowerstatsWidget({
    Key? key,
    required this.powerstats,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Center(
        child: Text(
          "Powerstats".toUpperCase(),
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.white,
            fontSize: 18,
          ),
        ),
      ),
      SizedBox(height: 24),
      Row(
        children: [
          SizedBox(width: 16),
          Expanded(
            child: Center(
              child: PowerstatWidget(
                  name: "Intelligence", value: powerstats.intelligencePercent),
            ),
          ),
          Expanded(
            child: Center(
              child: PowerstatWidget(
                  name: "Strength", value: powerstats.strengthPercent),
            ),
          ),
          Expanded(
            child: Center(
              child: PowerstatWidget(
                  name: "Speed", value: powerstats.speedPercent),
            ),
          ),
          SizedBox(width: 16),
        ],
      ),
      SizedBox(height: 20),
      Row(
        children: [
          SizedBox(width: 16),
          Expanded(
            child: Center(
              child: PowerstatWidget(
                  name: "Durability", value: powerstats.durabilityPercent),
            ),
          ),
          Expanded(
            child: Center(
              child: PowerstatWidget(
                  name: "Power", value: powerstats.powerPercent),
            ),
          ),
          Expanded(
            child: Center(
              child: PowerstatWidget(
                  name: "Combat", value: powerstats.combatPercent),
            ),
          ),
          SizedBox(width: 16),
        ],
      ),
      SizedBox(height: 30),
    ]);
  }
}

class PowerstatWidget extends StatelessWidget {
  final String name;
  final double value;

  const PowerstatWidget({
    Key? key,
    required this.name,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        ArcWidget(value: value, color: calculateColorByValue()),
        Padding(
          padding: const EdgeInsets.only(top: 17),
          child: Text(
            "${(value * 100).toInt()}",
            style: TextStyle(
                color: calculateColorByValue(),
                fontWeight: FontWeight.w700,
                fontSize: 18),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 44),
          child: Text(
            name.toUpperCase(),
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
          ),
        )
      ],
    );
  }

  Color calculateColorByValue() {
    if (value <= 0.5) {
      return Color.lerp(Colors.red, Colors.orangeAccent, value / 0.5)!;
    }
    return Color.lerp(Colors.orangeAccent, Colors.green, (value - 0.5) / 0.5)!;
  }
}

class ArcWidget extends StatelessWidget {
  final double value;
  final Color color;
  const ArcWidget({
    Key? key,
    required this.value,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: ArcCustonmPainter(value: value, color: color),
      size: Size(66, 33),
    );
  }
}

class ArcCustonmPainter extends CustomPainter {
  final double value;
  final Color color;
  ArcCustonmPainter({
    required this.value,
    required this.color,
  });
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height * 2);
    final backgroundPaint = Paint()
      ..color = Colors.white24
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 6;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 6;
    canvas.drawArc(rect, pi, pi, false, backgroundPaint);
    canvas.drawArc(rect, pi, pi * value, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is ArcCustonmPainter) {
      return oldDelegate.value != value;
    }
    return true;
  }
}

class SuperheroAppBar extends StatelessWidget {
  const SuperheroAppBar({
    Key? key,
    required this.superhero,
  }) : super(key: key);

  final Superhero superhero;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      stretch: true,
      pinned: true,
      floating: true,
      expandedHeight: 348,
      backgroundColor: SuperheroesColors.background,
      actions: [
        FavoriteButton(),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          superhero.name,
          style: TextStyle(
              fontWeight: FontWeight.w800, fontSize: 22, color: Colors.white),
        ),
        centerTitle: true,
        background: CachedNetworkImage(
          placeholder: (context, url) => ColoredBox(
            color: SuperheroesColors.superheroCardBG,
          ),
          errorWidget: (context, url, error) => Container(
            color: SuperheroesColors.superheroCardBG,
            alignment: Alignment.center,
            child: Image.asset(
              SuperheroesImages.unknownBig,
              width: 85,
              height: 264,
            ),
          ),
          imageUrl: superhero.image.url,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class FavoriteButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<SuperheroBloc>(context, listen: false);
    return StreamBuilder<bool>(
      stream: bloc.observeIsFavorite(),
      initialData: false,
      builder: (context, snapshot) {
        final favorite =
            !snapshot.hasData || snapshot.data == null || snapshot.data!;
        return GestureDetector(
          onTap: () =>
              favorite ? bloc.removeFromFavorites() : bloc.addToFavorite(),
          child: Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            child: Image.asset(
              favorite
                  ? SuperheroesIcons.starFilled
                  : SuperheroesIcons.starEmpty,
              width: 32,
              height: 32,
            ),
          ),
        );
      },
    );
  }
}

class BiographyCard extends StatelessWidget {
  final Biography biography;

  const BiographyCard({
    Key? key,
    required this.biography,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: SuperheroesColors.superheroCardBG,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          Container(
            padding: EdgeInsets.only(left: 16, right: 16),
            child: Column(
              children: [
                SizedBox(height: 16),
                Text(
                  "Bio".toUpperCase(),
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: Colors.white),
                ),
                // SizedBox(height: 8),
                bioAliasHeader("Full name"),
                SizedBox(height: 4),
                bioAliasText(biography.fullName),
                SizedBox(height: 20),
                bioAliasHeader("Aliases"),
                SizedBox(height: 4),
                bioAliasText(biography.aliases.join(", ")),
                SizedBox(height: 20),
                bioAliasHeader("Place of birth"),
                SizedBox(height: 4),
                bioAliasText(biography.placeOfBirth),
                SizedBox(height: 24)
              ],
            ),
          ),
          Row(
            children: [
              const Expanded(child: SizedBox()),
              Container(
                clipBehavior: Clip.antiAlias,
                decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                        bottomLeft: const Radius.circular(20))),
                height: 70,
                width: 24,
                child: biography.alignmentInfo != null
                    ? AlignmentWidget(alignmentInfo: biography.alignmentInfo!)
                    : const SizedBox(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Row bioAliasHeader(final String name) {
    return Row(
      children: [
        Text(
          name.toUpperCase(),
          textAlign: TextAlign.left,
          style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 12,
              color: Color(0xFF999999)),
        ),
        Expanded(child: SizedBox()),
      ],
    );
  }

  Row bioAliasText(final String text) {
    return Row(
      children: [
        Flexible(
          child: Text(
            text,
            textAlign: TextAlign.left,
            style: const TextStyle(
                fontWeight: FontWeight.w400, fontSize: 16, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
