import 'package:counter_note/cubit/navigation_cubit.dart';
import 'package:counter_note/screens/journals.dart';
import 'package:counter_note/screens/pages.dart';
import 'package:counter_note/screens/settings.dart';
import 'package:counter_note/central/search.dart';
import 'package:counter_note/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CentralNavigation extends StatelessWidget {
  final Widget child;
  const CentralNavigation({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationCubit, NavigationState>(
      builder: (context, state) {
        if (state is NavigationSuccess) {
          return Row(
            children: [
              Container(
                width: 190,
                decoration: const BoxDecoration(),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 1,
                          child: Button(
                            'Sync',
                            icon: BlocBuilder<NavigationCubit, NavigationState>(
                              builder: (context, state) {
                                return state is NavigationLoading
                                    ? const SizedBox(
                                        width: 15,
                                        height: 15,
                                        child: CircularProgressIndicator(
                                          color: Colors.black38,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.sync);
                              },
                            ),
                            active: false,
                            onTap: () {
                              context.read<NavigationCubit>().sync();
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 1,
                          child: Button(
                            '⌘K',
                            icon: const Icon(Icons.search),
                            active: false,
                            onTap: () {
                              openSearchMenu(context);
                            },
                          ),
                        ),
                      ],
                    ),
                    Button(
                      'Journals',
                      icon: const Icon(Icons.calendar_today_outlined),
                      active: state.journalNav,
                      onTap: () {
                        context
                            .read<NavigationCubit>()
                            .navigateTo(RouteState.journalSelected);
                      },
                    ),
                    Button(
                      'Pages',
                      icon: const Icon(Icons.summarize_outlined),
                      active: state.pagesNav,
                      onTap: () {
                        context
                            .read<NavigationCubit>()
                            .navigateTo(RouteState.pages);
                      },
                    ),
                    Expanded(child: Container()),
                    Button(
                      'Settings',
                      icon: const Icon(Icons.settings_outlined),
                      active: state.settingsNav,
                      onTap: () {
                        context
                            .read<NavigationCubit>()
                            .navigateTo(RouteState.settings);
                      },
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
              const VerticalDivider(
                width: 1,
                color: Colors.black38,
                thickness: 1,
              ),
              Expanded(child: buildBody(state)),
            ],
          );
        } else {
          return Container();
        }
      },
    );
  }

  StatelessWidget buildBody(NavigationSuccess state) {
    return switch (state.route) {
      RouteState.journalSelected => const JournalsScreen(),
      RouteState.pages => const PagesScreen(),
      RouteState.pageSelected => const PagesScreen(),
      RouteState.settings => const SettingsScreen(),
    };
  }
}
