import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:http/http.dart' as http;

import '../resources/superheroes_images.dart';

class MainBloc {
  static const minSymbols = 3;

  final stateSubject = BehaviorSubject<MainPageState>();
  final searchedSuperheroesSubject = BehaviorSubject<List<SuperheroInfo>>();
  final favoriteSuperheroesSubject =
      BehaviorSubject<List<SuperheroInfo>>.seeded(SuperheroInfo.mocked);
  final currentTextSubject = BehaviorSubject<String>.seeded("");

  StreamSubscription? textSubscription;
  StreamSubscription? searchSubscription;

  Stream<MainPageState> observeMainPageState() => stateSubject;

  MainBloc() {
    stateSubject.add(MainPageState.noFavorites);

    textSubscription =
        Rx.combineLatest2<String, List<SuperheroInfo>, MainPageStateInfo>(
                currentTextSubject
                    .distinct()
                    .debounceTime(const Duration(milliseconds: 500)),
                favoriteSuperheroesSubject,
                (searchText, favorites) =>
                    MainPageStateInfo(searchText, favorites.isNotEmpty))
            .listen((value) {
      searchSubscription?.cancel();
      if (value.searchText.isEmpty) {
        if (value.haveFavorites) {
          stateSubject.add(MainPageState.favorites);
        } else {
          stateSubject.add(MainPageState.noFavorites);
        }
      } else if (value.searchText.length < minSymbols) {
        stateSubject.add(MainPageState.minSymbols);
      } else {
        searchForSuperheroes(value.searchText);
      }
    });
  }

  void removeFavorite() {
    final currentFavorite = favoriteSuperheroesSubject.value;
    final newFavorite = currentFavorite.isNotEmpty
        ? currentFavorite
            .takeWhile((value) =>
                currentFavorite.indexOf(value) < currentFavorite.length - 1)
            .toList()
        : SuperheroInfo.mocked;
    favoriteSuperheroesSubject.add(newFavorite);
  }

  void searchForSuperheroes(final String text) {
    stateSubject.add(MainPageState.loading);
    searchSubscription = search(text).asStream().listen((searchReults) {
      if (searchReults.isEmpty) {
        stateSubject.add(MainPageState.nothingFound);
      } else {
        searchedSuperheroesSubject.add(searchReults);
        stateSubject.add(MainPageState.searchResults);
      }
    }, onError: (error, stackTrace) {
      stateSubject.add(MainPageState.loadingError);
    });
  }

  Stream<List<SuperheroInfo>> obsereFavoriteSuperheroes() =>
      favoriteSuperheroesSubject;

  Stream<List<SuperheroInfo>> obsereSearchedSuperheroes() =>
      searchedSuperheroesSubject;

  Future<List<SuperheroInfo>> search(final String text) async {
    await Future.delayed(const Duration(seconds: 1));
    final response = await http.get(Uri.parse("https://postman-echo.com/get?foo1=bar1&foo2=bar2"));
    print(response.statusCode);
    print(response.reasonPhrase);
    print(response.headers);
    print(response.body);
    return SuperheroInfo.mocked
        .where((element) =>
            element.name.toLowerCase().contains(text.toLowerCase()))
        .toList();
  }

  void nextState() {
    final currentState = stateSubject.value;
    final nextState = MainPageState.values[
        (MainPageState.values.indexOf(currentState) + 1) %
            MainPageState.values.length];
    stateSubject.add(nextState);
  }

  void updateText(final String? text) {
    currentTextSubject.add(text ?? "");
  }

  void dispose() {
    stateSubject.close();
    favoriteSuperheroesSubject.close();
    searchedSuperheroesSubject.close();
    currentTextSubject.close();

    textSubscription?.cancel();
  }
}

enum MainPageState {
  noFavorites,
  minSymbols,
  loading,
  nothingFound,
  loadingError,
  searchResults,
  favorites,
}

class SuperheroInfo {
  final String name;
  final String realName;
  final String imageUrl;

  const SuperheroInfo({
    required this.name,
    required this.realName,
    required this.imageUrl,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SuperheroInfo &&
        other.name == name &&
        other.realName == realName &&
        other.imageUrl == imageUrl;
  }

  @override
  int get hashCode => name.hashCode ^ realName.hashCode ^ imageUrl.hashCode;

  @override
  String toString() =>
      'SuperheroInfo()(name: $name, realName: $realName, imageUrl: $imageUrl)';

  static const mocked = [
    SuperheroInfo(
      name: "Batman",
      realName: "Bruce Wayne",
      imageUrl: SuperheroesImages.batmanUrl,
    ),
    SuperheroInfo(
      name: "Ironman",
      realName: "Tony Stark",
      imageUrl: SuperheroesImages.ironmanUrl,
    ),
    SuperheroInfo(
      name: "Venom",
      realName: "Eddie Brock",
      imageUrl: SuperheroesImages.venomUrl,
    ),
  ];
}

class MainPageStateInfo {
  final String searchText;
  final bool haveFavorites;

  MainPageStateInfo(this.searchText, this.haveFavorites);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MainPageStateInfo &&
        other.searchText == searchText &&
        other.haveFavorites == haveFavorites;
  }

  @override
  int get hashCode => searchText.hashCode ^ haveFavorites.hashCode;
}
