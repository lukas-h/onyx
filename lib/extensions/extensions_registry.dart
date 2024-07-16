import 'package:onyx/extensions/page_extension.dart';
import 'package:onyx/extensions/settings_extension.dart';

class ExtensionsRegistry {
  final List<SettingsExtension> settingsExtensions;
  final List<PageExtension> pagesExtensions;

  ExtensionsRegistry({
    required this.settingsExtensions,
    required this.pagesExtensions,
  });
}
