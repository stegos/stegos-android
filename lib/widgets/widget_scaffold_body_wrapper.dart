import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import 'package:provider/provider.dart';
import 'package:stegos_wallet/env_stegos.dart';
import 'package:stegos_wallet/stores/store_stegos.dart';
import 'package:stegos_wallet/ui/themes.dart';

class ScaffoldBodyWrapperWidget extends StatefulWidget {
  const ScaffoldBodyWrapperWidget({Key key, this.builder, this.wrapInObserver = false})
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
  bool get hasError => error?.message?.isNotEmpty ?? false;
  ReactionDisposer _disposer;

  @override
  void initState() {
    super.initState();
    error = null;
    operable = false;
    connected = false;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_disposer == null) {
      final store = Provider.of<StegosStore>(context);
      error = store.error.value;
      operable = store.nodeService.operable;
      connected = store.nodeService.connected;
      _disposer = reaction(
          (_) => [
                store.error.value,
                store.nodeService.operable,
                store.nodeService.connected,
              ], (arr) {
        setState(() {
          error = arr[0] as ErrorState;
          operable = arr[1] as bool;
          connected = arr[2] as bool;
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
          if (!operable)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 50),
              color: StegosColors.accentColor,
              child: Text(
                !connected ? 'Stegos node is not connected' : 'Stegos node synchronizing...',
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
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 50),
                color: StegosColors.errorColor,
                child: Text(
                  error.message,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                ),
              ),
            ),
          //
          Expanded(child: widget.wrapInObserver ? Observer(builder: builder) : builder(context))
        ],
      ),
    );
  }
}
