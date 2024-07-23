import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onyx/cubit/page_cubit.dart';
import 'package:onyx/extensions/page_extension.dart';
import 'package:onyx/extensions/settings_extension.dart';
import 'package:onyx/widgets/button.dart';

class ChatPageExtension extends PageExtension {
  ChatPageExtension()
      : super(
          activeOnJournals: true,
          activeOnPages: true,
          extensionType: ExtensionDisplayType.sidebar,
        );

  @override
  Widget buildBody(BuildContext context, PageState state) {
    return const Center(child: Text('Hi'));
  }

  @override
  Widget buildControlButton(
    BuildContext context,
    PageState state,
    bool opened,
    VoidCallback onOpen,
  ) {
    return Button(
      'AI Chat',
      icon: const Icon(Icons.mode_comment_outlined),
      active: opened,
      onTap: onOpen,
      maxWidth: false,
    );
  }

  @override
  List<BlocProvider> registerBlocProviders(BuildContext context) => [];

  @override
  List<RepositoryProvider> registerRepositoryProviders(BuildContext context) =>
      [];
}

class ChatSettingsExtension extends SettingsExtension {
  ChatSettingsExtension()
      : super(
          icon: const Icon(Icons.mode_comment_outlined),
          title: 'AI Chat',
        );

  @override
  Widget buildBody(BuildContext context) {
    return TextField(
      controller: TextEditingController(),
      decoration: const InputDecoration(
        border: InputBorder.none,
        hintText: 'OpenAI Key',
      ),
      cursorColor: Colors.black,
      onChanged: (v) {},
    );
  }

  @override
  List<BlocProvider> registerBlocProviders(BuildContext context) => [];

  @override
  List<RepositoryProvider> registerRepositoryProviders(BuildContext context) =>
      [];
}
