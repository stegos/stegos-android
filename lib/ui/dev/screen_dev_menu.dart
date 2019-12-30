import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mobx/mobx.dart';
import 'package:pedantic/pedantic.dart';
import 'package:provider/provider.dart';
import 'package:stegos_wallet/env_stegos.dart';
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
  ReactionDisposer _disposer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final env = Provider.of<StegosEnv>(context);
    final store = env.store;
    _disposer ??= reaction(
        (_) => [store.nodeWsEndpoint, store.nodeWsEndpointApiToken], (_) => setState(() {}));
  }

  @override
  void dispose() {
    if (_disposer != null) {
      _disposer();
      _disposer = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final env = Provider.of<StegosEnv>(context);
    return Theme(
      data: StegosThemes.baseTheme,
      child: Scaffold(
        appBar: AppBarWidget(
          centerTitle: false,
          backgroundColor: Theme.of(context).colorScheme.primary,
          leading: IconButton(
            icon: const SizedBox(
              width: 24,
              height: 24,
              child: Image(image: AssetImage('assets/images/arrow_back.png')),
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
                      onTap: store.embeddedNode
                          ? null
                          : () async {
                              var addr = (await appShowSimpleAskTextDialog(
                                      title: 'Node address', intialValue: store.nodeWsEndpoint))
                                  ?.trim();
                              if (addr != null) {
                                if (!addr.startsWith('ws://')) addr = 'ws://${addr}';
                                store.nodeWsEndpoint = addr;
                              }
                            }),
                  ListTile(
                      title: const Text('Node API Token'),
                      onTap: store.embeddedNode
                          ? null
                          : () async {
                              final token = (await appShowSimpleAskTextDialog(
                                      title: 'API Token',
                                      intialValue: store.nodeWsEndpointApiToken))
                                  ?.trim();
                              if (token != null && token.length == 24) {
                                unawaited(store.mergeSingle('wsApiToken', token));
                              }
                            }),
                  SwitchListTile(
                    onChanged: (bool value) {
                      if (value == false) {
                        setState(() {});
                        return;
                      }
                      final wsApiToken = store.nodeWsEndpointApiToken;
                      final wsEndpoint = store.nodeWsEndpoint;
                      final oldWsEndpoint =
                          store.settings['oldWsEndpoint'] ?? env.configNodeWsEndpoint;
                      final oldWsApiToken =
                          store.settings['oldWsApiToken'] ?? env.configNodeWsEndpointApiToken;
                      if (value) {
                        store.mergeSettings({
                          'nodeWsEndpoint': env.configEmbeddedNodeWsEndpoint,
                          'wsApiToken': env.configEmbeddedNodeWsEndpointApiToken,
                          'oldWsEndpoint': wsEndpoint,
                          'oldWsApiToken': wsApiToken
                        });
                      } else {
                        store.mergeSettings({
                          'nodeWsEndpoint': oldWsEndpoint,
                          'wsApiToken': oldWsApiToken,
                          'oldWsEndpoint': wsEndpoint,
                          'oldWsApiToken': wsApiToken
                        });
                      }
                    },
                    value: store.embeddedNode,
                    activeColor: StegosColors.primaryColor,
                    title: const Text('Embedded node'),
                  ),
                  SwitchListTile(
                    onChanged: (bool value) {
                      store.mergeSingle('needWelcome', value);
                    },
                    value: store.needWelcome,
                    activeColor: StegosColors.primaryColor,
                    title: const Text('Show welcome screen'),
                  ),
                ],
              );
            }),
      ),
    );
  }
}
