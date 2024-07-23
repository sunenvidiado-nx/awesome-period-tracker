import 'package:flutter/material.dart';

extension ColorExtensions on Color {
  Color darken([double? amount]) {
    if (amount == null) {
      return this;
    }

    if (amount < 0) {
      throw ArgumentError('Amount must be a positive number');
    }

    if (amount > 1) {
      throw ArgumentError('Amount must be less than or equal to 1');
    }

    final hsl = HSLColor.fromColor(this);
    final hslDarkened =
        hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

    return hslDarkened.toColor();
  }
}
