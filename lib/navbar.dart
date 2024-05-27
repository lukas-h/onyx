import 'package:counter_note/cubit/navigation_cubit.dart';
import 'package:counter_note/search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SideNavigation extends StatelessWidget {
  final Widget child;
  const SideNavigation({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 190,
          decoration: const BoxDecoration(),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: BlocBuilder<NavigationCubit, NavigationState>(
            builder: (context, state) {
              if (state is NavigationSuccess) {
                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 1,
                          child: NavigationItem(
                            'Sync',
                            icon: const Icon(Icons.sync),
                            active: false,
                            onTap: () {
                              context.read<NavigationCubit>().sync();
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 1,
                          child: NavigationItem(
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
                    NavigationItem(
                      'Journals',
                      icon: const Icon(Icons.calendar_today_outlined),
                      active: state.journalNav,
                      onTap: () {
                        context
                            .read<NavigationCubit>()
                            .navigateTo(RouteState.journals);
                      },
                    ),
                    NavigationItem(
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
                    NavigationItem(
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
                );
              } else {
                return Container();
              }
            },
          ),
        ),
        const VerticalDivider(
          width: 1,
          color: Colors.black38,
          thickness: 1,
        ),
        Expanded(child: child),
      ],
    );
  }
}

class NavigationItem extends StatelessWidget {
  final String title;
  final Widget icon;
  final bool active;
  final double? width;
  final VoidCallback onTap;

  // ignore: use_key_in_widget_constructors
  const NavigationItem(
    this.title, {
    required this.icon,
    required this.active,
    required this.onTap,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(3),
        onTap: onTap,
        child: Container(
          width: width,
          decoration: BoxDecoration(
              color:
                  active ? Colors.black.withOpacity(0.08) : Colors.transparent,
              borderRadius: BorderRadius.circular(3),
              border:
                  Border.all(width: 1, color: Colors.black.withOpacity(0.08))),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              IconTheme(data: const IconThemeData(size: 15), child: icon),
              const SizedBox(width: 8),
              Text(title),
            ],
          ),
        ),
      ),
    );
  }
}
