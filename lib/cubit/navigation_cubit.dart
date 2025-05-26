import 'package:collection/collection.dart';
import 'package:onyx/store/image_store.dart';
import 'package:onyx/store/page_store.dart';

import 'package:onyx/cubit/page_cubit.dart';
import 'package:onyx/utils/utils.dart';
import 'package:replay_bloc/replay_bloc.dart';

class NavigationState {}

class NavigationInitial extends NavigationState {}

enum RouteState {
  pages,
  pageSelected,
  journalSelected,
  graphview,
  settings,
}

class NavigationSuccess extends NavigationState {
  final RouteState route;
  final String? pageId;
  final bool newPage;

  bool get journalNav => route == RouteState.journalSelected;

  bool get pagesNav => route == RouteState.pageSelected || route == RouteState.pages;

  bool get settingsNav => route == RouteState.settings;
  bool get graphViewNav => route == RouteState.graphview;

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
    await store.init();
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

      await store.init();
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
      final newPageId = store.createPage();
      emit(
        currentState.copyWith(
          pageId: newPageId,
          route: RouteState.pageSelected,
          newPage: true,
        ),
      );
      _recentPages.add(newPageId);
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
      final newPageId = store.getTodaysJournalId();
      emit(
        currentState.copyWith(
          pageId: newPageId,
          route: RouteState.journalSelected,
        ),
      );
    }
  }

  Future<void> switchToPreviousJournal() async {
    if (state is NavigationSuccess) {
      final currentState = state as NavigationSuccess;

      try {
        final currentJournalDate = ddmmyyyy.parse(currentState.pageId ?? '');
        final nextJournalDate = currentJournalDate.subtract(Duration(days: 1));
        final nextJournalDateString = ddmmyyyy.format(nextJournalDate);

        emit(
          currentState.copyWith(
            pageId: nextJournalDateString,
            route: RouteState.journalSelected,
          ),
        );
      } catch (e) {
        emit(
          currentState.copyWith(
            pageId: store.getTodaysJournalId(),
            route: RouteState.journalSelected,
          ),
        );
      }
    }
  }

  void switchToNextJournal() {
    if (state is NavigationSuccess) {
      final currentState = state as NavigationSuccess;

      try {
        final currentJournalDate = ddmmyyyy.parse(currentState.pageId ?? '');
        final nextJournalDate = currentJournalDate.add(Duration(days: 1));
        final nextJournalDateString = ddmmyyyy.format(nextJournalDate);

        emit(
          currentState.copyWith(
            pageId: nextJournalDateString,
            route: RouteState.journalSelected,
          ),
        );
      } catch (e) {
        emit(
          currentState.copyWith(
            pageId: store.getTodaysJournalId(),
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
    final page = store.pages.values.firstWhereOrNull((e) => e.title == text)?.uid;
    if (page != null) {
      switchToPage(page);
    } else {
      final journal = store.journals.values.firstWhereOrNull((e) => e.title == text)?.uid;
      if (journal != null) {
        switchToJournal(journal);
      }
    }
  }

  void openPageOrJournalUsingUid(String uid){
    final page = store.pages.values.firstWhereOrNull((e) => e.uid == uid);
    if (page != null) {
      switchToPage(page.uid);
    } else {
      final journal = store.journals.values.firstWhereOrNull((e) => e.uid == uid);
      if (journal != null) {
        switchToJournal(journal.uid);
      }
    }
  }

  PageState? get currentPage {
    if (state is NavigationSuccess) {
      final currentState = state as NavigationSuccess;
      return switch (currentState.route) {
        RouteState.pages => store.getPage(currentState.pageId ?? '')?.toPageState(false),
        RouteState.pageSelected => store.getPage(currentState.pageId ?? '')?.toPageState(false),
        RouteState.journalSelected => store.getJournal(currentState.pageId ?? '').toPageState(true),
        RouteState.settings => null,
        RouteState.graphview => null
      };
    } else {
      return null;
    }
  }

  List<PageState> get pages => store.pages.values.map((e) => e.toPageState(false)).toList();

  List<PageState> get journals => store.journals.values.map((e) => e.toPageState(true)).toList();
}
