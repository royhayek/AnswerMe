import 'package:flutter/material.dart';

class AppBarLeadingButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.chevron_left, color: Colors.black, size: 33),
      onPressed: () => Navigator.pop(context),
    );
  }
}
