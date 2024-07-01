import 'package:flutter/material.dart';

class Shim extends StatelessWidget {
  final double height;

  const Shim({super.key, required this.height});

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: height);
  }
}
