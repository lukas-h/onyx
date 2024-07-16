import 'package:onyx/central/favorites.dart';
import 'package:onyx/central/help.dart';
import 'package:onyx/central/recents.dart';
import 'package:onyx/cubit/navigation_cubit.dart';
import 'package:onyx/screens/journals.dart';
import 'package:onyx/screens/pages.dart';
import 'package:onyx/screens/settings.dart';
import 'package:onyx/central/search.dart';
import 'package:onyx/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CentralNavigation extends StatelessWidget {
  const CentralNavigation({
    super.key,
  });
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
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 35,
                          child: Button(
                            '',
                            maxWidth: false,
                            icon: const Icon(Icons.keyboard_arrow_left),
                            active: false,
                            onTap: context.read<NavigationCubit>().canUndo
                                ? () {
                                    context.read<NavigationCubit>().undo();
                                  }
                                : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 35,
                          child: Button(
                            '',
                            maxWidth: false,
                            icon: const Icon(Icons.keyboard_arrow_right),
                            active: false,
                            onTap: context.read<NavigationCubit>().canRedo
                                ? () {
                                    context.read<NavigationCubit>().redo();
                                  }
                                : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Divider(
                      height: 12,
                      endIndent: 0,
                      thickness: 1,
                      color: Colors.black.withOpacity(0.08),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 1,
                          child: Button(
                            'Sync',
                            maxWidth: true,
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
                            maxWidth: true,
                            icon: const Icon(Icons.search),
                            active: false,
                            onTap: () {
                              openSearchMenu(
                                context,
                                onSelect: (context, state) {
                                  Navigator.pop(context);
                                  final cubit = context.read<NavigationCubit>();
                                  if (state == null) return;
                                  if (state.isJournal) {
                                    cubit.switchToJournal(state.uid);
                                  } else {
                                    cubit.switchToPage(state.uid);
                                  }
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    Button(
                      'Journals',
                      maxWidth: true,
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
                      maxWidth: true,
                      icon: const Icon(Icons.summarize_outlined),
                      active: state.pagesNav,
                      onTap: () {
                        context
                            .read<NavigationCubit>()
                            .navigateTo(RouteState.pages);
                      },
                    ),
                    const SizedBox(height: 8),
                    Divider(
                      height: 12,
                      endIndent: 0,
                      thickness: 1,
                      color: Colors.black.withOpacity(0.08),
                    ),
                    const FavoritesList(),
                    const RecentsList(),
                    if (state.route != RouteState.pages &&
                        state.route != RouteState.settings)
                      Button(
                        'References',
                        maxWidth: true,
                        icon: const Icon(Icons.hub_outlined),
                        active: false,
                        onTap: () {},
                      ),
                    Expanded(child: Container()),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Button(
                            'Settings',
                            maxWidth: true,
                            icon: const Icon(Icons.settings_outlined),
                            active: state.settingsNav,
                            onTap: () {
                              context
                                  .read<NavigationCubit>()
                                  .navigateTo(RouteState.settings);
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 1,
                          child: Button(
                            '⌘',
                            maxWidth: true,
                            icon: const Icon(Icons.help_outline_outlined),
                            active: false,
                            onTap: () {
                              openHelpMenu(context);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
              const VerticalDivider(
                width: 1,
                color: Colors.black26,
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
