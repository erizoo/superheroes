// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:superheroes/blocs/main_bloc.dart';
import 'package:superheroes/pages/superhero_page.dart';
import 'package:superheroes/resources/superheroes_colors.dart';
import 'package:superheroes/resources/superheroes_images.dart';

import '../widgets/action_button.dart';
import '../widgets/info_with_button.dart';
import '../widgets/superhero_card.dart';

class MainPage extends StatefulWidget {
  MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final MainBloc bloc = MainBloc();

  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: bloc,
      child: Scaffold(
        appBar: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle.light,
          backgroundColor: Colors.transparent,
          elevation: 0.0,
        ),
        backgroundColor: SuperheroesColors.background,
        body: SafeArea(
          child: MainPageContent(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    bloc.dispose();
    super.dispose();
  }
}

class MainPageContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final MainBloc bloc = Provider.of<MainBloc>(context);
    return Stack(
      children: [
        MainPageStateWidget(),
        Align(
          alignment: Alignment.bottomCenter,
          child: GestureDetector(
            onTap: () {
              bloc.nextState();
            },
            child: Text(
              "Next state".toUpperCase(),
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
          ),
        )
      ],
    );
  }
}

class MainPageStateWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final MainBloc bloc = Provider.of<MainBloc>(context);
    return StreamBuilder<MainPageState>(
      stream: bloc.observeMainPageState(),
      builder: (context, snapshot) {
        if (!snapshot.hasData == 0 || snapshot.data == null) {
          return SizedBox();
        }
        final MainPageState state = snapshot.data!;
        switch (state) {
          case MainPageState.loading:
            return const LoadingIndicator();
          case MainPageState.minSymbols:
            return const MinSymbolsWidget();
          case MainPageState.noFavorite:
            return InfoWithButton(
                title: "No favorites yet",
                subtitle: "Search and add",
                buttonText: "Search",
                assetImage: SuperheroesImages.ironman,
                imageHeight: 119,
                imageWidth: 108,
                imageTopPadding: 9);
          case MainPageState.favorites:
            return Favorites();
          case MainPageState.searchResult:
            return SearchResults();
          case MainPageState.nothingFound:
            return InfoWithButton(
                title: "Nothing found",
                subtitle: "Search for something else",
                buttonText: "Search",
                assetImage: SuperheroesImages.hulk,
                imageHeight: 112,
                imageWidth: 84,
                imageTopPadding: 16);
          case MainPageState.loadingError:
            return InfoWithButton(
                title: "Error happened",
                subtitle: "Please, try again",
                buttonText: "Retry",
                assetImage: SuperheroesImages.superman,
                imageHeight: 106,
                imageWidth: 126,
                imageTopPadding: 22);
          default:
            return Center(
                child: Text(
                  state.toString(),
                  style: const TextStyle(color: Colors.white),
                ));
        }
      },
    );
  }
}

class Favorites extends StatelessWidget {
  const Favorites({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 90),
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Your favorites",
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SuperheroCard(
            name: "Batman",
            realName: "Bruce Wayne",
            imageUrl: SuperheroesImages.batmanUrl,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => SuperheroPage(
                  name: "Batman",
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 8,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SuperheroCard(
            name: "Ironman",
            realName: "Tony Stark",
            imageUrl: SuperheroesImages.ironmanUrl,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => SuperheroPage(
                  name: "Ironman",
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class SearchResults extends StatelessWidget {
  const SearchResults({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      // ignore: prefer_const_literals_to_create_immutables
      children: [
        SizedBox(height: 90),
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Search results",
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SuperheroCard(
            name: "Batman",
            realName: "Bruce Wayne",
            imageUrl: SuperheroesImages.batmanUrl,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => SuperheroPage(
                  name: "Batman",
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 8,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SuperheroCard(
            name: "Venom",
            realName: "Eddie Brock",
            imageUrl: SuperheroesImages.venomUrl,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => SuperheroPage(
                  name: "Venom",
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class NoFavoriteWidget extends StatelessWidget {
  const NoFavoriteWidget({
    Key? key,
  }) : super(key: key);

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
              padding: EdgeInsets.only(top: 10),
              child: Image.asset(
                SuperheroesImages.ironman,
                height: 119,
                width: 108,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          "No favorites yet",
          textAlign: TextAlign.center,
          style: const TextStyle(
              fontSize: 32, color: Colors.white, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 20),
        Text(
          "Search and add".toUpperCase(),
          textAlign: TextAlign.center,
          style: const TextStyle(
              fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 30),
        ActionButton(onTap: () {}, text: "Search".toUpperCase())
      ],
    ));
  }
}

class MinSymbolsWidget extends StatelessWidget {
  const MinSymbolsWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 100.0),
      child: Align(
          alignment: Alignment.topCenter,
          child: Text(
            "Enter at least 3 symbols",
            style: TextStyle(color: Colors.white, fontSize: 20),
          )),
    );
  }
}

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: EdgeInsets.only(top: 110),
        child: CircularProgressIndicator(
          color: SuperheroesColors.blue,
          strokeWidth: 4,
        ),
      ),
    );
  }
}
