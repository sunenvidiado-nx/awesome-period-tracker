import 'dart:math' as math;

import 'package:awesome_period_tracker/core/app_assets.dart';
import 'package:awesome_period_tracker/core/app_colors.dart';
import 'package:awesome_period_tracker/core/extensions/string_extensions.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

part 'cycle_event_type.mapper.dart';

@MappableEnum()
enum CycleEventType {
  period,
  intimacy,
  symptoms,
  fertile;

  String get label => name.capitalize();

  Color get color {
    return switch (this) {
      CycleEventType.period => AppColors.red,
      CycleEventType.intimacy => AppColors.orange,
      CycleEventType.fertile => AppColors.green,
      CycleEventType.symptoms => AppColors.black.withAlpha(100),
    };
  }

  Widget get icon {
    return switch (this) {
      CycleEventType.period => SvgPicture.asset(
          AppAssets.mainIconNoBackground,
          height: 14,
        ),
      CycleEventType.intimacy => Icon(
          Icons.favorite,
          color: color,
          size: 18,
        ),
      CycleEventType.fertile => Transform.rotate(
          angle: math.pi / 4,
          child: Icon(
            Icons.hdr_strong,
            color: color,
            size: 18,
          ),
        ),
      CycleEventType.symptoms => Icon(
          Icons.emergency_rounded,
          color: color,
          size: 18,
        ),
    };
  }
}
