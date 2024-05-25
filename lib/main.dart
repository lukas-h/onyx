import 'package:counter_note/cubit.dart';
import 'package:counter_note/keyboard.dart';
import 'package:counter_note/list.dart';
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
      create: (context) => CounterCubit(),
      child: MaterialApp(
        title: 'Counter Note',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const Scaffold(
          body: KeyboardInterceptor(child: ChecklistView()),
        ),
      ),
    );
  }
}
