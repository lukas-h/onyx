import 'package:counter_note/cubit/navigation_cubit.dart';
import 'package:counter_note/cubit/page_cubit.dart';
import 'package:counter_note/central/keyboard.dart';
import 'package:counter_note/central/navigation.dart';
import 'package:counter_note/screens/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(const CounterNoteApp());
}

class CounterNoteApp extends StatelessWidget {
  const CounterNoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => NavigationCubit(),
        ),
        BlocProvider(
          create: (context) => PageCubit(
            PageState(
              index: 0,
              items: const [],
              created: DateTime.now(),
              title: '',
              sum: 0,
            ),
          ),
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
            if (state is NavigationSuccess && state.currentPage != null) {
              context.read<PageCubit>().selectPage(state.currentPage!);
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
