import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:stegos_wallet/ui/app.dart';

Future<String> appShowSimpleAskTextDialog(
        {@required String title,
        String intialValue = '',
        String titleCancelButton = 'CANCEL',
        String titleOkayButton = 'OK'}) =>
    appShowDialog(builder: (context) {
      final ctl = TextEditingController(text: intialValue);
      return AlertDialog(
        title: Text(title),
        content: TextField(
          autofocus: false,
          controller: ctl,
        ),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              StegosApp.navigatorState.pop(null);
            },
            child: Text(titleCancelButton),
          ),
          FlatButton(
            onPressed: () {
              StegosApp.navigatorState.pop(ctl.text);
            },
            child: Text(titleOkayButton),
          )
        ],
      );
    });

Future<T> appShowDialog<T>(
    {@required WidgetBuilder builder, BuildContext context, bool barrierDismissible = true}) {
  context ??= StegosApp.navigatorKey.currentContext;
  assert(debugCheckHasMaterialLocalizations(context));
  final ThemeData theme = Theme.of(context, shadowThemeOnly: true);
  return appShowGeneralDialog(
      pageBuilder: (BuildContext buildContext, Animation<double> animation,
          Animation<double> secondaryAnimation) {
        final Widget pageChild = Builder(builder: builder);
        return SafeArea(
          child: Builder(builder: (BuildContext context) {
            return theme != null ? Theme(data: theme, child: pageChild) : pageChild;
          }),
        );
      },
      barrierDismissible: barrierDismissible,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 150),
      transitionBuilder: _buildMaterialDialogTransitions);
}

Widget _buildMaterialDialogTransitions(BuildContext context, Animation<double> animation,
    Animation<double> secondaryAnimation, Widget child) {
  return FadeTransition(
    opacity: CurvedAnimation(
      parent: animation,
      curve: Curves.easeOut,
    ),
    child: child,
  );
}

Future<T> appShowGeneralDialog<T>(
    {@required RoutePageBuilder pageBuilder,
    bool barrierDismissible,
    String barrierLabel,
    Color barrierColor,
    Duration transitionDuration,
    RouteTransitionsBuilder transitionBuilder}) {
  assert(pageBuilder != null);
  assert(!barrierDismissible || barrierLabel != null);
  return StegosApp.navigatorState.push<T>(_DialogRoute<T>(
    pageBuilder: pageBuilder,
    barrierDismissible: barrierDismissible,
    barrierLabel: barrierLabel,
    barrierColor: barrierColor,
    transitionDuration: transitionDuration,
    transitionBuilder: transitionBuilder,
  ));
}

class _DialogRoute<T> extends PopupRoute<T> {
  _DialogRoute({
    @required RoutePageBuilder pageBuilder,
    bool barrierDismissible = true,
    String barrierLabel,
    Color barrierColor = const Color(0x80000000),
    Duration transitionDuration = const Duration(milliseconds: 200),
    RouteTransitionsBuilder transitionBuilder,
    RouteSettings settings,
  })  : assert(barrierDismissible != null),
        _pageBuilder = pageBuilder,
        _barrierDismissible = barrierDismissible,
        _barrierLabel = barrierLabel,
        _barrierColor = barrierColor,
        _transitionDuration = transitionDuration,
        _transitionBuilder = transitionBuilder,
        super(settings: settings);

  final RoutePageBuilder _pageBuilder;

  @override
  bool get barrierDismissible => _barrierDismissible;
  final bool _barrierDismissible;

  @override
  String get barrierLabel => _barrierLabel;
  final String _barrierLabel;

  @override
  Color get barrierColor => _barrierColor;
  final Color _barrierColor;

  @override
  Duration get transitionDuration => _transitionDuration;
  final Duration _transitionDuration;

  final RouteTransitionsBuilder _transitionBuilder;

  @override
  Widget buildPage(
      BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    return Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      child: _pageBuilder(context, animation, secondaryAnimation),
    );
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    if (_transitionBuilder == null) {
      return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.linear,
          ),
          child: child);
    } // Some default transition
    return _transitionBuilder(context, animation, secondaryAnimation, child);
  }
}
