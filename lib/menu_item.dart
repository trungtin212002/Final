import 'package:flutter/material.dart';

class MenuItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback? onTap;

  const MenuItem({required this.icon, required this.text, this.onTap});

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool isHovered = false;
        return MouseRegion(
          onEnter: (_) => setState(() => isHovered = true),
          onExit: (_) => setState(() => isHovered = false),
          child: Container(
            color: isHovered ? Colors.red[100] : Colors.transparent,
            child: ListTile(
              leading: Icon(icon),
              title: Text(text),
              onTap: onTap,
            ),
          ),
        );
      },
    );
  }
}