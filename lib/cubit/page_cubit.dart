import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:onyx/editor/model.dart';
import 'package:onyx/editor/parser.dart';
import 'package:onyx/store/image_store.dart';
import 'package:onyx/store/page_store.dart';
import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nanoid/nanoid.dart';
import 'package:replay_bloc/replay_bloc.dart';

class PageState extends Equatable {
  final bool isJournal;
  final String title;
  final DateTime created;
  final DateTime modified;
  final String uid;
  final List<ListItemState> items;
  final int index;
  final num sum;
  final List<String> labels;

  ListItemState? get currentItem => index >= 0 ? items[index] : null;

  const PageState({
    required this.isJournal,
    required this.items,
    required this.index,
    required this.sum,
    required this.title,
    required this.created,
    required this.modified,
    required this.uid,
    this.labels = const [],
  });

  @override
  List<Object?> get props => [nanoid()];

  PageState copyWith({
    List<ListItemState>? items,
    int? index,
    String? title,
    List<String>? labels,
  }) {
    return PageState(
      items: items ?? this.items,
      index: index ?? this.index,
      sum: sum,
      created: created,
      modified: modified,
      title: title ?? this.title,
      isJournal: isJournal,
      uid: uid,
      labels: labels ?? this.labels,
    );
  }

  PageModel toPageModel() => PageModel.fromPageState(this);

  factory PageState.fromPageModel(PageModel model, bool isJournal) => PageState(
        items: [
          for (int i = 0; i < model.fullText.length; i++)
            Parser.parse(
              ListItemState.unparsed(
                fullText: model.fullText[i],
                index: i,
                position: model.fullText[i].length,
              ),
            ),
        ],
        index: 0, // TODO use actual index
        sum: 0,
        title: model.title,
        isJournal: isJournal,
        created: model.created,
        modified: model.modified,
        uid: model.uid,
        labels: model.labels,
      );
}

class PageCubit extends ReplayCubit<PageState> {
  final PageStore store;
  final ImageStore imageStore;
  PageCubit(
    super.initialState, {
    required this.store,
    required this.imageStore,
  });

  @override
  void emit(PageState state) {
    if (state.isJournal) {
      store.updateJournal(state.toPageModel());
    } else {
      store.updatePage(state.toPageModel());
    }
    super.emit(state);
  }

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
        modified: state.modified,
        title: state.title,
        isJournal: state.isJournal,
        uid: state.uid,
        labels: state.labels,
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

  void updateLabels(List<String> labels) {
    emit(
      state.copyWith(labels: labels),
    );
  }

  void remove(int index) {
    if (state.items.isEmpty) return;
    final items = List.of(state.items, growable: true);
    items.removeAt(index);
    emit(
      PageState(
        items: items,
        index: index > 0 ? index - 1 : 0,
        sum: calculateUntil(items, items.length),
        created: state.created,
        modified: state.modified,
        title: state.title,
        isJournal: state.isJournal,
        uid: state.uid,
        labels: state.labels,
      ),
    );
  }

  void removeCurrent() => remove(state.index);

  void check(int index) {
    if (state.items.isEmpty) return;
    emit(
      state.copyWith(
        items: state.items.map((e) => e.index == index ? e.copyWith(checked: !e.checked) : e.copyWith()).toList(),
      ),
    );
  }

  void add(ListItemState model) {
    final items = List.of(state.items, growable: true);
    var item = Parser.parse(model);
    if (state.items.isNotEmpty) {
      item = item.copyWith(indent: state.items[state.index].indent);
    }
    if (state.index < (items.length - 1)) {
      items.insert(state.index + 1, item);
    } else {
      items.add(item);
    }
    emit(
      PageState(
        items: items,
        index: items.length == 1 ? 0 : state.index + 1,
        sum: calculateUntil(items, items.length),
        created: state.created,
        modified: state.modified,
        title: state.title,
        isJournal: state.isJournal,
        uid: state.uid,
        labels: state.labels,
      ),
    );
  }

  void index(int i) {
    if (i < state.items.length && ((i > -1 && state.isJournal) || (i >= -1 && !state.isJournal))) {
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

  void skipToNext() {
    final nextIndex = state.index + 1;
    if (nextIndex < state.items.length && state.items[nextIndex].fullText.isEmpty) {
      index(nextIndex);
    } else {
      add(
        ListItemState.unparsed(
          index: state.items.length,
          fullText: '',
          position: 0,
        ),
      );
    }
  }

  void reorder(int oldIndex, int newIndex) {
    final items = List.of(state.items, growable: true);
    final item = items.removeAt(oldIndex);

    if (newIndex < items.length) {
      items.insert(newIndex, item);
    } else {
      items.add(item);
    }

    emit(
      PageState(
        items: items.mapIndexed((i, e) => e.copyWith(index: i)).toList(),
        index: items.indexOf(item),
        sum: calculateUntil(items, items.length),
        created: state.created,
        modified: state.modified,
        title: state.title,
        isJournal: state.isJournal,
        uid: state.uid,
        labels: state.labels,
      ),
    );
  }

  void increaseIndent() {
    if (state.items.isEmpty) return;
    emit(
      state.copyWith(
        items: state.items.map((e) => e.index == state.index ? e.copyWith(indent: e.indent + 1) : e.copyWith()).toList(),
      ),
    );
  }

  void decreaseIndent() {
    if (state.items.isEmpty) return;
    emit(
      state.copyWith(
        items: state.items.map((e) => e.index == state.index && e.indent > 0 ? e.copyWith(indent: e.indent - 1) : e.copyWith()).toList(),
      ),
    );
  }

  Future<void> insertImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    final bytes = await image.readAsBytes();
    final name = image.name;
    final escapedName = name.replaceAll(' ', '_');
    await imageStore.addImage(bytes, escapedName);

    final imageString = '![$name]($escapedName)';

    emit(
      state.copyWith(
        items: state.items
            .map((e) => e.index == state.index
                ? Parser.parse(
                    e.copyWith(fullText: '${e.fullText} $imageString'),
                  )
                : e.copyWith())
            .toList(),
      ),
    );
  }

  void insertInternalLink(String link) => emit(
        state.copyWith(
          items: state.items
              .map((e) => e.index == state.index
                  ? Parser.parse(
                      e.copyWith(fullText: '${e.fullText}[[$link]]'),
                    )
                  : e.copyWith())
              .toList(),
        ),
      );

  void insertExternalLink(String text, String href) => emit(
        state.copyWith(
          items: state.items
              .map((e) => e.index == state.index
                  ? Parser.parse(
                      e.copyWith(fullText: '${e.fullText}[$text]($href)'),
                    )
                  : e.copyWith())
              .toList(),
        ),
      );

  void insertLineFeed() {
    emit(
      state.copyWith(
        items: state.items.map((e) {
          if (e.index == state.index) {
            final chars = e.fullText.characters.toList();
            chars.insert(e.position, '\n');

            return Parser.parse(
              e.copyWith(
                fullText: chars.join(''),
                position: e.position + 1,
              ),
            );
          } else {
            return e.copyWith();
          }
        }).toList(),
      ),
    );
  }

  Future<ImageModel?> getImage(String name) => imageStore.getImageByTitle(name);
}
