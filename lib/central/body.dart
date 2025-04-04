import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onyx/cubit/navigation_cubit.dart';
import 'package:onyx/screens/journals.dart';
import 'package:onyx/screens/pages.dart';
import 'package:onyx/screens/settings.dart';

class Body extends StatelessWidget {
  const Body({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationCubit, NavigationState>(
        builder: (BuildContext context, NavigationState state) {
      if (state is NavigationSuccess) {
        return switch (state.route) {
          RouteState.journalSelected => const JournalsScreen(),
          RouteState.pages => const PagesScreen(),
          RouteState.pageSelected => const PagesScreen(),
          RouteState.settings => const SettingsScreen(),
        };
      } else {
        return Container();
      }
    });
  }
}
