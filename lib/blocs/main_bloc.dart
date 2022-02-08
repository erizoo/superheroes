import 'dart:async';

import 'package:rxdart/rxdart.dart';

class MainBloc {
  final BehaviorSubject<MainPageState> stateSubject = BehaviorSubject();

  Stream<MainPageState> observeMainPageState() => stateSubject.stream;

  MainBloc(){
    stateSubject.add(MainPageState.noFavorite);
  }

  void nextState() {
    final currentState = stateSubject.value;
    final nextState = MainPageState.values[(MainPageState.values.indexOf(currentState) + 1) %
        MainPageState.values.length];
    stateSubject.add(nextState);
  }

  void dispose() {
    stateSubject.close();
  }
}

enum MainPageState {
  noFavorite,
  minSymbols,
  loading,
  nothingFound,
  loadingError,
  searchResult,
  favorites,
}
