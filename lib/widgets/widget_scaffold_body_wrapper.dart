import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import 'package:provider/provider.dart';
import 'package:stegos_wallet/env_stegos.dart';
import 'package:stegos_wallet/stores/store_stegos.dart';
import 'package:stegos_wallet/ui/themes.dart';

class ScaffoldBodyWrapperWidget extends StatefulWidget {
  const ScaffoldBodyWrapperWidget(
      {Key key, this.builder, this.wrapInObserver = false})
      : super(key: key);
  final WidgetBuilder builder;
  final bool wrapInObserver;
  @override
  State<StatefulWidget> createState() => ScaffoldBodyWrapperWidgetState();
}

class ScaffoldBodyWrapperWidgetState extends State<ScaffoldBodyWrapperWidget> {
  ErrorState error;
  bool operable;
  bool connected;
  bool locked;
  int remote_epoch;
  int min_epoch;
  bool get hasError => error?.message?.isNotEmpty ?? false;
  ReactionDisposer _disposer;

  @override
  void initState() {
    super.initState();
    error = null;
    operable = false;
    connected = false;
    locked = false;
    remote_epoch = 0;
    min_epoch = 0;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_disposer == null) {
      final store = Provider.of<StegosStore>(context);
      error = store.error.value;
      operable = store.nodeService.operable;
      remote_epoch = store.nodeService.remote_epoch;
      min_epoch = store.nodeService.min_epoch;
      connected = store.nodeService.connected;
      locked = store.nodeService.locked;
      _disposer = reaction(
          (_) => [
                store.error.value,
                store.nodeService.operable,
                store.nodeService.connected,
                store.nodeService.min_epoch,
                store.nodeService.remote_epoch,
                store.nodeService.locked,
              ], (arr) {
        setState(() {
          error = arr[0] as ErrorState;
          operable = arr[1] as bool;
          connected = arr[2] as bool;
          min_epoch = arr[3] as int;
          remote_epoch = arr[4] as int;
          locked = arr[5] as bool;
        });
      });
    }
  }

  @override
  void dispose() {
    if (_disposer != null) {
      _disposer.call();
      _disposer = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final builder = widget.builder;
    if (operable && !hasError) {
      if (widget.wrapInObserver) {
        return Observer(builder: builder);
      } else {
        return builder(context);
      }
    }
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          //
          if (!operable && !locked)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 50),
              color: StegosColors.accentColor,
              child: Text(
                !connected
                    ? 'Stegos node is not connected'
                    : 'Stegos node synchronizing ${min_epoch}/${remote_epoch}...',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 9),
              ),
            ),
          //
          if (hasError)
            GestureDetector(
              onTap: () {
                final env = Provider.of<StegosEnv>(context);
                env.resetError();
              },
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 50),
                color: StegosColors.errorColor,
                child: Text(
                  error.message,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                ),
              ),
            ),
          //
          Expanded(
              child: widget.wrapInObserver
                  ? Observer(builder: builder)
                  : builder(context))
        ],
      ),
    );
  }
}
