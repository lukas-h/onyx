import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onyx/cubit/ai_cubit.dart';
import 'package:onyx/cubit/page_cubit.dart';
import 'package:onyx/extensions/page_extension.dart';
import 'package:onyx/widgets/button.dart';

class ChatPageExtension extends PageExtension {
  final TextEditingController _messageController = TextEditingController();

  ChatPageExtension()
      : super(
          activeOnJournals: true,
          activeOnPages: true,
          extensionType: ExtensionDisplayType.sidebar,
        );

  @override
  Widget buildBody(BuildContext context, PageState state) {
    return Container(
        width: 380,
        padding: EdgeInsets.all(8),
        child: BlocBuilder<AiServiceCubit, AiServiceState>(builder: (context, aiState) {
          final chatHistory = aiState.chatHistory;
          final loading = aiState.loading;
          final aiCubit = context.read<AiServiceCubit>();
          return Column(
            spacing: 8,
            children: [
              Expanded(
                  child: ListView.builder(
                itemBuilder: (context, index) => MessageCard(chatHistory[index]),
                itemCount: chatHistory.length,
              )),
              TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Ask anything',
                ),
                onEditingComplete: () {
                  aiCubit.sendMessage(_messageController.text, state.toPageModel().toMarkdown());
                  _messageController.clear();
                },
              ),
              if (loading)
                const Icon(
                  Icons.rocket_launch,
                  size: 42,
                )
              else
                Button(
                  'Send',
                  maxWidth: false,
                  icon: const Icon(Icons.done),
                  active: false,
                  onTap: () {
                    aiCubit.sendMessage(_messageController.text, state.toPageModel().toMarkdown());
                    _messageController.clear();
                  },
                ),
            ],
          );
        }));
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

class MessageCard extends StatelessWidget {
  final AiChatModel message;
  const MessageCard(
    this.message, {
    super.key,
  });

  bool get _isAi {
    return message.source == ContextSource.ai;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: _isAi ? Alignment.bottomLeft : Alignment.bottomRight,
      margin: EdgeInsets.all(8),
      padding: EdgeInsets.all(8),
      child: Card(
        color: _isAi ? Colors.lightBlue : Colors.grey[200],
        child: Padding(padding: EdgeInsets.all(8), child: Text(message.text)),
      ),
    );
  }
}
