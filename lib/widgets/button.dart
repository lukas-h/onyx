import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  final bool active;
  final Color? borderColor;
  final double? height;
  final Widget icon;
  final double? iconSize;
  final bool maxWidth;
  final VoidCallback? onTap;
  final String title;
  final Widget? trailingIcon;
  final double? width;

  // ignore: use_key_in_widget_constructors
  const Button(
    this.title, {
    required this.active,
    this.borderColor,
    required this.icon,
    this.iconSize,
    required this.maxWidth,
    required this.onTap,
    this.trailingIcon,
    this.width,
    this.height = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      width: width,
      height: height,
      child: InkWell(
        enableFeedback: onTap != null,
        borderRadius: BorderRadius.circular(2),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: active
                ? Colors.black.withValues(alpha: 0.08)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(2),
            border: Border.all(
              width: 1,
              color: borderColor ?? Colors.black.withValues(alpha: 0.08),
            ),
          ),
          padding: EdgeInsets.symmetric(horizontal: title.isNotEmpty ? 4 : 0),
          child: Row(
            mainAxisAlignment: title.isNotEmpty
                ? MainAxisAlignment.start
                : MainAxisAlignment.center,
            spacing: 8,
            children: [
              IconTheme(
                  data: IconThemeData(
                    color: onTap != null ? Colors.black : Colors.black38,
                    size: 14,
                  ),
                  child: icon),
              if (title.isNotEmpty && maxWidth)
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: onTap != null ? Colors.black : Colors.black38,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              if (title.isNotEmpty && !maxWidth)
                Text(
                  title,
                  style: TextStyle(
                    color: onTap != null ? Colors.black : Colors.black38,
                    fontSize: 14,
                  ),
                ),
              if (trailingIcon != null && title.isNotEmpty) trailingIcon!,
            ],
          ),
        ),
      ),
    );
  }
}
