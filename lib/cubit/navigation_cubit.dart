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
  final String? pageId;
  final bool newPage;

  bool get journalNav => route == RouteState.journalSelected;

  bool get pagesNav =>
      route == RouteState.pageSelected || route == RouteState.pages;

  bool get settingsNav => route == RouteState.settings;

  NavigationSuccess({
    required this.route,
    this.pageId,
    required this.newPage,
  });

  NavigationSuccess copyWith({
    RouteState? route,
    String? pageId,
    bool? newPage,
  }) {
    return NavigationSuccess(
      route: route ?? this.route,
      pageId: pageId ?? this.pageId,
      newPage: newPage ?? false,
    );
  }

  NavigationLoading copyToLoading() => NavigationLoading(
        route: route,
        pageId: pageId,
      );
}

class NavigationLoading extends NavigationSuccess {
  NavigationLoading({
    required super.route,
    required super.pageId,
    super.newPage = false,
  });

  NavigationSuccess copyToSuccess() => NavigationSuccess(
        route: route,
        pageId: pageId,
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
    // await store.init();
    await store.initLimitation();
    await imageStore.init();

    if (state is NavigationSuccess) {
      emit((state as NavigationSuccess).copyWith());
    } else {
      emit(
        NavigationSuccess(
          route: RouteState.journalSelected,
          newPage: false,
        ),
      );
    }
  }

  Future<void> sync() async {
    if (state is NavigationSuccess) {
      emit((state as NavigationSuccess).copyToLoading());
      // await store.init();
      await store.initLimitation();
      await imageStore.init();
      if (state is NavigationLoading) {
        emit((state as NavigationLoading).copyToSuccess());
      }
    }
  }

  Future<void> deletePage(String uid) async {
    if (state is NavigationSuccess) {
      final currentState = state as NavigationSuccess;
      store.deletePage(uid);
      emit(
        currentState.copyWith(
          route: RouteState.pages,
        ),
      );
    }
  }

  void createPage() {
    if (state is NavigationSuccess) {
      final currentState = state as NavigationSuccess;
      final newpageId = store.createPage();
      emit(
        currentState.copyWith(
          pageId: newpageId,
          route: RouteState.pageSelected,
          newPage: true,
        ),
      );
      final uid = store.getPage(newpageId)?.uid;
      if (uid != null) _recentPages.add(uid);
    }
  }

  void switchToPage(String uid) {
    if (state is NavigationSuccess) {
      final currentState = state as NavigationSuccess;
      emit(
        currentState.copyWith(
          pageId: uid,
          route: RouteState.pageSelected,
        ),
      );
      _recentPages.add(uid);
    }
  }

  void switchToJournal(String uid) {
    if (state is NavigationSuccess) {
      final currentState = state as NavigationSuccess;
      emit(
        currentState.copyWith(
          pageId: uid,
          route: RouteState.journalSelected,
        ),
      );
    }
  }

  void switchToTodaysJournal() {
    if (state is NavigationSuccess) {
      final currentState = state as NavigationSuccess;
      final newpageId = store.getTodaysJournalId();
      emit(
        currentState.copyWith(
          pageId: newpageId,
          route: RouteState.journalSelected,
        ),
      );
    }
  }

  Future<void> switchToPreviousJournal() async {
    if (state is NavigationSuccess) {
      final currentState = state as NavigationSuccess;
      if (currentState.pageId < (store.journalLength - 1)) {
        final newpageId = currentState.pageId + 1;
        emit(
          currentState.copyWith(
            pageId: newpageId,
            route: RouteState.journalSelected,
          ),
        );
      } else {
        // TODO add pagination -> load older
        await store.loadMoreJournals(store.journals, 30, false);
      }
    }
  }

  void switchToNextJournal() {
    if (state is NavigationSuccess) {
      final currentState = state as NavigationSuccess;

      if (currentState.pageId > 0) {
        final newpageId = currentState.pageId - 1;

        emit(
          currentState.copyWith(
            pageId: newpageId,
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
          store.getPage(currentState.pageId)?.toPageState(false),
        RouteState.pageSelected =>
          store.getPage(currentState.pageId)?.toPageState(false),
        RouteState.journalSelected =>
          store.getJournal(currentState.pageId)?.toPageState(true),
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
