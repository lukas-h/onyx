import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  final bool active;
  final Color? borderColor;
  final double? height;
  final Widget icon;
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
    required this.maxWidth,
    required this.onTap,
    this.trailingIcon,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
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
      ),
    );
  }
}
