import 'package:counter_note/cubit/page_cubit.dart';
import 'package:counter_note/editor/list.dart';
import 'package:counter_note/utils/utils.dart';
import 'package:counter_note/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class JournalsScreen extends StatelessWidget {
  const JournalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BlocBuilder<PageCubit, PageState>(
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: ListTile(
                title: Text(
                  state.title,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    BlocBuilder<PageCubit, PageState>(
                      builder: (context, state) {
                        return Button(
                          'Today',
                          icon: const Icon(Icons.today_outlined),
                          onTap: isToday(state.created) ? null : () {},
                          active: isToday(state.created),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    Button(
                      'Next',
                      icon: const Icon(Icons.keyboard_arrow_up),
                      onTap: isToday(state.created) ? null : () {},
                      active: false,
                    ),
                    const SizedBox(width: 8),
                    Button(
                      'Previous',
                      icon: const Icon(Icons.keyboard_arrow_down),
                      onTap: () {},
                      active: false,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const Expanded(child: ChecklistView()),
      ],
    );
  }
}
