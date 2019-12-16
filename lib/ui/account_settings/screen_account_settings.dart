import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pedantic/pedantic.dart';
import 'package:provider/provider.dart';
import 'package:stegos_wallet/env_stegos.dart';
import 'package:stegos_wallet/log/loggable.dart';
import 'package:stegos_wallet/services/service_node.dart';
import 'package:stegos_wallet/ui/app.dart';
import 'package:stegos_wallet/ui/backup/account_backup.dart';
import 'package:stegos_wallet/ui/routes.dart';
import 'package:stegos_wallet/ui/themes.dart';
import 'package:stegos_wallet/utils/dialogs.dart';
import 'package:stegos_wallet/widgets/widget_app_bar.dart';
import 'package:stegos_wallet/widgets/widget_scaffold_body_wrapper.dart';

/// Main wallet screen with integrated TabBar.
///
class AccountSettingsScreen extends StatefulWidget {
  AccountSettingsScreen({Key key, @required this.account}) : super(key: key);

  final AccountStore account;

  @override
  State<StatefulWidget> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> with Loggable<_AccountSettingsScreenState> {
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
                builder: (context) => SingleChildScrollView(
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
                          color: StegosColors.primaryColorDark,
                        ),
                        onTap: () => Navigator.pushNamed(context, Routes.username,
                            arguments: widget.account),
                      ),
                      _buildListTile(
                        leading: SvgPicture.asset('assets/images/packet_main_account.svg'),
                        title: 'Red packet main account',
                        subtitle: 'STG from mining red packets enter in account automatically',
                        trailing: Switch(
                          onChanged: (bool value) {},
                          value: true,
                          activeColor: StegosColors.primaryColor,
                        ),
                      ),
                      _buildListTile(
                        leading: SvgPicture.asset('assets/images/backed_up.svg'),
                        title: widget.account.backedUp ? 'Account backed up' : 'Backup account',
                        subtitle: widget.account.backedUp
                            ? ''
                            : 'Strongly recommend back up your account',
                        group: 'Security',
                        trailing: Icon(
                          Icons.check,
                          color: StegosColors.accentColor
                              .withOpacity(widget.account.backedUp ? 1 : 0.54),
                        ),
                        onTap: _backupAccount,
                      ),
                      _buildListTile(
                          leading: SvgPicture.asset('assets/images/password.svg'),
                          title: 'Password',
                          trailing: Icon(
                            Icons.navigate_next,
                            color: StegosColors.primaryColorDark,
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
                            activeColor: StegosColors.primaryColor,
                          )),
                      _buildListTile(
                        onTap: () {
                          _deleteAccount().then((bool value) {
                            if (StegosApp.navigatorState.canPop()) {
                              StegosApp.navigatorState.pop();
                            }
                            if (StegosApp.navigatorState.canPop()) {
                              StegosApp.navigatorState.pop();
                            }
                          });
                        },
                        leading: SvgPicture.asset(
                          'assets/images/delete.svg',
                          width: 21,
                        ),
                        title: 'Delete',
                      ),
                    ],
                  ),
                ))));
  }

  Future<bool> _deleteAccount() => appShowDialog<bool>(
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Delete account ${widget.account.humanName}?'),
        content: const Text('Please make an account backup if you with to restore it later.'),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              StegosApp.navigatorState.pop(false);
            },
            child: const Text('CANCEL'),
          ),
          FlatButton(
            onPressed: () {
              StegosApp.navigatorState.pop(true);
              final env = Provider.of<StegosEnv>(context);
              env.nodeService.deleteAccount(widget.account);
            },
            child: const Text('DELETE'),
          )
        ],
      );
    },
  );

  void _backupAccount() async {
    final env = Provider.of<StegosEnv>(context);
    final List<String> words = await env.nodeService.getSeedWords(widget.account);
    final bool backedUp = await StegosApp.navigatorState.push(MaterialPageRoute(
      builder: (BuildContext context) => AccountBackup(words: words),
      fullscreenDialog: true,
    ));
    if (backedUp) {
      unawaited(env.nodeService.markAsBackedUp(widget.account.id).catchError((err, StackTrace st) {
        log.warning('Failed to backup account: ', err, st);
      }));
    }
  }
}
