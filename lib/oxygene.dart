library;

import 'package:flutter/material.dart';

import 'src/genome_short_form.dart';
import 'src/pipe_drawler.dart';

class Oxygene extends StatelessWidget {
  final String genome;
  final double? width;
  final double? height;
  final Color backgroundColor;

  final double leafScale;

  const Oxygene({
    super.key,
    required this.genome,
    this.width,
    this.height,
    this.backgroundColor = Colors.white,
    this.leafScale = 2.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ColoredBox(
        color: backgroundColor,
        child: IgnorePointer(
          child: PipeDrawler(
            genome: GenomeShortForm.expand(genome),
            activeKnot: -1,
            fit: true,
            leafScale: leafScale,
          ),
        ),
      ),
    );
  }
}
