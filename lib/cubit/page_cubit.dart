import 'package:counter_note/editor/model.dart';
import 'package:counter_note/editor/parser.dart';
import 'package:counter_note/store/image_store.dart';
import 'package:counter_note/store/page_store.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nanoid/nanoid.dart';

class PageState extends Equatable {
  final bool isJournal;
  final String title;
  final DateTime created;
  final String uid;
  final List<ListItemState> items;
  final int index;
  final num sum;

  ListItemState? get currentItem => index >= 0 ? items[index] : null;

  const PageState({
    required this.isJournal,
    required this.items,
    required this.index,
    required this.sum,
    required this.title,
    required this.created,
    required this.uid,
  });

  @override
  List<Object?> get props => [nanoid()];

  PageState copyWith({
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
      isJournal: isJournal,
      uid: uid,
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
              ),
            ),
        ],
        index: 0, // TODO use actual index
        sum: 0,
        title: model.title,
        isJournal: isJournal,
        created: model.created,
        uid: model.uid,
      );
}

class PageCubit extends Cubit<PageState> {
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
        title: state.title,
        isJournal: state.isJournal,
        uid: state.uid,
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
        isJournal: state.isJournal,
        uid: state.uid,
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
        isJournal: state.isJournal,
        uid: state.uid,
      ),
    );
  }

  void index(int i) {
    if (i < state.items.length && i >= -1) {
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
    if (nextIndex < state.items.length &&
        state.items[nextIndex].fullText.isEmpty) {
      index(nextIndex);
    } else {
      add(
        ListItemState.unparsed(
          index: state.items.length,
          fullText: '',
        ),
      );
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
        isJournal: state.isJournal,
        uid: state.uid,
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
                      e.copyWith(fullText: '${e.fullText} [[$link]]'),
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
                      e.copyWith(fullText: '${e.fullText} [$text]($href)'),
                    )
                  : e.copyWith())
              .toList(),
        ),
      );

  ImageModel? getImage(String name) => imageStore.getImageByName(name);
}
