import 'package:counter_note/cubit/navigation_cubit.dart';
import 'package:counter_note/cubit/page_cubit.dart';
import 'package:counter_note/central/keyboard.dart';
import 'package:counter_note/central/navigation.dart';
import 'package:counter_note/persistence/page_store.dart';
import 'package:counter_note/screens/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(const CounterNoteApp());
}

class CounterNoteApp extends StatefulWidget {
  const CounterNoteApp({
    super.key,
  });

  @override
  State<CounterNoteApp> createState() => _CounterNoteAppState();
}

class _CounterNoteAppState extends State<CounterNoteApp> {
  final store = PageStore(
    [],
    [],
  );

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => NavigationCubit(store: store),
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
              store: store),
        ),
      ],
      child: MaterialApp(
        title: 'Counter Note',
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
        home: BlocConsumer<NavigationCubit, NavigationState>(
          listener: (context, state) {
            final currentPage = context.read<NavigationCubit>().currentPage;
            if (currentPage != null) {
              context.read<PageCubit>().selectPage(currentPage);
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
    );
  }
}
