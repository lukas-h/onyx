import 'package:flutter/services.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:onyx/central/body.dart';
import 'package:onyx/cubit/connectivity_cubit.dart';
import 'package:onyx/cubit/favorites_cubit.dart';
import 'package:onyx/cubit/navigation_cubit.dart';
import 'package:onyx/cubit/page_cubit.dart';
import 'package:onyx/central/keyboard.dart';
import 'package:onyx/central/navigation.dart';
import 'package:onyx/cubit/pb_cubit.dart';
import 'package:onyx/extensions/chat_extension.dart';
import 'package:onyx/extensions/extensions_registry.dart';
import 'package:onyx/hive/hive_registrar.g.dart';
import 'package:onyx/store/favorite_store.dart';
import 'package:onyx/store/image_store.dart';
import 'package:onyx/store/page_store.dart';
import 'package:onyx/screens/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onyx/hive/hive_boxes.dart';
import 'package:onyx/widgets/button.dart';

void main() async {
  await Hive.initFlutter();

  Hive.registerAdapters();

  await Hive.openBox<PageModel>(pageBox);
  await Hive.openBox<PageModel>(journalBox);

  initializeDateFormatting('en_AU');

  runApp(const OnyxApp());
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarBrightness: Brightness.light,
    ),
  );
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
    return RepositoryProvider(
      create: (context) => ExtensionsRegistry(
        pagesExtensions: [
          ChatPageExtension(),
        ],
        settingsExtensions: [
          ChatSettingsExtension(),
        ],
      ),
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => ConnectivityCubit(),
          ),
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
          builder: (context, child) {
            final mediaQueryData = MediaQuery.of(context);
            return MediaQuery(
              data: mediaQueryData.copyWith(textScaler: const TextScaler.linear(1.2)),
              child: child!,
            );
          },
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
            dialogTheme: DialogTheme(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(3),
                side: BorderSide(
                  width: 1,
                  color: Colors.black.withValues(alpha: 0.08),
                ),
              ),
              backgroundColor: Colors.white,
            ),
            fontFamily: 'Futura',
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
                    context.read<PageCubit>().index(0);
                  }
                }
              },
              builder: (context, state) => state is NavigationSuccess ? HomeScreen(state: state) : const LoadingScreen(),
            ),
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final NavigationSuccess state;
  const HomeScreen({
    super.key,
    required this.state,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool expanded = true;
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final wideEnough = constraints.maxWidth >= 700;
      return Scaffold(
        drawer: Drawer(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
            side: BorderSide.none,
          ),
          width: 191,
          child: SafeArea(
            child: NavigationMenu(
              state: widget.state,
              onTapCollapse: () {
                Navigator.pop(context);
              },
            ),
          ),
        ),
        body: SafeArea(
          bottom: false,
          child: KeyboardInterceptor(
            child: Stack(
              children: [
                Row(
                  children: [
                    if (wideEnough && expanded)
                      Builder(builder: (context) {
                        return NavigationMenu(
                          state: widget.state,
                          onTapCollapse: () {
                            setState(() {
                              expanded = false;
                            });
                            Scaffold.of(context).closeDrawer();
                          },
                        );
                      }),
                    if (wideEnough && expanded)
                      const VerticalDivider(
                        width: 1,
                        color: Colors.black26,
                        thickness: 1,
                      ),
                    const Expanded(child: Body()),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Builder(builder: (context) {
                        return Button(
                          '',
                          width: 40,
                          height: 40,
                          iconSize: 18,
                          maxWidth: false,
                          icon: const Icon(Icons.more_horiz_outlined),
                          active: false,
                          onTap: () {
                            if (wideEnough) {
                              setState(() {
                                expanded = !expanded;
                              });
                            } else {
                              Scaffold.of(context).openDrawer();
                            }
                          },
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
