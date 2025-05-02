import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onyx/cubit/ai_cubit.dart';
import 'package:onyx/cubit/page_cubit.dart';
import 'package:onyx/extensions/page_extension.dart';
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
    final chatHistory = context.read<AiServiceCubit>().chatHistory;
    return Container(
      width: 380,
      padding: EdgeInsets.all(8),
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemBuilder: (context, index) => PageCard(
                state: pages[index],
                onTap: () {
                  context.read<NavigationCubit>().switchToPage(pages[index].uid);
                },
              ),
              itemCount: pages.length,
            ),
          )
        ],
      ),
    );
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
  List<RepositoryProvider> registerRepositoryProviders(BuildContext context) => [];
}
