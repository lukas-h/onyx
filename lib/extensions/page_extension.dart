import 'package:flutter/widgets.dart';
import 'package:onyx/cubit/page_cubit.dart';

enum ExtensionDisplayType {
  popup,
  sidebar,
  // …
}

abstract class PageExtension {
  final bool activeOnPages;
  final bool activeOnJournals;
  final ExtensionDisplayType extensionType;
  PageExtension({
    required this.activeOnPages,
    required this.activeOnJournals,
    required this.extensionType,
  });
  Widget buildControlButton(
    BuildContext context,
    PageState state,
    bool opened,
  );

  Widget buildBody(
    BuildContext context,
    PageState state,
  ); // only builds when opened
}
