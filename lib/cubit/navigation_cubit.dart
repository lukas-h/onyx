import 'package:bloc/bloc.dart';
import 'package:counter_note/cubit/page_cubit.dart';
import 'package:intl/intl.dart';

class NavigationState {}

class NavigationInitial extends NavigationState {}

enum RouteState {
  pages,
  pageSelected,
  journals,
  journalSelected,
  settings,
}

class NavigationSuccess extends NavigationState {
  final List<PageState> pages;
  final List<PageState> journals;
  final RouteState route;
  final int? index;

  NavigationSuccess({
    required this.pages,
    required this.journals,
    required this.route,
    required this.index,
  });
}

class NavigationCubit extends Cubit<NavigationState> {
  NavigationCubit() : super(NavigationInitial()) {
    init();
  }
  Future<void> init() async {
    await Future.delayed(const Duration(seconds: 1));
    print('Herro');
    emit(
      NavigationSuccess(
        route: RouteState.journalSelected,
        index: 0,
        pages: [],
        journals: [
          PageState(
            items: const [],
            index: 0,
            sum: 0,
            title: DateFormat.yMMMMd().format(DateTime.now()),
            created: DateTime.now(),
          ),
        ],
      ),
    );
  }

  void sync() {}

  void createPage() {}
  void createJournal() {}

  void deletePage() {}

  void updatePage() {}
  void updateJournal() {}
}
