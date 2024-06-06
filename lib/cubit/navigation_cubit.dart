import 'package:collection/collection.dart';
import 'package:onyx/store/image_store.dart';
import 'package:onyx/store/page_store.dart';

import 'package:onyx/cubit/page_cubit.dart';
import 'package:replay_bloc/replay_bloc.dart';

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
  final bool newPage;

  bool get journalNav => route == RouteState.journalSelected;

  bool get pagesNav =>
      route == RouteState.pageSelected || route == RouteState.pages;

  bool get settingsNav => route == RouteState.settings;

  NavigationSuccess({
    required this.route,
    required this.index,
    required this.newPage,
  });

  NavigationSuccess copyWith({
    RouteState? route,
    int? index,
    bool? newPage,
  }) {
    return NavigationSuccess(
      route: route ?? this.route,
      index: index ?? this.index,
      newPage: newPage ?? false,
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
    super.newPage = false,
  });

  NavigationSuccess copyToSuccess() => NavigationSuccess(
        route: route,
        index: index,
        newPage: false,
      );
}

class NavigationCubit extends ReplayCubit<NavigationState> {
  final PageStore store;
  final ImageStore imageStore;
  final Set<String> _recentPages = {};
  List<String> get recentPages => _recentPages.toList();

  NavigationCubit({
    required this.store,
    required this.imageStore,
  }) : super(NavigationInitial()) {
    init();
  }
  Future<void> init() async {
    await store.init();
    await imageStore.init();

    if (state is NavigationSuccess) {
      emit((state as NavigationSuccess).copyWith());
    } else {
      emit(
        NavigationSuccess(
          route: RouteState.journalSelected,
          index: 0,
          newPage: false,
        ),
      );
    }
  }

  Future<void> sync() async {
    if (state is NavigationSuccess) {
      emit((state as NavigationSuccess).copyToLoading());
      await store.init();
      emit((state as NavigationLoading).copyToSuccess());
    }
  }

  Future<void> deletePage(String uid) async {
    if (state is NavigationSuccess) {
      final currentState = state as NavigationSuccess;
      store.deletePage(uid);
      emit(
        currentState.copyWith(
          index: 0,
          route: RouteState.pages,
        ),
      );
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
          newPage: true,
        ),
      );
      final uid = store.getPage(newIndex)?.uid;
      if (uid != null) _recentPages.add(uid);
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
      _recentPages.add(uid);
    }
  }

  void switchToJournal(String uid) {
    if (state is NavigationSuccess) {
      final currentState = state as NavigationSuccess;
      final newIndex = store.getJournalIndex(uid);
      emit(
        currentState.copyWith(
          index: newIndex,
          route: RouteState.journalSelected,
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

  void openPageOrJournal(String text) {
    final page = store.pages.firstWhereOrNull((e) => e.title == text)?.uid;
    if (page != null) {
      switchToPage(page);
    } else {
      final journal =
          store.journals.firstWhereOrNull((e) => e.title == text)?.uid;
      if (journal != null) {
        switchToJournal(journal);
      }
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

  List<PageState> get journals =>
      store.journals.map((e) => e.toPageState(true)).toList();
}
