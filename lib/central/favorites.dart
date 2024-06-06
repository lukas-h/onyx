import 'package:collection/collection.dart';
import 'package:counter_note/cubit/favorites_cubit.dart';
import 'package:counter_note/cubit/navigation_cubit.dart';
import 'package:counter_note/widgets/button.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

extension on String {
  String only(int max) => max >= (length - 1) ? this : substring(0, max);
}

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
              icon: const Icon(Icons.favorite_border),
              active: favoritesExtended,
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
