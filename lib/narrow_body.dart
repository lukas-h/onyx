import 'package:flutter/material.dart';

class NarrowBody extends StatelessWidget {
  final Widget child;
  const NarrowBody({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 750),
        child: child,
      ),
    );
  }
}
