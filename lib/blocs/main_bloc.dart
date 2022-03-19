import 'dart:async';
import 'dart:convert';

// import 'package:rxdart/subjects.dart';
import 'package:flutter/cupertino.dart';
import 'package:rxdart/rxdart.dart';
import 'package:superheroes/exception/api_exception.dart';
import 'package:superheroes/model/superhero.dart';
import 'package:superheroes/resources/superheroes_images.dart';
import "package:http/http.dart" as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MainBloc {
  static const minSymbols = 3;

  final stateSubject = BehaviorSubject<MainPageState>();
  final searchedSuperheroesSubject = BehaviorSubject<List<SuperheroInfo>>();
  final favoriteSuperheroesSubject =
      BehaviorSubject<List<SuperheroInfo>>.seeded(SuperheroInfo.mocked);
  final currentTextSubject = BehaviorSubject<String>.seeded("");
  final FocusNode searchFocusNode = FocusNode();

  bool hasSearchError = false;
  StreamSubscription? textSubscription;
  StreamSubscription? searchSubscription;

  http.Client? client;

  Stream<MainPageState> observeMainPageState() => stateSubject;

  MainBloc({this.client}) {
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
    hasSearchError = false;
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
      hasSearchError = true;
    });
  }

  Stream<List<SuperheroInfo>> obsereFavoriteSuperheroes() =>
      favoriteSuperheroesSubject;
  Stream<List<SuperheroInfo>> obsereSearchedSuperheroes() =>
      searchedSuperheroesSubject;

  Future<List<SuperheroInfo>> search(final String text) async {
    final token = dotenv.env["SUPERHERO_TOKEN"];
    final response = await (client ??= http.Client())
        .get(Uri.parse("https://superheroapi.com/api/$token/search/$text"));
    // .get(Uri.parse("https://postman-echo.com/stat/459"));

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded['response'] == 'success') {
        final List<dynamic> results = decoded['results'];
        final List<Superhero> superheroes =
            results.map((e) => Superhero.fromJson(e)).toList();
        final List<SuperheroInfo> found = superheroes.map((superhero) {
          return SuperheroInfo(
            name: superhero.name,
            realName: superhero.biography.fullName,
            imageUrl: superhero.image.url,
          );
        }).toList();
        return found;
      } else if (decoded['response'] == 'error') {
        if (decoded['error'] == 'character with given name not found') {
          return [];
        }
      }
    }
    final ApiException exception = ApiException.get(response.statusCode);
    throw exception;
  }

  void retry() {
    if (hasSearchError) {
      final String currentValue = currentTextSubject.value;
      currentTextSubject.add("");
      currentTextSubject.add(currentValue);
    }
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
    client?.close();
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
