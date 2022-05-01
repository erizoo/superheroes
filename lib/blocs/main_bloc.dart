import 'dart:async';
import 'dart:convert';

// import 'package:rxdart/subjects.dart';
import 'package:flutter/cupertino.dart';
import 'package:rxdart/rxdart.dart';
import 'package:superheroes/exception/api_exception.dart';
import 'package:superheroes/favorite_superheroes_storage.dart';
import 'package:superheroes/model/alignment_info.dart';
import 'package:superheroes/model/superhero.dart';
import 'package:superheroes/resources/superheroes_images.dart';
import "package:http/http.dart" as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MainBloc {
  static const minSymbols = 3;

  final stateSubject = BehaviorSubject<MainPageState>();
  final searchedSuperheroesSubject = BehaviorSubject<List<SuperheroInfo>>();
  final currentTextSubject = BehaviorSubject<String>.seeded("");
  final FocusNode searchFocusNode = FocusNode();

  StreamSubscription? textSubscription;
  StreamSubscription? searchSubscription;
  StreamSubscription? removeFromFavoriteSubscription;

  http.Client? client;

  Stream<MainPageState> observeMainPageState() => stateSubject;

  MainBloc({this.client}) {
    // stateSubject.add(MainPageState.noFavorites);

    textSubscription =
        Rx.combineLatest2<String, List<Superhero>, MainPageStateInfo>(
                currentTextSubject
                    .distinct()
                    .debounceTime(const Duration(milliseconds: 500)),
                FavoriteSuperheroesStorage.getIntsance()
                    .observeFavoriteSuperheroes(),
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

  // void removeFavorite() {
  //   final currentFavorite = favoriteSuperheroesSubject.value;
  //   final newFavorite = currentFavorite.isNotEmpty
  //       ? currentFavorite
  //           .takeWhile((value) =>
  //               currentFavorite.indexOf(value) < currentFavorite.length - 1)
  //           .toList()
  //       : SuperheroInfo.mocked;
  //   favoriteSuperheroesSubject.add(newFavorite);
  // }

  void removeFromFavorites(final String id) {
    removeFromFavoriteSubscription?.cancel();
    removeFromFavoriteSubscription = FavoriteSuperheroesStorage.getIntsance()
        .removeFromFavorites(id)
        .asStream()
        .listen((event) {
      print("Removed from favorites $event");
    }, onError: (error, stackTrace) {
      print("Error happened in removeFromFavorites $error, $stackTrace");
    });
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

  Stream<List<SuperheroInfo>> obsereFavoriteSuperheroes() {
    return FavoriteSuperheroesStorage.getIntsance()
        .observeFavoriteSuperheroes()
        .map((superheroes) {
      return superheroes
          .map((superhero) => SuperheroInfo.fromSuperhero(superhero))
          .toList();
    });
  }

  Stream<List<SuperheroInfo>> obsereSearchedSuperheroes() =>
      searchedSuperheroesSubject;

  Future<List<SuperheroInfo>> search(final String text) async {
    final token = dotenv.env["SUPERHERO_TOKEN"];
    final response = await (client ??= http.Client())
        .get(Uri.parse("https://superheroapi.com/api/$token/search/$text"));
    // .get(Uri.parse("https://postman-echo.com/stat/459"));
    if (response.statusCode >= 400 && response.statusCode <= 499) {
      throw ApiException("Client error happened");
    } else if (response.statusCode >= 500 && response.statusCode <= 599) {
      throw ApiException("Server error happened");
    } else if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded['response'] == 'success') {
        final List<dynamic> results = decoded['results'];
        final List<Superhero> superheroes =
            results.map((e) => Superhero.fromJson(e)).toList();
        final List<SuperheroInfo> found = superheroes.map((superhero) {
          return SuperheroInfo.fromSuperhero(superhero);
        }).toList();
        return found;
      } else if (decoded['response'] == 'error') {
        if (decoded['error'] == 'character with given name not found') {
          return [];
        }
        throw ApiException("Client error happened");
      }
    }
    throw Exception("Unknow error happened");
  }

  void retry() {
    final String currentValue = currentTextSubject.value;
    currentTextSubject.add("");
    currentTextSubject.add(currentValue);
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
    searchedSuperheroesSubject.close();
    currentTextSubject.close();
    searchSubscription?.cancel();
    removeFromFavoriteSubscription?.cancel();
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
  final String id;
  final String name;
  final String realName;
  final String imageUrl;
  final AlignmentInfo? alignmentInfo;

  const SuperheroInfo({
    required this.id,
    required this.name,
    required this.realName,
    required this.imageUrl,
    this.alignmentInfo,
  });

  factory SuperheroInfo.fromSuperhero(final Superhero superhero) {
    return SuperheroInfo(
      id: superhero.id,
      name: superhero.name,
      realName: superhero.biography.fullName,
      imageUrl: superhero.image.url,
      alignmentInfo: superhero.biography.alignmentInfo,
    );
  }

  SuperheroInfo copyWith({
    String? id,
    String? name,
    String? realName,
    String? imageUrl,
  }) {
    return SuperheroInfo(
      id: id ?? this.id,
      name: name ?? this.name,
      realName: realName ?? this.realName,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SuperheroInfo &&
        other.id == id &&
        other.name == name &&
        other.realName == realName &&
        other.imageUrl == imageUrl;
  }

  @override
  int get hashCode {
    return id.hashCode ^ name.hashCode ^ realName.hashCode ^ imageUrl.hashCode;
  }

  @override
  String toString() {
    return 'SuperheroInfo(id: $id, name: $name, realName: $realName, imageUrl: $imageUrl)';
  }

  static const mocked = [
    SuperheroInfo(
      id: "70",
      name: "Batman",
      realName: "Bruce Wayne",
      imageUrl: SuperheroesImages.batmanUrl,
    ),
    SuperheroInfo(
      id: "732",
      name: "Ironman",
      realName: "Tony Stark",
      imageUrl: SuperheroesImages.ironmanUrl,
    ),
    SuperheroInfo(
      id: "687",
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
