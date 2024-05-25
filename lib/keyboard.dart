import 'package:counter_note/cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SearchIntent extends ActivateIntent {
  const SearchIntent();
}

class DeleteLineIntent extends Intent {
  const DeleteLineIntent();
}

class LineUpIntent extends Intent {
  const LineUpIntent();
}

class LineDownIntent extends Intent {
  const LineDownIntent();
}

class KeyboardInterceptor extends StatelessWidget {
  final Widget child;

  const KeyboardInterceptor({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.keyK):
            const SearchIntent(),
        LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.delete):
            const DeleteLineIntent(),
        LogicalKeySet(LogicalKeyboardKey.arrowUp): const LineUpIntent(),
        LogicalKeySet(LogicalKeyboardKey.arrowDown): const LineDownIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          SearchIntent: CallbackAction<Intent>(
            onInvoke: (Intent intent) => _showDialog(context),
          ),
          DeleteLineIntent: CallbackAction<Intent>(
            onInvoke: (Intent intent) =>
                context.read<CounterCubit>().removeCurrent(),
          ),
          LineUpIntent: CallbackAction<Intent>(
            onInvoke: (Intent intent) => context.read<CounterCubit>().indexUp(),
          ),
          LineDownIntent: CallbackAction<Intent>(
            onInvoke: (Intent intent) =>
                context.read<CounterCubit>().indexDown(),
          ),
        },
        child: FocusScope(
          autofocus: true,
          child: child,
        ),
      ),
    );
  }

  Future<dynamic> _showDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => const AlertDialog(
        content: Text('Hi'),
      ),
    );
  }
}
