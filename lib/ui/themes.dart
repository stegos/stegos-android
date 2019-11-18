import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

mixin StegosColors {
  static const white = Color(0xfffefefe);
  static const black = Color(0xff000000);
  static const splashBackground = Color(0xff171c29);
  static const backgroundColor = Color(0xff171c29);

  static const primaryColor = Colors.deepOrange;
  static const buttonColor = primaryColor;
  static final primaryColorLight = Colors.orange.shade200;
  static final primaryColorDark = Colors.orange.shade900;
  static const primaryColorBrightness = Brightness.dark;

  //static const accentColor = Color(0xffEFF1F3);
  static const accentColor = Color(0xffe26e04);
  static const accentColorBrightness = Brightness.light;

  static const textSelectionColor = Colors.orangeAccent;

  static final colorScheme = ColorScheme.fromSwatch(
      brightness: Brightness.dark,
      primarySwatch: StegosColors.primaryColor,
      primaryColorDark: StegosColors.primaryColorDark,
      accentColor: StegosColors.accentColor,
      backgroundColor: StegosColors.backgroundColor);
}

mixin StegosDecorators {}

mixin StegosThemes {
  static SystemUiOverlayStyle defaultSystsemOverlay = SystemUiOverlayStyle.dark.copyWith(
      // statusBarColor: StegosColors.black,
      );

  static const defaultPadding = EdgeInsets.all(16.0);

  static const defaultCaptionTextStyle =
      TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xff656565));

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

    colorScheme: StegosColors.colorScheme,
    brightness: StegosColors.colorScheme.brightness,

    primaryColor: StegosColors.colorScheme.primary,
    primaryColorDark: StegosColors.colorScheme.primaryVariant,
    primaryColorBrightness: StegosColors.primaryColorBrightness,
    primaryColorLight: StegosColors.primaryColorLight,
    buttonColor: StegosColors.buttonColor,

    // accentColor: StegosColors.colorScheme.secondary,
    accentColor: StegosColors.accentColor,
    accentColorBrightness: StegosColors.accentColorBrightness,

    backgroundColor: StegosColors.colorScheme.background,
    scaffoldBackgroundColor: StegosColors.colorScheme.background,
    canvasColor: StegosColors.colorScheme.primaryVariant, // BottomNavigationBar
    cardColor: StegosColors.colorScheme.primaryVariant, // Cards

    textSelectionColor: StegosColors.textSelectionColor,
    cursorColor: StegosColors.white,
  );

  static final _baseTextTheme = _defaults.textTheme;

  static final _basePrimaryTextTheme = _defaults.primaryTextTheme;

  static final _baseAccentTextTheme = _defaults.accentTextTheme;

  static final baseTheme = _defaults.copyWith(
      textTheme: _baseTextTheme,
      primaryTextTheme: _basePrimaryTextTheme,
      accentTextTheme: _baseAccentTextTheme,
      buttonTheme: _defaults.buttonTheme.copyWith(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2.0)),
      ));

  static final splashTheme = ThemeData.dark().copyWith(
      backgroundColor: StegosColors.splashBackground, canvasColor: StegosColors.splashBackground);

  static final appBarTheme = baseTheme;

  static final welcomeTheme = baseTheme;
}
