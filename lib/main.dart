import 'package:counter_note/cubit/page_cubit.dart';
import 'package:counter_note/keyboard.dart';
import 'package:counter_note/list.dart';
import 'package:counter_note/navbar.dart';
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
    return BlocProvider(
      create: (context) => PageCubit(
        PageState(
          index: 0,
          items: const [],
          pageCreated: DateTime.now(),
          pageTitle: '',
          sum: 0,
        ),
      ),
      child: MaterialApp(
        title: 'Counter Note',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const Scaffold(
          body: KeyboardInterceptor(
            child: SideNavigation(
              child: ChecklistView(),
            ),
          ),
        ),
      ),
    );
  }
}
