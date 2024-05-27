import 'package:flutter/material.dart';

class SideNavigation extends StatelessWidget {
  final Widget child;
  const SideNavigation({super.key, required this.child});

  Widget _navbarItem(
    String title,
    IconData icon,
    bool active, [
    double? width,
  ]) {
    return Container(
      width: width,
      decoration: BoxDecoration(
          color: active ? Colors.black.withOpacity(0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(3),
          border: Border.all(width: 1, color: Colors.black.withOpacity(0.08))),
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 15,
          ),
          const SizedBox(width: 8),
          Text(title)
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 190,
          decoration: const BoxDecoration(),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      flex: 1, child: _navbarItem('Sync', Icons.sync, false)),
                  const SizedBox(width: 8),
                  Expanded(
                      flex: 1, child: _navbarItem('⌘K', Icons.search, false)),
                ],
              ),
              _navbarItem('Journals', Icons.calendar_today_outlined, true),
              _navbarItem('Pages', Icons.summarize_outlined, false),
              _navbarItem('Settings', Icons.settings_outlined, false),
            ],
          ),
        ),
        const VerticalDivider(
          width: 1,
          color: Colors.black38,
          thickness: 1,
        ),
        Expanded(child: child),
      ],
    );
  }
}
