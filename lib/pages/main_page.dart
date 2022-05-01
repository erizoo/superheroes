// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'package:superheroes/blocs/main_bloc.dart';
import 'package:superheroes/pages/superhero_page.dart';
import 'package:superheroes/resources/superheroes_images.dart';
import 'package:superheroes/resources/superhoroes_colors.dart';
import 'package:superheroes/widgets/action_button.dart';
import 'package:superheroes/widgets/info_with_button.dart';
import 'package:superheroes/widgets/superhero_card.dart';

class MainPage extends StatefulWidget {
  final http.Client? client;
  const MainPage({
    Key? key,
    this.client,
  }) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late MainBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = MainBloc(client: widget.client);
  }

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
    return Stack(
      children: [
        MainPageStateWidget(),
        // RemoveButton(),
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
      controller.addListener(() {
        bloc.updateText(controller.text);
        setState(() {});
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final MainBloc bloc = Provider.of<MainBloc>(context, listen: false);
    return TextField(
      focusNode: bloc.searchFocusNode,
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
          onTap: () => controller.clear(),
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

// class RemoveButton extends StatelessWidget {
//   const RemoveButton({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final MainBloc bloc = Provider.of<MainBloc>(context, listen: false);
//     return StreamBuilder<MainPageState>(
//       stream: bloc.observeMainPageState(),
//       builder: (context, snapshot) {
//         return bloc.stateSubject.value == MainPageState.favorites ||
//                 bloc.stateSubject.value == MainPageState.noFavorites
//             ? Align(
//                 alignment: Alignment.bottomCenter,
//                 child: Padding(
//                   padding: const EdgeInsets.only(bottom: 16),
//                   child: ActionButton(
//                       onTap: () => bloc.removeFavorite(), text: "Remove"),
//                 ),
//               )
//             : SizedBox.shrink();
//       },
//     );
//   }
// }

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
              onTap: () => bloc.searchFocusNode.requestFocus(),
            );
          case MainPageState.favorites:
            return SuperheroesList(
                title: "Your favorites",
                stream: bloc.obsereFavoriteSuperheroes(),
                state: state);
          case MainPageState.searchResults:
            return SuperheroesList(
                title: "Search resulst",
                stream: bloc.obsereSearchedSuperheroes(),
                state: state);
          case MainPageState.nothingFound:
            return InfoWithButton(
              title: "Nothing found",
              subtitle: "Search for something else",
              buttonText: "Search",
              assetImage: SuperheroesImages.hulk,
              imageHeight: 112,
              imageWidth: 84,
              imageTopPadding: 16,
              onTap: () => bloc.searchFocusNode.requestFocus(),
            );
          case MainPageState.loadingError:
            return InfoWithButton(
                title: "Error happened",
                subtitle: "Please, try again",
                buttonText: "Retry",
                assetImage: SuperheroesImages.superman,
                imageHeight: 106,
                imageWidth: 126,
                imageTopPadding: 22,
                onTap: bloc.retry);
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
  final MainPageState state;

  const SuperheroesList({
    Key? key,
    required this.title,
    required this.stream,
    required this.state,
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
                return ListTitleWidget(title: title);
              }
              final SuperheroInfo item = superheroes[index - 1];
              return ListTile(
                superhero: item,
                ableToSwipe: state == MainPageState.favorites,
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

class ListTile extends StatelessWidget {
  final SuperheroInfo superhero;
  final bool ableToSwipe;

  const ListTile({
    Key? key,
    required this.superhero,
    required this.ableToSwipe,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final MainBloc bloc = Provider.of<MainBloc>(context, listen: false);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ableToSwipe
          ? Dismissible(
              key: ValueKey(superhero.id),
              child: SuperheroCard(
                superheroInfo: superhero,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => SuperheroPage(
                      id: superhero.id,
                    ),
                  ),
                ),
              ),
              background: DismissBackground(
                dismissAlignment: Alignment.centerLeft,
                textAlign: TextAlign.left,
              ),
              secondaryBackground: DismissBackground(
                dismissAlignment: Alignment.centerRight,
                textAlign: TextAlign.right,
              ),
              onDismissed: (_) => bloc.removeFromFavorites(superhero.id),
              // direction: !ableToSwipe
              //     ? DismissDirection.none
              //     : DismissDirection.horizontal,
            )
          : SuperheroCard(
              superheroInfo: superhero,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => SuperheroPage(
                    id: superhero.id,
                  ),
                ),
              ),
            ),
    );
  }
}

class DismissBackground extends StatelessWidget {
  final Alignment dismissAlignment;
  final TextAlign textAlign;
  const DismissBackground({
    Key? key,
    required this.dismissAlignment,
    required this.textAlign,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: SuperheroesColors.red,
      ),
      height: 70,
      alignment: dismissAlignment,
      child: Text(
        "Remove\nfrom\nfavorites".toUpperCase(),
        textAlign: textAlign,
        style: TextStyle(
          fontSize: 12,
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class ListTitleWidget extends StatelessWidget {
  const ListTitleWidget({
    Key? key,
    required this.title,
  }) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 90, bottom: 12),
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
}
