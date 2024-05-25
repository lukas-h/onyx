import 'package:counter_note/model.dart';
import 'package:counter_note/parser.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nanoid/nanoid.dart';

class CounterState extends Equatable {
  final String uid;
  final List<ListItemModel> items;
  final int index;
  final num sum;

  CounterState(this.items, this.index, this.sum) : uid = nanoid();

  @override
  List<Object?> get props => [uid];

  CounterState copyWith({
    String? uid,
    List<ListItemModel>? items,
    int? index,
  }) {
    return CounterState(
      items ?? this.items,
      index ?? this.index,
      sum,
    );
  }
}

class CounterCubit extends Cubit<CounterState> {
  CounterCubit() : super(CounterState(const [], 0, 0));

  num calculateUntil(List<ListItemModel> items, int untilIndex) {
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

  void update(int index, ListItemModel model) {
    final items = List.of(state.items, growable: true);
    items[index] = Parser.parse(model);
    emit(
      CounterState(
        items,
        state.index,
        calculateUntil(items, items.length),
      ),
    );
  }

  void remove(int index) {
    if (state.items.isEmpty) return;
    final items = List.of(state.items, growable: true);
    items.removeAt(index);
    emit(
      CounterState(
        items,
        items.length - 1,
        calculateUntil(items, items.length),
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
    print(state.items.map((e) => '${e.checked}').join(', '));
  }

  void add(ListItemModel model) {
    final items = List.of(state.items, growable: true);
    var item = Parser.parse(model);
    if (state.items.isNotEmpty) {
      item = item.copyWith(indent: state.items.last.indent);
    }
    items.add(item);
    emit(
      CounterState(
        items,
        items.length - 1,
        calculateUntil(items, items.length),
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
      CounterState(
        items,
        newIndex,
        calculateUntil(items, items.length),
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
