import 'package:bloc/bloc.dart';
import 'package:counter_note/utils/utils.dart';
import 'package:intl/intl.dart';

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
  final List<PageState> pages;
  final List<PageState> journals;
  final RouteState route;
  final int index;

  PageState? get currentPage => switch (route) {
        RouteState.pages => pages.isNotEmpty ? pages[index] : null,
        RouteState.journalSelected =>
          journals.isNotEmpty ? journals[index] : null,
        RouteState.pageSelected => pages.isNotEmpty ? pages[index] : null,
        RouteState.settings => journals.last,
      };

  bool get journalNav => route == RouteState.journalSelected;

  bool get pagesNav =>
      route == RouteState.pageSelected || route == RouteState.pages;

  bool get settingsNav => route == RouteState.settings;

  NavigationSuccess({
    required this.pages,
    required this.journals,
    required this.route,
    required this.index,
  });

  NavigationSuccess copyWith({
    List<PageState>? pages,
    List<PageState>? journals,
    RouteState? route,
    int? index,
  }) {
    return NavigationSuccess(
      pages: pages ?? this.pages,
      journals: journals ?? this.journals,
      route: route ?? this.route,
      index: index ?? this.index,
    );
  }

  NavigationLoading copyToLoading() => NavigationLoading(
        pages: pages,
        journals: journals,
        route: route,
        index: index,
      );
}

class NavigationLoading extends NavigationSuccess {
  NavigationLoading({
    required super.pages,
    required super.journals,
    required super.route,
    required super.index,
  });

  NavigationSuccess copyToSuccess() => NavigationSuccess(
        pages: pages,
        journals: journals,
        route: route,
        index: index,
      );
}

class NavigationCubit extends Cubit<NavigationState> {
  NavigationCubit() : super(NavigationInitial()) {
    init();
  }
  Future<void> init() async {
    await Future.delayed(const Duration(seconds: 1));
    emit(
      NavigationSuccess(
        route: RouteState.journalSelected,
        index: 0,
        pages: [],
        journals: [
          ...List.generate(
            30,
            (index) {
              final date = DateTime.now().subtract(Duration(days: index));
              return PageState(
                items: const [],
                index: 0,
                sum: 0,
                title: DateFormat.yMMMMd().format(date),
                created: date,
              );
            },
          ),
        ],
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
      emit(
        currentState.copyWith(
          index: currentState.pages.length,
          route: RouteState.pageSelected,
          pages: [
            ...currentState.pages,
            PageState(
              items: const [],
              index: 0,
              sum: 0,
              title: '',
              created: DateTime.now(),
            ),
          ],
          journals: currentState.journals,
        ),
      );
    }
  }

  // TODO void updatePage() {}
  // TODO void deletePage() {}
  // TODO void updateJournal() {}

  void switchToTodaysJournal() {
    if (state is NavigationSuccess) {
      final currentState = state as NavigationSuccess;
      final newIndex =
          currentState.journals.indexWhere((e) => isToday(e.created));
      emit(currentState.copyWith(
          index: newIndex, route: RouteState.journalSelected));
    }
  }

  void switchToPreviousJournal() {
    if (state is NavigationSuccess) {
      final currentState = state as NavigationSuccess;
      if (currentState.index < (currentState.journals.length - 1)) {
        final newIndex = currentState.index + 1;
        emit(currentState.copyWith(
            index: newIndex, route: RouteState.journalSelected));
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
        emit(currentState.copyWith(
            index: newIndex, route: RouteState.journalSelected));
      }
    }
  }

  navigateTo(RouteState newRoute) {
    if (state is NavigationSuccess) {
      final currentState = state as NavigationSuccess;
      emit(currentState.copyWith(route: newRoute));
    }
  }
}
