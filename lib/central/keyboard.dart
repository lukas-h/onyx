import 'package:counter_note/cubit/navigation_cubit.dart';
import 'package:counter_note/cubit/page_cubit.dart';
import 'package:counter_note/central/search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SearchIntent extends ActivateIntent {
  const SearchIntent();
}

class SyncIntent extends ActivateIntent {
  const SyncIntent();
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

class IndentIncreaseIntent extends Intent {
  const IndentIncreaseIntent();
}

class IndentDecreaseIntent extends Intent {
  const IndentDecreaseIntent();
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
        LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.keyS):
            const SyncIntent(),
        LogicalKeySet(LogicalKeyboardKey.arrowUp): const LineUpIntent(),
        LogicalKeySet(LogicalKeyboardKey.arrowDown): const LineDownIntent(),
        LogicalKeySet(LogicalKeyboardKey.tab): const IndentIncreaseIntent(),
        LogicalKeySet(LogicalKeyboardKey.shift, LogicalKeyboardKey.tab):
            const IndentDecreaseIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          SearchIntent: CallbackAction<Intent>(
            onInvoke: (_) => _showDialog(context),
          ),
          DeleteLineIntent: CallbackAction<Intent>(
            onInvoke: (_) => context.read<PageCubit>().removeCurrent(),
          ),
          LineUpIntent: CallbackAction<Intent>(
            onInvoke: (_) => context.read<PageCubit>().indexUp(),
          ),
          LineDownIntent: CallbackAction<Intent>(
            onInvoke: (_) => context.read<PageCubit>().indexDown(),
          ),
          IndentIncreaseIntent: CallbackAction<Intent>(
            onInvoke: (_) => context.read<PageCubit>().increaseIndent(),
          ),
          IndentDecreaseIntent: CallbackAction<Intent>(
            onInvoke: (_) => context.read<PageCubit>().decreaseIndent(),
          ),
          SyncIntent: CallbackAction<Intent>(
            onInvoke: (_) => context.read<NavigationCubit>().sync(),
          )
        },
        child: FocusScope(
          autofocus: true,
          child: child,
        ),
      ),
    );
  }

  Future<dynamic> _showDialog(BuildContext context) => openSearchMenu(context);
}
