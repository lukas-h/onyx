import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    VoidCallback onOpen,
  );

  Widget buildBody(
    BuildContext context,
    PageState state,
  ); // only builds when opened

  List<BlocProvider> registerBlocProviders(BuildContext context);

  List<RepositoryProvider> registerRepositoryProviders(BuildContext context);
}
