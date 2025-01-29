import 'dart:ui';

import 'package:flutter/material.dart';

List<Widget> Myfilter() {
  return [
    Align(
      alignment: const AlignmentDirectional(3, -0.3),
      child: Container(
        height: 300,
        width: 300,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.deepOrangeAccent,
        ),
      ),
    ),
    Align(
      alignment: const AlignmentDirectional(-3, -0.3),
      child: Container(
        height: 300,
        width: 300,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.deepOrangeAccent,
        ),
      ),
    ),
    Align(
      alignment: const AlignmentDirectional(0, -1.2),
      child: Container(
        height: 300,
        width: 600,
        decoration: const BoxDecoration(
          color: Colors.deepPurple,
        ),
      ),
    ),
    // Blur Effect
    BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
      child: Container(
        decoration: const BoxDecoration(color: Colors.transparent),
      ),
    ),
  ];
}
