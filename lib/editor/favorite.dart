import 'package:counter_note/cubit/favorites_cubit.dart';
import 'package:counter_note/widgets/button.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FavoriteButton extends StatelessWidget {
  final String uid;
  const FavoriteButton({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<FavoritesCubit, List<String>, bool>(
      selector: (state) {
        return state.contains(uid);
      },
      builder: (context, state) {
        return Button(
          '${state ? 'Remove' : 'Add'} favorite',
          maxWidth: false,
          icon: Icon(state ? Icons.favorite : Icons.favorite_outline),
          active: false,
          onTap: () {
            final cubit = context.read<FavoritesCubit>();
            if (state) {
              cubit.remove(uid);
            } else {
              cubit.add(uid);
            }
          },
        );
      },
    );
  }
}
