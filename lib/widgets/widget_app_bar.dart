import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stegos_wallet/ui/themes.dart';

final kWidgetAppBarOverlayStyle = SystemUiOverlayStyle.dark.copyWith(
  statusBarColor: StegosColors.white,
);

/// AppBarWidget with custom design.
///
/// See also:
/// * https://flutter.github.io/assets-for-api-docs/assets/material/app_bar.png
///
///
class AppBarWidget extends AppBar {
  AppBarWidget(
      {Key key,
      Widget title,
      Widget leading,
      Widget bottomChild,
      List<Widget> actions,
      ThemeData theme,
      Brightness brightness,
      Color backgroundColor,
      bool centerTitle = true,
      bool automaticallyImplyLeading = true,
      double bottomChildPrefferedHeight = 0.0,
      bool updateSystemUIOverlay = true})
      : super(
          key: key,
          leading: leading,
          title: title,
          actions: actions,
          centerTitle: centerTitle,
          flexibleSpace: null,
          brightness: brightness ?? theme?.brightness,
          automaticallyImplyLeading: automaticallyImplyLeading,
          textTheme: theme?.primaryTextTheme ?? StegosThemes.appBarTheme.primaryTextTheme,
          bottom: (bottomChild != null && bottomChildPrefferedHeight > 0.0)
              ? _AppBarWidgetBottomContainer(
                  backgroundColor: backgroundColor ?? theme?.backgroundColor ?? StegosColors.white,
                  prefferedHeight: bottomChildPrefferedHeight,
                  child: bottomChild,
                )
              : null,
        ) {
    if (updateSystemUIOverlay) {
      SystemChrome.setSystemUIOverlayStyle(kWidgetAppBarOverlayStyle);
    }
  }
}

class _AppBarWidgetBottomContainer extends StatelessWidget implements PreferredSizeWidget {
  _AppBarWidgetBottomContainer(
      {Key key,
      @required this.child,
      @required this.prefferedHeight,
      @required this.backgroundColor})
      : super(key: key);

  final double prefferedHeight;
  final Color backgroundColor;
  final Widget child;

  @override
  Size get preferredSize => Size.fromHeight(prefferedHeight);

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: StegosThemes.appBarTheme.primaryTextTheme.body1,
      child: Container(
        color: backgroundColor,
        width: double.infinity,
        height: prefferedHeight,
        child: child,
      ),
    );
  }
}
