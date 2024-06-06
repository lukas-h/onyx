import 'package:onyx/cubit/navigation_cubit.dart';
import 'package:onyx/cubit/page_cubit.dart';
import 'package:onyx/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DeleteButton extends StatelessWidget {
  final PageState state;
  const DeleteButton({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return Button(
      'Delete page',
      maxWidth: false,
      icon: const Icon(Icons.delete_outline_outlined),
      onTap: () async {
        final delete = await showDialog(
          context: context,
          builder: (context) => const DeleteDialog(),
        );
        if (delete && context.mounted) {
          context.read<NavigationCubit>().deletePage(state.uid);
        }
      },
      active: false,
    );
  }
}

class DeleteDialog extends StatelessWidget {
  const DeleteDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 350, maxWidth: 350),
        child: const Text(
          'DANGER: Are you sure\nyou want to delete this page?',
          textAlign: TextAlign.center,
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Button(
              'Cancel',
              maxWidth: false,
              icon: const Icon(Icons.close),
              active: false,
              onTap: () {
                Navigator.pop(context, false);
              },
            ),
            Button(
              'Delete page',
              maxWidth: false,
              icon: const Icon(
                Icons.delete_outline_outlined,
                color: Colors.red,
              ),
              active: false,
              onTap: () {
                Navigator.pop(context, true);
              },
            ),
          ],
        ),
      ],
    );
  }
}
