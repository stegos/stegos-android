import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:stegos_wallet/env_stegos.dart';
import 'package:stegos_wallet/services/service_node.dart';
import 'package:stegos_wallet/stores/store_stegos.dart';
import 'package:stegos_wallet/ui/themes.dart';
import 'package:stegos_wallet/widgets/widget_app_bar.dart';
import 'package:stegos_wallet/widgets/widget_scaffold_body_wrapper.dart';

/// Main wallet screen with integrated TabBar.
///
class SettingsScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Widget _buildListTile({
    Widget leading,
    String title,
    String subtitle,
    String group,
    Widget trailing,
    dense,
    enabled = true,
    Function() onTap,
  }) {
    const TextStyle titleStyle = TextStyle(fontSize: 18, letterSpacing: 0.3);
    const TextStyle subtitleStyle =
        TextStyle(fontSize: 12, letterSpacing: 0.3, color: Color(0xff7d8b97));

    final List<Widget> body = <Widget>[
      Text(
        title,
        style: titleStyle,
      ),
    ];
    if (subtitle != null) {
      body.add(const SizedBox(
        height: 5,
      ));
      body.add(Text(
        subtitle,
        style: subtitleStyle,
      ));
    }
    return RawMaterialButton(
      onPressed: onTap ?? () {},
      child: Container(
        padding: const EdgeInsets.all(17).copyWith(top: group != null ? 0 : 17),
        margin: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(color: StegosColors.white.withOpacity(0.7), width: 0.35))),
        child: Column(
          children: <Widget>[
            Container(
              alignment: Alignment.topLeft,
              child: group != null
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 20, top: 10),
                      child: Text(
                        group,
                        style: subtitleStyle,
                      ))
                  : null,
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    alignment: Alignment.topLeft,
                    child: leading,
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: body,
                  ),
                ),
                Expanded(
                  child: Container(
                    alignment: Alignment.centerRight,
                    child: trailing,
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = Provider.of<StegosStore>(context);
    return Theme(
      data: StegosThemes.settingsTheme,
      child: Scaffold(
        appBar: AppBarWidget(
          centerTitle: false,
          leading: IconButton(
            icon: const Image(
              image: AssetImage('assets/images/arrow_back.png'),
              width: 24,
              height: 24,
            ),
            onPressed: () => {Navigator.pop(context)},
          ),
          title: const Text('Settings'),
        ),
        body: ScaffoldBodyWrapperWidget(
            wrapInObserver: true,
            builder: (context) {
              return SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    _buildListTile(
                        onTap: _onAllowPincodeChanged,
                        leading: SvgPicture.asset(
                          'assets/images/fingerprint.svg',
                          width: 21,
                        ),
                        title: 'Fingerprint',
                        subtitle: 'Allow to use fingerprint to unlock wallet',
                        trailing: Switch(
                          onChanged: _onAllowPincodeChanged,
                          value: store.configAllowFingerprintWalletProtection,
                          activeColor: StegosColors.primaryColor,
                        )),
                  ],
                ),
              );
            }),
      ),
    );
  }

  void _onAllowPincodeChanged([bool val]) {
    final store = Provider.of<StegosStore>(context);
    final bool value = val ?? !store.configAllowFingerprintWalletProtection;
    store.mergeSingle('configAllowFingerprintWalletProtection', value);
  }
}
