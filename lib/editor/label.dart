import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onyx/cubit/label_cubit.dart';
import 'package:onyx/cubit/page_cubit.dart';
import 'package:onyx/widgets/button.dart';

class LabelButton extends StatefulWidget {
  final String uid;
  const LabelButton({super.key, required this.uid});

  @override
  State<LabelButton> createState() => _LabelButtonState();
}

class _LabelButtonState extends State<LabelButton> {
  final _textController = TextEditingController();
  bool _showDropdown = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LabelCubit, List<String>>(
      builder: (context, labels) {
        return BlocBuilder<PageCubit, PageState>(
          builder: (context, pageState) {
            return Column(
              children: [
                Button(
                  'Labels',
                  maxWidth: false,
                  icon: const Icon(Icons.label_outline),
                  active: false,
                  onTap: () {
                    setState(() {
                      _showDropdown = !_showDropdown;
                    });
                  },
                ),
                if (_showDropdown)
                  Container(
                    width: 200,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          TextField(
                            maxLines: 1,
                            maxLength: 20,
                            controller: _textController,
                            decoration: const InputDecoration(
                              hintText: 'New label...',
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            ),
                          ),
                          Button(
                            'Add',
                            maxWidth: false,
                            icon: const Icon(Icons.add),
                            active: false,
                            onTap: () {
                              if (_textController.text.isNotEmpty) {
                                context.read<LabelCubit>().addLabel(_textController.text);
                                _textController.clear();
                              }
                            },
                          ),
                        ]),
                        const SizedBox(height: 8),
                        ...labels.map((label) {
                          final isSelected = pageState.labels.contains(label);
                          return ListTile(
                            dense: true,
                            title: Text(label),
                            leading: Icon(
                              isSelected ? Icons.label : Icons.label_outline,
                              color: isSelected ? Colors.blue : null,
                            ),
                            onTap: () {
                              final newLabels = List<String>.from(pageState.labels);
                              if (isSelected) {
                                newLabels.remove(label);
                              } else {
                                newLabels.add(label);
                              }
                              context.read<PageCubit>().updateLabels(newLabels);
                            },
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline, size: 16),
                              onPressed: () {
                                context.read<LabelCubit>().removeLabel(label);
                              },
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}
