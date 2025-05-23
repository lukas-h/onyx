import 'package:onyx/central/help.dart';
import 'package:onyx/cubit/navigation_cubit.dart';
import 'package:onyx/cubit/page_cubit.dart';
import 'package:onyx/central/search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io' show Platform;

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

class CreateNewLineIntent extends Intent {
  const CreateNewLineIntent();
}

class LineFeedIntent extends Intent {
  const LineFeedIntent();
}

class IndentIncreaseIntent extends Intent {
  const IndentIncreaseIntent();
}

class IndentDecreaseIntent extends Intent {
  const IndentDecreaseIntent();
}

class ImageInsertIntent extends Intent {
  const ImageInsertIntent();
}

class NextJournalIntent extends Intent {
  const NextJournalIntent();
}

class PreviousJournalIntent extends Intent {
  const PreviousJournalIntent();
}

class PageInsertIntent extends Intent {
  const PageInsertIntent();
}

class LinkInsertIntent extends Intent {
  const LinkInsertIntent();
}

class HelpIntent extends Intent {
  const HelpIntent();
}

class UndoIntent extends Intent {
  const UndoIntent();
}

class RedoIntent extends Intent {
  const RedoIntent();
}

class KeyboardInterceptor extends StatelessWidget {
  final Widget child;

  const KeyboardInterceptor({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PageCubit>();
    final navCubit = context.read<NavigationCubit>();

    final modifierKey = Platform.isMacOS ? LogicalKeyboardKey.meta : LogicalKeyboardKey.control;

    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(modifierKey, LogicalKeyboardKey.keyK): const SearchIntent(),
        LogicalKeySet(modifierKey, LogicalKeyboardKey.delete): const DeleteLineIntent(),
        LogicalKeySet(modifierKey, LogicalKeyboardKey.keyS): const SyncIntent(),
        LogicalKeySet(modifierKey, LogicalKeyboardKey.keyH): const HelpIntent(),
        LogicalKeySet(modifierKey, LogicalKeyboardKey.keyZ): const UndoIntent(),
        LogicalKeySet(
          modifierKey,
          LogicalKeyboardKey.shift,
          LogicalKeyboardKey.keyZ,
        ): const RedoIntent(),
        LogicalKeySet(modifierKey, LogicalKeyboardKey.enter): const CreateNewLineIntent(),
        LogicalKeySet(modifierKey, LogicalKeyboardKey.keyI): const ImageInsertIntent(),
        LogicalKeySet(modifierKey, LogicalKeyboardKey.arrowUp): const NextJournalIntent(),
        LogicalKeySet(modifierKey, LogicalKeyboardKey.arrowDown): const PreviousJournalIntent(),
        LogicalKeySet(modifierKey, LogicalKeyboardKey.keyR): const PageInsertIntent(),
        LogicalKeySet(modifierKey, LogicalKeyboardKey.keyL): const LinkInsertIntent(),
        LogicalKeySet(LogicalKeyboardKey.arrowUp): const LineUpIntent(),
        LogicalKeySet(LogicalKeyboardKey.arrowDown): const LineDownIntent(),
        LogicalKeySet(LogicalKeyboardKey.enter): const LineFeedIntent(),
        LogicalKeySet(LogicalKeyboardKey.tab): const IndentIncreaseIntent(),
        LogicalKeySet(LogicalKeyboardKey.shift, LogicalKeyboardKey.tab): const IndentDecreaseIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          SearchIntent: CallbackAction<Intent>(
            onInvoke: (_) => _showSearchMenu(context),
          ),
          DeleteLineIntent: CallbackAction<Intent>(
            onInvoke: (_) => cubit.removeCurrent(),
          ),
          LineUpIntent: CallbackAction<Intent>(
            onInvoke: (_) => cubit.indexUp(),
          ),
          LineDownIntent: CallbackAction<Intent>(
            onInvoke: (_) => cubit.indexDown(),
          ),
          CreateNewLineIntent: CallbackAction<Intent>(
            onInvoke: (_) => cubit.skipToNext(),
          ),
          LineFeedIntent: CallbackAction<Intent>(
            onInvoke: (_) => cubit.insertLineFeed(),
          ),
          IndentIncreaseIntent: CallbackAction<Intent>(
            onInvoke: (_) => cubit.increaseIndent(),
          ),
          IndentDecreaseIntent: CallbackAction<Intent>(
            onInvoke: (_) => cubit.decreaseIndent(),
          ),
          SyncIntent: CallbackAction<Intent>(
            onInvoke: (_) => navCubit.sync(),
          ),
          ImageInsertIntent: CallbackAction<Intent>(
            onInvoke: (_) => cubit.insertImage(),
          ),
          NextJournalIntent: CallbackAction<Intent>(
            onInvoke: (_) => navCubit.switchToNextJournal(),
          ),
          PreviousJournalIntent: CallbackAction<Intent>(
            onInvoke: (_) => navCubit.switchToPreviousJournal(),
          ),
          PageInsertIntent: CallbackAction<Intent>(
            onInvoke: (_) => _showInsertMenu(context),
          ),
          HelpIntent: CallbackAction<Intent>(
            onInvoke: (_) => openHelpMenu(context),
          ),
          UndoIntent: CallbackAction<Intent>(
            onInvoke: (_) {
              if (cubit.canUndo) {
                cubit.undo();
              }
              return;
            },
          ),
          RedoIntent: CallbackAction<Intent>(
            onInvoke: (_) {
              if (cubit.canRedo) {
                cubit.redo();
              }
              return;
            },
          ),
        },
        child: FocusScope(
          autofocus: true,
          child: child,
        ),
      ),
    );
  }

  Future<dynamic> _showSearchMenu(BuildContext context) => openSearchMenu(
        context,
        onSelect: (context, state) {
          Navigator.pop(context);
          final cubit = context.read<NavigationCubit>();
          if (state == null) return;
          if (state.isJournal) {
            cubit.switchToJournal(state.uid);
          } else {
            cubit.switchToPage(state.uid);
          }
        },
      );

  Future<dynamic> _showInsertMenu(BuildContext context) async {
    final cubit = context.read<PageCubit>();
    final page = await openInsertMenu(context);
    if (page != null) {
      cubit.insertInternalLink(page.title);
    }
  }
}
