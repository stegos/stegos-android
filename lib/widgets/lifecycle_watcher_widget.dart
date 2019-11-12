import 'package:flutter/widgets.dart';
import 'package:stegos_wallet/log/loggable.dart';

class LifecycleWatcher extends StatefulWidget {
  final Widget Function(BuildContext context, AppLifecycleState state) builder;
  final Future<void> Function(AppLifecycleState state) stateHandler;

  LifecycleWatcher({Key key, @required this.stateHandler, @required this.builder})
      : super(key: key);

  @override
  _LifecycleWatcherState createState() => _LifecycleWatcherState();
}

class _LifecycleWatcherState extends State<LifecycleWatcher>
    with WidgetsBindingObserver, Loggable<LifecycleWatcher> {
  AppLifecycleState _lastState;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    widget.stateHandler(state).then((_) {
      setState(() {
        _lastState = state;
      });
    }).catchError((err, st) {
      log.severe('App state handler throws error', err, st);
    });
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _lastState);
}
