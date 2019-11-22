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
        if (error == null || (error.message?.isEmpty ?? true)) {
          return builder(context);
        }
        return SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 50),
                color: StegosColors.errorColor,
                child: Text(
                  error.message,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                ),
              ),
              Expanded(child: builder(context))
            ],
          ),
        );
      },
    );
  }
}
