import 'package:counter_note/editor/model.dart';
import 'package:counter_note/editor/parser.dart';
import 'package:counter_note/persistence/page_store.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nanoid/nanoid.dart';

class PageState extends Equatable {
  final String title;
  final DateTime created;
  final String uid;
  final List<ListItemState> items;
  final int index;
  final num sum;

  PageState({
    required this.items,
    required this.index,
    required this.sum,
    required this.title,
    required this.created,
  }) : uid = nanoid();

  @override
  List<Object?> get props => [uid];

  PageState copyWith({
    String? uid,
    List<ListItemState>? items,
    int? index,
    String? title,
  }) {
    return PageState(
      items: items ?? this.items,
      index: index ?? this.index,
      sum: sum,
      created: created,
      title: title ?? this.title,
    );
  }

  PageModel toPageModel() => PageModel.fromPageState(this);

// TODO
  factory PageState.fromPageModel(PageModel model) => PageState(
        items:
            model.fullText.map((e) => Parser.parse(ListItemState.e)).toList(),
        index: model.fullText.length - 1,
        sum: 0,
        title: '',
        created: DateTime.now(), // TODO
      );
}

class PageCubit extends Cubit<PageState> {
  PageCubit(super.initialState);

  void selectPage(PageState newPage) {
    emit(newPage);
  }

  num calculateUntil(List<ListItemState> items, int untilIndex) {
    final limit = untilIndex < items.length ? untilIndex : items.length;
    num sum = 0;
    for (int i = 0; i < limit; i++) {
      final item = items[i];
      switch (item.operator) {
        case Operator.add:
          sum += item.number ?? 0;
          break;
        case Operator.subtract:
          sum -= item.number ?? 0;
          break;
        case Operator.multiply:
          sum *= item.number ?? 1;
          break;
        case Operator.divide:
          sum /= item.number ?? 1;
          break;
        default:
          break;
      }
    }
    return sum;
  }

  void update(int index, ListItemState model) {
    final items = List.of(state.items, growable: true);
    items[index] = Parser.parse(model);
    emit(
      PageState(
        items: items,
        index: state.index,
        sum: calculateUntil(items, items.length),
        created: state.created,
        title: state.title,
      ),
    );
  }

  void updateTitle(String title) {
    emit(
      state.copyWith(
        title: title,
      ),
    );
  }

  void remove(int index) {
    if (state.items.isEmpty) return;
    final items = List.of(state.items, growable: true);
    items.removeAt(index);
    emit(
      PageState(
        items: items,
        index: items.length - 1,
        sum: calculateUntil(items, items.length),
        created: state.created,
        title: state.title,
      ),
    );
  }

  void removeCurrent() => remove(state.index);

  void check(int index) {
    if (state.items.isEmpty) return;
    emit(
      state.copyWith(
        items: state.items
            .map((e) => e.index == index
                ? e.copyWith(checked: !e.checked)
                : e.copyWith())
            .toList(),
      ),
    );
  }

  void add(ListItemState model) {
    final items = List.of(state.items, growable: true);
    var item = Parser.parse(model);
    if (state.items.isNotEmpty) {
      item = item.copyWith(indent: state.items.last.indent);
    }
    items.add(item);
    emit(
      PageState(
        items: items,
        index: items.length - 1,
        sum: calculateUntil(items, items.length),
        created: state.created,
        title: state.title,
      ),
    );
  }

  void index(int i) {
    if (i < state.items.length && i >= 0) {
      emit(state.copyWith(index: i));
    }
  }

  void indexUp() {
    if (state.index > 0) {
      index(state.index - 1);
    }
  }

  void indexDown() {
    if (state.items.isNotEmpty && state.index < state.items.length - 1) {
      index(state.index + 1);
    }
  }

  void reorder(int oldIndex, int newIndex) {
    final items = List.of(state.items, growable: true);
    final item = items.removeAt(oldIndex);
    items.insert(newIndex, item);
    emit(
      PageState(
        items: items,
        index: newIndex,
        sum: calculateUntil(items, items.length),
        created: state.created,
        title: state.title,
      ),
    );
  }

  void increaseIndent() {
    if (state.items.isEmpty) return;
    emit(
      state.copyWith(
        items: state.items
            .map((e) => e.index == state.index
                ? e.copyWith(indent: e.indent + 1)
                : e.copyWith())
            .toList(),
      ),
    );
  }

  void decreaseIndent() {
    if (state.items.isEmpty) return;
    emit(
      state.copyWith(
        items: state.items
            .map((e) => e.index == state.index && e.indent > 0
                ? e.copyWith(indent: e.indent - 1)
                : e.copyWith())
            .toList(),
      ),
    );
  }
}
