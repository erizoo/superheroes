// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:superheroes/blocs/main_bloc.dart';
import 'package:superheroes/pages/superhero_page.dart';
import 'package:superheroes/resources/superheroes_colors.dart';
import 'package:superheroes/resources/superheroes_images.dart';
import 'package:superheroes/widgets/action_button.dart';
import 'package:superheroes/widgets/info_with_button.dart';
import 'package:superheroes/widgets/superhero_card.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

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
    final MainBloc bloc = Provider.of<MainBloc>(context, listen: false);
    return Stack(
      children: [
        MainPageStateWidget(),
        RemoveButton(),
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 12),
          child: SearchWidget(),
        ),
      ],
    );
  }
}

class SearchWidget extends StatefulWidget {
  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  final TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance?.addPostFrameCallback((timeStamp) {
      final MainBloc bloc = Provider.of<MainBloc>(context, listen: false);
      controller.addListener(() => bloc.updateText(controller.text));
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: (value) {
        setState(() {});
      },
      textCapitalization: TextCapitalization.words,
      textInputAction: TextInputAction.search,
      cursorColor: SuperheroesColors.white,
      controller: controller,
      style: TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: 20,
        color: SuperheroesColors.white,
      ),
      decoration: InputDecoration(
        suffix: GestureDetector(
          onTap: () {
            controller.clear();
            setState(() {});
          },
          child: Icon(
            Icons.clear,
            color: SuperheroesColors.white,
          ),
        ),
        filled: true,
        fillColor: SuperheroesColors.indigo75,
        isDense: true,
        prefixIcon: Icon(
          Icons.search,
          color: SuperheroesColors.searchIcon,
          size: 24,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: SuperheroesColors.white,
            width: 2,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: dinamycBorder(),
        ),
      ),
    );
  }

  BorderSide dinamycBorder() {
    return controller.text.isEmpty
        ? BorderSide(color: Colors.white24)
        : BorderSide(color: Colors.white, width: 2);
  }
}

class RemoveButton extends StatelessWidget {
  const RemoveButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final MainBloc bloc = Provider.of<MainBloc>(context, listen: false);
    return StreamBuilder<MainPageState>(
      stream: bloc.observeMainPageState(),
      builder: (context, snapshot) {
        return bloc.stateSubject.value == MainPageState.favorites ||
            bloc.stateSubject.value == MainPageState.noFavorites
            ? Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: ActionButton(
                onTap: () => bloc.removeFavorite(), text: "Remove"),
          ),
        )
            : SizedBox.shrink();
      },
    );
  }
}

class MainPageStateWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final MainBloc bloc = Provider.of<MainBloc>(context, listen: false);
    return StreamBuilder<MainPageState>(
      stream: bloc.observeMainPageState(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return const SizedBox();
        }
        final MainPageState state = snapshot.data!;
        switch (state) {
          case MainPageState.loading:
            return const LoadingIndicator();
          case MainPageState.minSymbols:
            return const MinSymbols();
          case MainPageState.noFavorites:
            return InfoWithButton(
              title: "No favorites yet",
              subtitle: "Search and add",
              buttonText: "Search",
              assetImage: SuperheroesImages.ironman,
              imageHeight: 119,
              imageWidth: 108,
              imageTopPadding: 9,
            );
          case MainPageState.favorites:
            return SuperheroesList(
                title: "Your favorites",
                stream: bloc.obsereFavoriteSuperheroes());
          case MainPageState.searchResults:
            return SuperheroesList(
                title: "Search resulst",
                stream: bloc.obsereSearchedSuperheroes());
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

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Align(
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

class MinSymbols extends StatelessWidget {
  const MinSymbols({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(top: 110),
        child: const Text(
          "Enter at least 3 symbols",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: SuperheroesColors.white,
          ),
        ),
      ),
    );
  }
}

class SuperheroesList extends StatelessWidget {
  final String title;
  final Stream<List<SuperheroInfo>> stream;

  const SuperheroesList({
    Key? key,
    required this.title,
    required this.stream,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<SuperheroInfo>>(
        stream: stream,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot == null) {
            return SizedBox.shrink();
          }
          final List<SuperheroInfo> superheroes = snapshot.data!;
          return ListView.separated(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            itemCount: superheroes.length + 1,
            itemBuilder: (BuildContext context, int index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(
                      left: 16, right: 16, top: 90, bottom: 12),
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 24,
                      color: SuperheroesColors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                );
              }
              final SuperheroInfo item = superheroes[index - 1];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SuperheroCard(
                  superheroInfo: item,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => SuperheroPage(
                        name: item.name,
                      ),
                    ),
                  ),
                ),
              );
            },
            separatorBuilder: (BuildContext context, int index) {
              return SizedBox(
                height: 8,
              );
            },
          );
        });
  }
}
