library;

import 'package:flutter/material.dart';

import 'src/pipe_drawler.dart';

export 'src/pipe_logic.dart';
export 'src/pipe_drawler.dart';

class Oxygene extends StatelessWidget {
  final String genome;
  final double? width;
  final double? height;
  final Color backgroundColor;
  final Color borderColor;
  final double borderWidth;
  final BorderRadiusGeometry borderRadius;

  const Oxygene({
    super.key,
    required this.genome,
    this.width,
    this.height,
    this.backgroundColor = Colors.white,
    this.borderColor = Colors.black26,
    this.borderWidth = 1,
    this.borderRadius = const BorderRadius.all(Radius.circular(4)),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: borderColor, width: borderWidth),
        borderRadius: borderRadius,
      ),
      clipBehavior: Clip.antiAlias,
      child: IgnorePointer(
        child: PipeActDrawler(
          genome: genome,
          activeKnot: -1,
          onKnotTap: (_) {},
          fit: true,
        ),
      ),
    );
  }
}
