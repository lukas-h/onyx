import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  final String title;
  final Widget icon;
  final bool active;
  final double? width;
  final VoidCallback? onTap;
  final Color? borderColor;
  final Widget? trailingIcon;
  final bool maxWidth;

  // ignore: use_key_in_widget_constructors
  const Button(
    this.title, {
    required this.icon,
    required this.active,
    required this.onTap,
    this.width,
    this.borderColor,
    this.trailingIcon,
    required this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: InkWell(
        enableFeedback: onTap != null,
        borderRadius: BorderRadius.circular(3),
        onTap: onTap,
        child: Container(
          width: width,
          decoration: BoxDecoration(
            color: active ? Colors.black.withOpacity(0.08) : Colors.transparent,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(
              width: 1,
              color: borderColor ?? Colors.black.withOpacity(0.08),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: IconTheme(
            data: IconThemeData(
              size: 15,
              color: onTap != null ? Colors.black : Colors.black38,
            ),
            child: Row(
              mainAxisSize: maxWidth ? MainAxisSize.max : MainAxisSize.min,
              children: [
                icon,
                if (title.isNotEmpty) const SizedBox(width: 8),
                if (title.isNotEmpty)
                  Text(
                    title,
                    style: TextStyle(
                      color: onTap != null ? Colors.black : Colors.black38,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                if (trailingIcon != null && title.isNotEmpty) trailingIcon!,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
