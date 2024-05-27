import 'package:counter_note/cubit/page_cubit.dart';
import 'package:counter_note/list.dart';
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
              ),
            );
          },
        ),
        const Expanded(child: ChecklistView()),
      ],
    );
  }
}
