import 'package:collection/collection.dart';
import 'package:counter_note/cubit/navigation_cubit.dart';
import 'package:counter_note/utils/utils.dart';
import 'package:counter_note/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RecentsList extends StatefulWidget {
  const RecentsList({super.key});

  @override
  State<RecentsList> createState() => _RecentsListState();
}

class _RecentsListState extends State<RecentsList> {
  bool recentExtended = false;
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationCubit, NavigationState>(
      builder: (context, state) {
        final navCubit = context.read<NavigationCubit>();
        final pages = navCubit.pages;
        final recents = navCubit.recentPages;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Button(
              'Recents',
              maxWidth: true,
              icon: const Icon(Icons.history),
              active: false,
              trailingIcon: AnimatedRotation(
                turns: recentExtended ? 0.5 : 0,
                duration: const Duration(milliseconds: 150),
                child: const Icon(Icons.arrow_drop_down),
              ),
              onTap: () {
                setState(() {
                  recentExtended = !recentExtended;
                });
              },
            ),
            if (recentExtended)
              ...recents.only(10).map((e) {
                final page = pages.singleWhereOrNull((k) => k.uid == e);
                if (page == null) return Container();
                return Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Button(
                    page.title.only(17),
                    maxWidth: true,
                    active: false,
                    onTap: () {
                      navCubit.switchToPage(page.uid);
                    },
                    icon: const Icon(Icons.summarize_outlined),
                    borderColor: Colors.transparent,
                  ),
                );
              }),
          ],
        );
      },
    );
  }
}
