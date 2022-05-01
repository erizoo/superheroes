import 'dart:async';
import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:rxdart/subjects.dart';
import 'package:superheroes/exception/api_exception.dart';
import 'package:superheroes/favorite_superheroes_storage.dart';
import 'package:superheroes/model/superhero.dart';

class SuperheroBloc {
  http.Client? client;
  final String id;

  final superheroSubject = BehaviorSubject<Superhero>();
  final stateSubject = BehaviorSubject<SuperheroPageState>();

  SuperheroBloc({this.client, required this.id}) {
    getFromFavorites();
  }

  Stream<Superhero> observeSuperhero() => superheroSubject;
  Stream<SuperheroPageState> observeSuperheroPageState() => stateSubject;

  StreamSubscription? requestSubscription;
  StreamSubscription? addToFavoriteSubscription;
  StreamSubscription? removeFromFavoriteSubscription;
  StreamSubscription? getFromFavoritesSubscription;

  void requestSuperhero() {
    requestSubscription?.cancel();
    requestSubscription = request().asStream().listen((superhero) {
      final lastSuperhero = superheroSubject.valueOrNull;
      if (lastSuperhero != null && superheroSubject.value == superhero) {
        return;
      } else {
        superheroSubject.add(superhero);
      }
    }, onError: (error, stackTrace) {
      print("Error happened in requestSuperhero $error, $stackTrace");
    });
  }

  void retry() {
    updateState(SuperheroPageState.loading);
    requestSuperhero();
  }

  Future<Superhero> request() async {
    final token = dotenv.env["SUPERHERO_TOKEN"];
    final response = await (client ??= http.Client())
        .get(Uri.parse("https://superheroapi.com/api/$token/$id"));
    // .get(Uri.parse("https://postman-echo.com/stat/459"));
    if (response.statusCode >= 400 && response.statusCode <= 499) {
      updateState(SuperheroPageState.error);
      throw ApiException("Client error happened");
    } else if (response.statusCode >= 500 && response.statusCode <= 599) {
      updateState(SuperheroPageState.error);
      throw ApiException("Server error happened");
    } else if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded['response'] == 'success') {
        final superhero = Superhero.fromJson(decoded);
        await FavoriteSuperheroesStorage.getIntsance()
            .updateFavorites(superhero);
        updateState(SuperheroPageState.loaded);
        return superhero;
      } else if (decoded['response'] == 'error') {
        updateState(SuperheroPageState.error);
        throw ApiException("Client error happened");
      }
    }
    updateState(SuperheroPageState.error);
    throw Exception("Unknow error happened");
  }

  void getFromFavorites() {
    getFromFavoritesSubscription?.cancel();
    getFromFavoritesSubscription = FavoriteSuperheroesStorage.getIntsance()
        .getSuperhero(id)
        .asStream()
        .listen((superhero) {
      if (superhero != null) {
        superheroSubject.add(superhero);
        updateState(SuperheroPageState.loaded);
      } else {
        updateState(SuperheroPageState.loading);
      }
      requestSuperhero();
    }, onError: (error, stackTrace) {
      print("Error happened in addToFavorites $error, $stackTrace");
    });
  }

  void updateState(final SuperheroPageState newState) {
    final currState = stateSubject.valueOrNull;
    if (newState == currState) {
      return;
    }
    if (currState == SuperheroPageState.loaded &&
        newState == SuperheroPageState.error) {
      return;
    }
    stateSubject.add(newState);
    // stateSubject.add(SuperheroPageState.loading);
  }

  void addToFavorite() {
    final superhero = superheroSubject.valueOrNull;
    if (superhero == null) {
      return;
    }
    addToFavoriteSubscription?.cancel();
    addToFavoriteSubscription = FavoriteSuperheroesStorage.getIntsance()
        .addToFavorites(superhero)
        .asStream()
        .listen((event) {
      // print("Added to favorites $event");
    }, onError: (error, stackTrace) {
      print("Error happened in addToFavorites $error, $stackTrace");
    });
  }

  void removeFromFavorites() {
    removeFromFavoriteSubscription?.cancel();
    removeFromFavoriteSubscription = FavoriteSuperheroesStorage.getIntsance()
        .removeFromFavorites(id)
        .asStream()
        .listen((event) {
      // print("Removed from favorites $event");
    }, onError: (error, stackTrace) {
      print("Error happened in removeFromFavorites $error, $stackTrace");
    });
  }

  Stream<bool> observeIsFavorite() {
    return FavoriteSuperheroesStorage.getIntsance().observeIsFavorite(id);
  }

  void dispose() {
    client?.close();
    requestSubscription?.cancel();
    addToFavoriteSubscription?.cancel();
    removeFromFavoriteSubscription?.cancel();
    getFromFavoritesSubscription?.cancel();
    superheroSubject.close();
  }
}

enum SuperheroPageState {
  loading,
  loaded,
  error,
}
