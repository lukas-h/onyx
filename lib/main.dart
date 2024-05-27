import 'package:counter_note/cubit/navigation_cubit.dart';
import 'package:counter_note/cubit/page_cubit.dart';
import 'package:counter_note/keyboard.dart';
import 'package:counter_note/navbar.dart';
import 'package:counter_note/screens/journals.dart';
import 'package:counter_note/screens/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(const CounterNoteApp());
}

class CounterNoteApp extends StatelessWidget {
  const CounterNoteApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
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
        BlocProvider(
          create: (context) => NavigationCubit(),
        ),
      ],
      child: MaterialApp(
        title: 'Counter Note',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: BlocConsumer<NavigationCubit, NavigationState>(
          listener: (context, state) {
            print('Herrrrro ${state.runtimeType}');
            if (state is NavigationSuccess) {
              context.read<PageCubit>().selectPage(state.journals[0]);
            }
          },
          builder: (context, state) => state is NavigationSuccess
              ? const Scaffold(
                  body: KeyboardInterceptor(
                    child: SideNavigation(
                      child: JournalsScreen(),
                    ),
                  ),
                )
              : const LoadingScreen(),
        ),
      ),
    );
  }
}
