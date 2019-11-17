import 'package:flutter/widgets.dart';
import 'package:stegos_wallet/log/loggable.dart';

class LifecycleWatcher extends StatefulWidget {
  LifecycleWatcher({Key key, @required this.builder}) : super(key: key);

  final Widget Function(BuildContext context, AppLifecycleState state) builder;

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
    setState(() {
      _lastState = state;
    });
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _lastState);
}
