library;

import 'package:flutter/material.dart';

import 'src/pipe_drawler.dart';

class Oxygene extends StatelessWidget {
  final String genome;
  final double? width;
  final double? height;

  const Oxygene({
    super.key,
    required this.genome,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: IgnorePointer(
        child: PipeDrawler(
          genome: genome,
          activeKnot: -1,
          fit: true,
        ),
      ),
    );
  }
}
