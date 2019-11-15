import 'package:flutter/material.dart';

mixin StegosColors {
  static const white = Color(0xfffefefe);
  static const splashBackground = Color(0xff171c29);
  static final colorScheme = ColorScheme.fromSwatch(/* placeholder */);
}

mixin StegosDecorators {}

mixin StegosThemes {
  static final _defaults = ThemeData(
      fontFamily: 'Roboto',
      typography: Typography(
        platform: TargetPlatform.android,
        englishLike: Typography.englishLike2018,
        dense: Typography.dense2018,
        tall: Typography.tall2018,
        // todo: Review:
        black: Typography.englishLike2018.merge(Typography.blackCupertino),
        white: Typography.englishLike2018.merge(Typography.whiteCupertino),
      ),
      brightness: StegosColors.colorScheme.brightness
      // placeholder
      );

  static final _baseTextTheme = _defaults.textTheme.apply(/* placeholder */);

  static final _basePrimaryTextTheme = _defaults.primaryTextTheme.apply(/* placeholder */);

  static final _baseAccentTextTheme = _defaults.accentTextTheme.apply(/* placeholder */);

  static final baseTheme = _defaults.copyWith(
    accentTextTheme: _baseAccentTextTheme,
  );

  static final splashTheme = ThemeData.dark().copyWith(
      backgroundColor: StegosColors.splashBackground, canvasColor: StegosColors.splashBackground);

  static final welcomeTheme = baseTheme.copyWith(
      buttonTheme: ButtonThemeData(
    buttonColor: const Color(0xffff6c00),
    textTheme: ButtonTextTheme.primary,
    colorScheme: ColorScheme.light(
        primary: const Color(0xffff6c00), primaryVariant: const Color(0xffff7b00)),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2.0)),
  ));
}
