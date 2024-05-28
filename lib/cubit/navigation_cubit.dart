import 'package:bloc/bloc.dart';
import 'package:counter_note/persistence/page_store.dart';

import 'package:counter_note/cubit/page_cubit.dart';

class NavigationState {}

class NavigationInitial extends NavigationState {}

enum RouteState {
  pages,
  pageSelected,
  journalSelected,
  settings,
}

class NavigationSuccess extends NavigationState {
  final RouteState route;
  final int index;

  bool get journalNav => route == RouteState.journalSelected;

  bool get pagesNav =>
      route == RouteState.pageSelected || route == RouteState.pages;

  bool get settingsNav => route == RouteState.settings;

  NavigationSuccess({
    required this.route,
    required this.index,
  });

  NavigationSuccess copyWith({
    RouteState? route,
    int? index,
  }) {
    return NavigationSuccess(
      route: route ?? this.route,
      index: index ?? this.index,
    );
  }

  NavigationLoading copyToLoading() => NavigationLoading(
        route: route,
        index: index,
      );
}

class NavigationLoading extends NavigationSuccess {
  NavigationLoading({
    required super.route,
    required super.index,
  });

  NavigationSuccess copyToSuccess() => NavigationSuccess(
        route: route,
        index: index,
      );
}

class NavigationCubit extends Cubit<NavigationState> {
  final PageStore store;
  NavigationCubit({
    required this.store,
  }) : super(NavigationInitial()) {
    init();
  }
  Future<void> init() async {
    await store.init();
    await Future.delayed(const Duration(seconds: 1));
    // TODO wait for store
    emit(
      NavigationSuccess(
        route: RouteState.journalSelected,
        index: 0,
      ),
    );
  }

  Future<void> sync() async {
    if (state is NavigationSuccess) {
      emit((state as NavigationSuccess).copyToLoading());
      await Future.delayed(const Duration(seconds: 3));
      emit((state as NavigationLoading).copyToSuccess());
    }
  }

  void createPage() {
    if (state is NavigationSuccess) {
      final currentState = state as NavigationSuccess;
      final newIndex = store.createPage();
      emit(
        currentState.copyWith(
          index: newIndex,
          route: RouteState.pageSelected,
        ),
      );
    }
  }

  void switchToPage(String uid) {
    if (state is NavigationSuccess) {
      final currentState = state as NavigationSuccess;
      final newIndex = store.getPageIndex(uid);
      emit(
        currentState.copyWith(
          index: newIndex,
          route: RouteState.pageSelected,
        ),
      );
    }
  }

  void switchToTodaysJournal() {
    if (state is NavigationSuccess) {
      final currentState = state as NavigationSuccess;
      final newIndex = store.getTodaysJournalIndex();
      emit(
        currentState.copyWith(
          index: newIndex,
          route: RouteState.journalSelected,
        ),
      );
    }
  }

  void switchToPreviousJournal() {
    if (state is NavigationSuccess) {
      final currentState = state as NavigationSuccess;
      if (currentState.index < (store.journalLength - 1)) {
        final newIndex = currentState.index + 1;
        emit(
          currentState.copyWith(
            index: newIndex,
            route: RouteState.journalSelected,
          ),
        );
      } else {
        // TODO add pagination -> load older
      }
    }
  }

  void switchToNextJournal() {
    if (state is NavigationSuccess) {
      final currentState = state as NavigationSuccess;
      if (currentState.index > 0) {
        final newIndex = currentState.index - 1;
        emit(
          currentState.copyWith(
            index: newIndex,
            route: RouteState.journalSelected,
          ),
        );
      }
    }
  }

  void navigateTo(RouteState newRoute) {
    if (state is NavigationSuccess) {
      final currentState = state as NavigationSuccess;
      emit(
        currentState.copyWith(
          route: newRoute,
        ),
      );
    }
  }

  PageState? get currentPage {
    if (state is NavigationSuccess) {
      final currentState = state as NavigationSuccess;
      return switch (currentState.route) {
        RouteState.pages =>
          store.getPage(currentState.index)?.toPageState(false),
        RouteState.pageSelected =>
          store.getPage(currentState.index)?.toPageState(false),
        RouteState.journalSelected =>
          store.getJournal(currentState.index)?.toPageState(true),
        RouteState.settings => null,
      };
    } else {
      return null;
    }
  }

  List<PageState> get pages =>
      store.pages.map((e) => e.toPageState(false)).toList();
}
