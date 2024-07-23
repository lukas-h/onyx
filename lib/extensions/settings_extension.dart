import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class SettingsExtension {
  final String title;
  final Icon icon;
  SettingsExtension({
    required this.title,
    required this.icon,
  });

  Widget buildBody(BuildContext context); // only builds when opened

  List<BlocProvider> registerBlocProviders(BuildContext context);

  List<RepositoryProvider> registerRepositoryProviders(BuildContext context);
}
