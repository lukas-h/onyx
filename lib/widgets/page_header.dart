import 'package:flutter/material.dart';

class PageHeader extends StatelessWidget {
  final List<Widget> buttons;
  final Widget title;
  const PageHeader({super.key, required this.buttons, required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 56),
          child: Align(
            alignment: Alignment.centerRight,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.only(left: 12, top: 12, right: 12),
              child: Row(
                children: [
                  ...buttons,
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: title,
        ),
      ],
    );
  }
}
