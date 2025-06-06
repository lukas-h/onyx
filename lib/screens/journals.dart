import 'package:onyx/cubit/navigation_cubit.dart';
import 'package:onyx/cubit/page_cubit.dart';
import 'package:onyx/editor/list.dart';
import 'package:onyx/screens/calendarview.dart';
import 'package:onyx/utils/utils.dart';
import 'package:onyx/widgets/button.dart';
import 'package:onyx/widgets/narrow_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onyx/widgets/page_header.dart';

class JournalsScreen extends StatelessWidget {
  const JournalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BlocBuilder<PageCubit, PageState>(
          builder: (context, state) {
            return PageHeader(
              buttons: [
                BlocBuilder<PageCubit, PageState>(
                  builder: (context, state) {
                    return Button(
                      'Today',
                      maxWidth: false,
                      icon: const Icon(Icons.today_outlined),
                      onTap: isToday(state.uid)
                          ? null
                          : () {
                              context.read<NavigationCubit>().switchToTodaysJournal();
                            },
                      active: isToday(state.uid),
                    );
                  },
                ),
                const SizedBox(width: 8),
                Button(
                  'Next',
                  maxWidth: false,
                  icon: const Icon(Icons.keyboard_arrow_up),
                  onTap: isToday(state.uid)
                      ? null
                      : () {
                          context.read<NavigationCubit>().switchToNextJournal();
                        },
                  active: false,
                ),
                const SizedBox(width: 8),
                Button(
                  'Previous',
                  maxWidth: false,
                  icon: const Icon(Icons.keyboard_arrow_down),
                  onTap: () {
                    context.read<NavigationCubit>().switchToPreviousJournal();
                  },
                  active: false,
                ),
                 const SizedBox(width: 8),
                Button(
                  'Calendar',
                  maxWidth: false,
                  icon: const Icon(Icons.calendar_month_outlined),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => CalendarViewScreen(
                      ),
                    );
                  },
                  active: false,
                ),
              ],
              title: Text(
                state.title,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            );
          },
        ),
        const Expanded(
          child: NarrowBody(child: ListEditor()),
        ),
      ],
    );
  }
}
