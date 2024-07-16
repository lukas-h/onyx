import 'package:flutter/widgets.dart';

abstract class SettingsExtension {
  final String title;
  final Icon icon;
  SettingsExtension({
    required this.title,
    required this.icon,
  });

  Widget buildBody(BuildContext context); // only builds when opened
}
