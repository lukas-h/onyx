import 'package:flutter/material.dart';

class PageHeader extends StatelessWidget {
  final List<Widget> buttons;
  final Widget title;
  const PageHeader({super.key, required this.buttons, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 0.0),
      child: LayoutBuilder(builder: (context, constraints) {
        if (constraints.maxWidth >= 700) {
          return ListTile(
            title: title,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: buttons,
            ),
          );
        } else {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const SizedBox(width: 50),
                    ...buttons,
                    const SizedBox(width: 24),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: title,
              ),
            ],
          );
        }
      }),
    );
  }
}
