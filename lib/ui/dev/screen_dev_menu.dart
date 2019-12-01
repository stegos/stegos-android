import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pedantic/pedantic.dart';
import 'package:provider/provider.dart';
import 'package:stegos_wallet/stores/store_stegos.dart';
import 'package:stegos_wallet/ui/themes.dart';
import 'package:stegos_wallet/utils/dialogs.dart';
import 'package:stegos_wallet/widgets/widget_app_bar.dart';
import 'package:stegos_wallet/widgets/widget_scaffold_body_wrapper.dart';

class DevMenuScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _DevMenuScreenState();
}

class _DevMenuScreenState extends State<DevMenuScreen> {
  static const _iconBackImage = AssetImage('assets/images/arrow_back.png');

  @override
  Widget build(BuildContext context) => Theme(
        data: StegosThemes.baseTheme,
        child: Scaffold(
          appBar: AppBarWidget(
            centerTitle: false,
            backgroundColor: Theme.of(context).colorScheme.primary,
            leading: IconButton(
              icon: const SizedBox(
                width: 24,
                height: 24,
                child: Image(image: _iconBackImage),
              ),
              onPressed: () => Navigator.pop(context, false),
            ),
            title: const Text('Development'),
          ),
          body: ScaffoldBodyWrapperWidget(
              wrapInObserver: true,
              builder: (context) {
                final store = Provider.of<StegosStore>(context);
                return ListView(
                  children: <Widget>[
                    ListTile(
                        title: const Text('Node address'),
                        subtitle: Text(store.nodeWsEndpoint),
                        onTap: () async {
                          var addr = await appShowSimpleAskTextDialog(
                              title: 'Node address', intialValue: store.nodeWsEndpoint);
                          if (addr != null) {
                            if (!addr.startsWith('ws://')) addr = 'ws://${addr}';
                            unawaited(store.mergeSingle('wsEndpoint', addr.trim()));
                          }
                        })
                  ],
                );
              }),
        ),
      );
}
