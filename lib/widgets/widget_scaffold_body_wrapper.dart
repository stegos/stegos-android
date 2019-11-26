import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';
import 'package:stegos_wallet/store/store_stegos.dart';
import 'package:stegos_wallet/ui/themes.dart';

class ScaffoldBodyWrapperWidget extends StatelessWidget {
  const ScaffoldBodyWrapperWidget({Key key, this.builder}) : super(key: key);

  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    final store = Provider.of<StegosStore>(context);
    return Observer(
      builder: (context) {
        final error = store.error.value;
        final operable = store.storeNode.operable;
        final connected = store.storeNode.connected;
        final hasError = error?.message?.isNotEmpty ?? false;
        if (operable && !hasError) {
          return builder(context);
        }
        final widgets = <Widget>[];
        if (!operable) {
          widgets.add(Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 50),
            color: StegosColors.accentColor,
            child: Text(
              !connected ? 'Stegos node is not connected' : 'Stegos node synchronizing...',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 9),
            ),
          ));
        }
        if (hasError) {
          widgets.add(Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 50),
            color: StegosColors.errorColor,
            child: Text(
              error.message,
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
          ));
        }
        widgets.add(Expanded(child: builder(context)));

        return SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: widgets,
          ),
        );
      },
    );
  }
}
