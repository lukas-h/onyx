import 'package:counter_note/cubit/navigation_cubit.dart';
import 'package:counter_note/cubit/page_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PagesScreen extends StatelessWidget {
  const PagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationCubit, NavigationState>(
      builder: (context, state) {
        if (state is NavigationSuccess) {
          return ListView.builder(
            itemBuilder: (context, index) =>
                _PageCard(state: state.pages[index]),
            itemCount: state.pages.length,
          );
        } else {
          return Container();
        }
      },
    );
  }
}

class _PageCard extends StatelessWidget {
  final PageState state;
  const _PageCard({required this.state});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(state.title),
    );
  }
}
