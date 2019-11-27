import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stegos_wallet/ui/themes.dart';
import 'package:stegos_wallet/widgets/widget_app_bar.dart';

/// Main wallet screen with integrated TabBar.
///
class SettingsScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget _buildListTile({
    Widget leading,
    String title,
    String subtitle,
    String group,
    Widget trailing,
    dense,
    enabled = true,
    onTap,
  }) {
    const TextStyle titleStyle = TextStyle(fontSize: 18, letterSpacing: 0.3);
    const TextStyle subtitleStyle =
        TextStyle(fontSize: 12, letterSpacing: 0.3, color: Color(0xff7d8b97));

    List<Widget> body = <Widget>[
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
    return Container(
      padding: const EdgeInsets.all(17).copyWith(top: group != null ? 0 : 17),
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          border:
              Border(bottom: BorderSide(color: StegosColors.white.withOpacity(0.7), width: 0.35))),
      child: Column(
        children: <Widget>[
          Container(
            alignment: Alignment.topLeft,
            child: group != null
                ? Container(
                    padding: const EdgeInsets.only(bottom: 20),
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
                child: Center(
                  child: trailing,
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBarWidget(
        centerTitle: false,
        leading: IconButton(
          icon: Icon(Icons.contacts),
          onPressed: () => {print('Show menu')},
        ),
        title: const Text('Stegos Wallet'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            _buildListTile(
                leading: SvgPicture.asset('assets/images/account_name.svg'),
                title: 'Account name',
                subtitle:
                    'New contacts will see this name before saving to contacts your information',
                group: 'General',
                trailing: Icon(
                  Icons.navigate_next,
                  color: Color(0xff7d8b97),
                )),
            _buildListTile(
              leading: SvgPicture.asset('assets/images/packet_main_account.svg'),
              title: 'Red packet main account',
              subtitle: 'STG from mining red packets enter in account automatically',
              trailing: Switch(
                onChanged: (bool value) {},
                value: true,
              ),
            ),
            _buildListTile(
              leading: SvgPicture.asset('assets/images/backed_up.svg'),
              title: 'Account backed up',
              subtitle: 'Strongly recommend back up your account',
              group: 'Security',
              trailing: Icon(
                Icons.check,
                color: Color(0xffff6c00).withOpacity(0.54),
              ),
            ),
            _buildListTile(
                leading: SvgPicture.asset('assets/images/password.svg'),
                title: 'Password',
                trailing: Icon(
                  Icons.navigate_next,
                  color: Color(0xff7d8b97),
                )),
            _buildListTile(
                leading: SvgPicture.asset(
                  'assets/images/fingerprint.svg',
                  width: 21,
                ),
                title: 'Fingerprint',
                subtitle: 'Allow to use fingerprint instead of password',
                trailing: Switch(
                  onChanged: (bool value) {},
                  value: true,
                )),
            _buildListTile(
              leading: SvgPicture.asset(
                'assets/images/delete.svg',
                width: 21,
              ),
              title: 'Delete',
            ),
          ],
        ),
      ));
}
