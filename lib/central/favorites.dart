import 'package:collection/collection.dart';
import 'package:counter_note/cubit/favorites_cubit.dart';
import 'package:counter_note/cubit/navigation_cubit.dart';
import 'package:counter_note/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:counter_note/utils/utils.dart';

class FavoritesList extends StatefulWidget {
  const FavoritesList({super.key});

  @override
  State<FavoritesList> createState() => _FavoritesListState();
}

class _FavoritesListState extends State<FavoritesList> {
  bool favoritesExtended = false;
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoritesCubit, List<String>>(
      builder: (context, state) {
        final navCubit = context.read<NavigationCubit>();
        final pages = navCubit.pages;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Button(
              'Favorites',
              maxWidth: true,
              icon: const Icon(Icons.favorite_border),
              trailingIcon: AnimatedRotation(
                turns: favoritesExtended ? 0.5 : 0,
                duration: const Duration(milliseconds: 150),
                child: const Icon(Icons.arrow_drop_down),
              ),
              active: false,
              onTap: () {
                setState(() {
                  favoritesExtended = !favoritesExtended;
                });
              },
            ),
            if (favoritesExtended)
              ...state.map((e) {
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
