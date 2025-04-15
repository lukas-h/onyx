import 'package:onyx/central/favorites.dart';
import 'package:onyx/central/help.dart';
import 'package:onyx/central/recents.dart';
import 'package:onyx/cubit/connectivity_cubit.dart';
import 'package:onyx/cubit/navigation_cubit.dart';
import 'package:onyx/central/search.dart';
import 'package:onyx/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NavigationMenu extends StatelessWidget {
  final NavigationSuccess state;
  final VoidCallback onTapCollapse;
  const NavigationMenu(
      {super.key, required this.state, required this.onTapCollapse});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 196,
      decoration: const BoxDecoration(),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Button(
                '',
                width: 40,
                height: 40,
                iconSize: 18,
                maxWidth: false,
                icon: const Icon(Icons.more_horiz_outlined),
                active: false,
                onTap: onTapCollapse,
              ),
              Button(
                '',
                width: 40,
                height: 40,
                iconSize: 18,
                maxWidth: false,
                icon: const Icon(Icons.keyboard_arrow_left),
                active: false,
                onTap: state.index>0
                    ? () {
                        context.read<NavigationCubit>().undo();
                      }
                    : null,
              ),
              Button(
                '',
                width: 40,
                height: 40,
                iconSize: 18,
                maxWidth: false,
                icon: const Icon(Icons.keyboard_arrow_right),
                active: false,
                onTap: context.read<NavigationCubit>().canRedo
                    ? () {
                        context.read<NavigationCubit>().redo();
                      }
                    : null,
              ),
            ],
          ),
          Divider(
            height: 16,
            endIndent: 0,
            thickness: 1,
            color: Colors.black.withValues(alpha: 0.08),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 1,
                child: BlocBuilder<ConnectivityCubit, bool>(
                  builder: (context, state) {
                    return Stack(
                      children: [
                        Button(
                          'Sync',
                          width: 84,
                          height: 40,
                          iconSize: 14,
                          maxWidth: false,
                          icon: BlocBuilder<NavigationCubit, NavigationState>(
                            builder: (context, navState) {
                              return navState is NavigationLoading
                                  ? const SizedBox(
                                      width: 15,
                                      height: 15,
                                      child: CircularProgressIndicator(
                                        color: Colors.black38,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Icon(
                                      state
                                          ? Icons.sync
                                          : Icons.cloud_off_outlined,
                                    );
                            },
                          ),
                          active: false,
                          onTap: state
                              ? () {
                                  context.read<NavigationCubit>().sync();
                                }
                              : null,
                        ),
                        Positioned(
                            top: 0,
                            right: 8,
                            child: Container(
                              height: 12,
                              width: 12,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                color: (state ? Colors.green : Colors.red),
                              ),
                            )),
                      ],
                    );
                  },
                ),
              ),
              Button(
                '⌘K',
                width: 84,
                height: 40,
                iconSize: 14,
                maxWidth: true,
                icon: const Icon(Icons.search),
                active: false,
                onTap: () {
                  onTapCollapse();
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
            ],
          ),
          Button(
            'Journals',
            height: 40,
            maxWidth: true,
            icon: const Icon(Icons.calendar_today_outlined),
            active: state.journalNav,
            onTap: () {
              onTapCollapse();
              context
                  .read<NavigationCubit>()
                  .navigateTo(RouteState.journalSelected);
            },
          ),
          Button(
            'Pages',
            height: 40,
            maxWidth: true,
            icon: const Icon(Icons.summarize_outlined),
            active: state.pagesNav,
            onTap: () {
              onTapCollapse();
              context.read<NavigationCubit>().navigateTo(RouteState.pages);
            },
          ),
          Divider(
            height: 12,
            endIndent: 0,
            thickness: 1,
            color: Colors.black.withValues(alpha: 0.08),
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
            children: [
              Button(
                'Settings',
                width: 120,
                maxWidth: true,
                icon: const Icon(Icons.settings_outlined),
                active: state.settingsNav,
                onTap: () {
                  onTapCollapse();
                  context
                      .read<NavigationCubit>()
                      .navigateTo(RouteState.settings);
                },
              ),
              Button(
                '⌘',
                width: 60,
                iconSize: 18,
                maxWidth: true,
                icon: const Icon(Icons.help_outline_outlined),
                active: false,
                onTap: () {
                  openHelpMenu(context);
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
