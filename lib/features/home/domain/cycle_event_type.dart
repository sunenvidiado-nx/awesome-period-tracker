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
  symptoms,
  intimacy,
  fertile;

  String get label => name.capitalize();

  Color get color {
    return switch (this) {
      CycleEventType.period => AppColors.pink,
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
      CycleEventType.fertile => CircleAvatar(
          backgroundColor: color,
          radius: 6,
        ),
      CycleEventType.symptoms => Icon(
          Icons.emergency_rounded,
          color: color,
          size: 18,
        ),
    };
  }
}
