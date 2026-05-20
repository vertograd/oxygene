library;

import 'package:flutter/material.dart';

import 'src/pipe_drawler.dart';

export 'src/pipe_logic.dart';
export 'src/pipe_drawler.dart';

/// Неинтерактивное превью L-system-генома в стилизованной рамке:
/// рисует геном через [PipeActDrawler] с `fit: true`, оборачивает в
/// [IgnorePointer], чтобы тапы уходили мимо, и кладёт в `Container` с
/// настраиваемым фоном/рамкой/скруглением. Размер по умолчанию не задан —
/// виджет занимает столько, сколько даст родитель.
class Oxygene extends StatelessWidget {
  final String genome;
  final double? width;
  final double? height;
  final Color backgroundColor;
  final Color borderColor;
  final BorderRadiusGeometry borderRadius;

  const Oxygene({
    super.key,
    required this.genome,
    this.width,
    this.height,
    this.backgroundColor = Colors.white,
    this.borderColor = Colors.black26,
    this.borderRadius = const BorderRadius.all(Radius.circular(4)),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: borderColor),
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
