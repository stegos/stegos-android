import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

mixin StegosColors {
  static const white = Color(0xffffffff);
  static const black = Color(0xff000000);
  static const splashBackground = Color(0xff15151f);
  static const backgroundColor = Color(0xff343946);

  static const primaryColor = MaterialColor(0xffff6c00, {
    50: Color.fromRGBO(255, 108, 0, .1),
    100: Color.fromRGBO(255, 108, 0, .2),
    200: Color.fromRGBO(255, 108, 0, .3),
    300: Color.fromRGBO(255, 108, 0, .4),
    400: Color.fromRGBO(255, 108, 0, .5),
    500: Color.fromRGBO(255, 108, 0, .6),
    600: Color.fromRGBO(255, 108, 0, .7),
    700: Color.fromRGBO(255, 108, 0, .8),
    800: Color.fromRGBO(255, 108, 0, .9),
    900: Color.fromRGBO(255, 108, 0, 1),
  });
  static const buttonColor = primaryColor;
  static final primaryColorLight = Colors.orange.shade200;
  static const primaryColorDark = Color(0xff7d8b97);
  static const primaryColorBrightness = Brightness.dark;

  //static const accentColor = Color(0xffEFF1F3);
  static const accentColor = Color(0xffe26e04);
  static const accentColorBrightness = Brightness.light;

  static const textSelectionColor = Colors.orangeAccent;

  static const errorColor = Color(0xffff3c3c);

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

  static const defaultPadding = EdgeInsets.all(30.0);

  static const defaultPaddingHorizontal = EdgeInsets.symmetric(horizontal: 30.0, vertical: 5.0);

  static const defaultPaddingVertical = EdgeInsets.symmetric(vertical: 30.0);

  static const defaultCaptionTextStyle =
      TextStyle(fontWeight: FontWeight.w500, fontSize: 18, color: Color(0xffffffff));

  static const defaultSubCaptionTextStyle =
      TextStyle(fontWeight: FontWeight.w300, fontSize: 14, color: Color(0xffffffff));

  static const defaultInputTextStyle =
      TextStyle(fontWeight: FontWeight.normal, fontSize: 16, color: Color(0xffffffff));

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
    canvasColor: StegosColors.colorScheme.primaryVariant,
    // BottomNavigationBar
    cardColor: StegosColors.colorScheme.primaryVariant,
    // Cards

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
    ),
    appBarTheme: const AppBarTheme(
      color: Color(0xff2b2e3b),
      textTheme: TextTheme(body1: TextStyle(fontSize: 20)),
      elevation: 0,
    ),
  );

  static final splashTheme = ThemeData.dark().copyWith(
      backgroundColor: StegosColors.splashBackground, canvasColor: StegosColors.splashBackground);

  static final backupTheme = baseTheme.copyWith(
    buttonTheme: _defaults.buttonTheme.copyWith(
      shape: const RoundedRectangleBorder(),
      textTheme: ButtonTextTheme.accent,
      colorScheme: ColorScheme.fromSwatch(
          primaryColorDark: StegosColors.primaryColorDark,
          accentColor: StegosColors.white,
          backgroundColor: StegosColors.primaryColorDark,
          brightness: Brightness.dark),
      disabledColor: StegosColors.primaryColorDark,
      buttonColor: StegosColors.primaryColor,
      focusColor: StegosColors.white,
      highlightColor: StegosColors.primaryColor,
      hoverColor: StegosColors.primaryColor,
      splashColor: const Color(0xffe26e04),
    ),
    inputDecorationTheme: InputDecorationTheme(
      prefixStyle: defaultInputTextStyle.copyWith(color: Colors.transparent),
      contentPadding: const EdgeInsets.only(left: 40.0, right: 13.0, top: 6.0, bottom: 6.0),
    ),
  );

  static final accountsTheme = baseTheme.copyWith(
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xff15151f), foregroundColor: StegosColors.primaryColor),
      buttonTheme: ButtonThemeData(
          buttonColor: const Color(0xff15151f),
          colorScheme: ColorScheme.fromSwatch(
              primaryColorDark: const Color(0xff15151f),
              accentColor: const Color(0xff15151f),
              backgroundColor: const Color(0xff15151f),
              brightness: Brightness.dark)));

  static final walletTheme = baseTheme.copyWith(
    tabBarTheme: const TabBarTheme(
      labelPadding: EdgeInsets.all(0),
      indicatorSize: TabBarIndicatorSize.label,
      labelColor: StegosColors.primaryColor,
      unselectedLabelColor: StegosColors.primaryColorDark,
      labelStyle:
          TextStyle(color: StegosColors.primaryColor, fontSize: 10, fontWeight: FontWeight.w300),
      unselectedLabelStyle: TextStyle(
          color: StegosColors.primaryColorDark, fontSize: 10, fontWeight: FontWeight.w300),
    ),
  );

  static final appBarTheme = baseTheme;

  static final welcomeTheme = baseTheme;

  static final pinpadTheme = baseTheme;

  static final settingsTheme = baseTheme.copyWith(
    buttonTheme: _defaults.buttonTheme.copyWith(
      shape: const RoundedRectangleBorder(),
      textTheme: ButtonTextTheme.accent,
      colorScheme: ColorScheme.fromSwatch(
          primaryColorDark: StegosColors.primaryColorDark,
          accentColor: StegosColors.white,
          backgroundColor: StegosColors.primaryColorDark,
          brightness: Brightness.dark),
      disabledColor: StegosColors.primaryColorDark,
      buttonColor: StegosColors.primaryColor,
      focusColor: StegosColors.white,
      highlightColor: StegosColors.primaryColor,
      hoverColor: StegosColors.primaryColor,
      splashColor: const Color(0xffe26e04),
    ),
  );

  static final passwordTheme = baseTheme.copyWith(
    buttonTheme: _defaults.buttonTheme.copyWith(
      shape: const RoundedRectangleBorder(),
      textTheme: ButtonTextTheme.accent,
      colorScheme: ColorScheme.fromSwatch(
          primaryColorDark: StegosColors.primaryColorDark,
          accentColor: StegosColors.white,
          backgroundColor: StegosColors.primaryColorDark,
          brightness: Brightness.dark),
      disabledColor: StegosColors.primaryColorDark,
      buttonColor: StegosColors.primaryColor,
      focusColor: StegosColors.white,
      highlightColor: StegosColors.primaryColor,
      hoverColor: StegosColors.primaryColor,
      splashColor: const Color(0xffe26e04),
    ),
    inputDecorationTheme: InputDecorationTheme(
      prefixStyle: defaultInputTextStyle.copyWith(color: Colors.transparent),
      contentPadding: const EdgeInsets.symmetric(horizontal: 13.0, vertical: 6.0),
    ),
  );

  static final AccountTheme = baseTheme;
}
