import 'dart:math';

import 'package:flutter/material.dart';

class CircleProgress extends CustomPainter {
  final double value; // Solo se declara como 'double'
  final bool isTemp;

  // Convertimos 'value' a double directamente en el constructor
  CircleProgress(num value, this.isTemp) : value = value.toDouble(); // Convertimos 'value' a 'double'

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

  @override
  void paint(Canvas canvas, Size size) {
    int maximumValue = isTemp ? 50 : 100; // Temp´s max is 50, humidity´s max is 100

    // Ajustar los valores para evitar que se dibujen valores negativos
    num safeValue = value < 0 ? 0 : value > maximumValue ? maximumValue : value;

    Paint outerCircle = Paint()
      ..strokeWidth = 14
      ..color = Colors.grey
      ..style = PaintingStyle.stroke;

    Paint tempArc = Paint()
      ..strokeWidth = 14
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    Paint humidityArc = Paint()
      ..strokeWidth = 14
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    Offset center = Offset(size.width / 2, size.height / 2);
    double radius = min(size.width / 2, size.height / 2) - 14;

    // Dibujar el círculo exterior
    canvas.drawCircle(center, radius, outerCircle);

    // Calcular el ángulo en función del valor de progreso
    double angle = 2 * pi * (safeValue / maximumValue);

    // Dibujar el arco (ya sea temperatura o humedad)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      angle,
      false,
      isTemp ? tempArc : humidityArc,
    );
  }
}
