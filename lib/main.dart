import 'package:onyx/cubit/favorites_cubit.dart';
import 'package:onyx/cubit/navigation_cubit.dart';
import 'package:onyx/cubit/page_cubit.dart';
import 'package:onyx/central/keyboard.dart';
import 'package:onyx/central/navigation.dart';
import 'package:onyx/cubit/pb_cubit.dart';
import 'package:onyx/store/favorite_store.dart';
import 'package:onyx/store/image_store.dart';
import 'package:onyx/store/page_store.dart';
import 'package:onyx/screens/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(const OnyxApp());
}

class OnyxApp extends StatefulWidget {
  const OnyxApp({
    super.key,
  });

  @override
  State<OnyxApp> createState() => _OnyxAppState();
}

class _OnyxAppState extends State<OnyxApp> {
  final store = PageStore();
  final favoriteStore = FavoriteStore();
  final imageStore = ImageStore([]);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => PocketBaseCubit(),
        ),
        BlocProvider(
          create: (context) => NavigationCubit(
            store: store,
            imageStore: imageStore,
          ),
        ),
        BlocProvider(
          create: (context) => FavoritesCubit(store: favoriteStore),
        ),
        BlocProvider(
          create: (context) => PageCubit(
            PageState(
              isJournal: true,
              index: 0,
              pos: 0,
              items: const [],
              created: DateTime.now(),
              title: '',
              sum: 0,
              uid: '',
            ),
            store: store,
            imageStore: imageStore,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'onyx',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
          dialogBackgroundColor: Colors.white,
          dialogTheme: DialogTheme(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(3),
              side: BorderSide(
                width: 1,
                color: Colors.black.withOpacity(0.08),
              ),
            ),
          ),
        ),
        home: BlocListener<PocketBaseCubit, PocketBaseState>(
          listener: (context, state) {
            final navCubit = context.read<NavigationCubit>();
            final favCubit = context.read<FavoritesCubit>();
            if (state is PocketBaseSuccess) {
              store.pbService = state.service;
              imageStore.pbService = state.service;
              favoriteStore.pbService = state.service;
              navCubit.init();
              favCubit.init();
            }
            if (state is PocketBasePrompt || state is PocketBaseError) {
              navCubit.navigateTo(RouteState.settings);
            }
          },
          child: BlocConsumer<NavigationCubit, NavigationState>(
            listener: (context, state) {
              final currentPage = context.read<NavigationCubit>().currentPage;
              if (currentPage != null) {
                context.read<PageCubit>().selectPage(currentPage);
                if (state is NavigationSuccess && state.newPage) {
                  context.read<PageCubit>().index(-1);
                }
              }
            },
            builder: (context, state) => state is NavigationSuccess
                ? const Scaffold(
                    body: KeyboardInterceptor(
                      child: CentralNavigation(),
                    ),
                  )
                : const LoadingScreen(),
          ),
        ),
      ),
    );
  }
}
