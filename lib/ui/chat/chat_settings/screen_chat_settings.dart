import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stegos_wallet/env_stegos.dart';
import 'package:stegos_wallet/services/service_node.dart';
import 'package:stegos_wallet/ui/app.dart';
import 'package:stegos_wallet/ui/qr_generator/qr_generator.dart';
import 'package:stegos_wallet/ui/routes.dart';
import 'package:stegos_wallet/ui/themes.dart';
import 'package:stegos_wallet/ui/wallet/wallet/account_card.dart';
import 'package:stegos_wallet/widgets/widget_app_bar.dart';
import 'package:stegos_wallet/widgets/widget_scaffold_body_wrapper.dart';

class ChatSettingsScreen extends StatefulWidget {
  @override
  _ChatSettingsScreenState createState() => _ChatSettingsScreenState();
}

class _ChatSettingsScreenState extends State<ChatSettingsScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  final bool isChannel = true;

  final TextEditingController channelAddressController = TextEditingController.fromValue(
      const TextEditingValue(text: '0xf7da9EFFF07539840CF329B71De91'));
  final TextEditingController chatNameController =
      TextEditingController.fromValue(const TextEditingValue(text: 'Lucky team'));

  Widget get delimiter => Container(
        height: 15,
        color: const Color(0xff2b2e3b),
      );

  Widget get listDelimiter => Container(
        height: 0.35,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        color: StegosColors.white,
      );

  Dialog deleteDialog = Dialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3.0)),
    child: Container(
      width: 320,
      height: 211,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 40, left: 30, right: 30, bottom: 10),
            child: Text(
              'Are you sure you want to delete Group Lucky team?',
              textAlign: TextAlign.center,
              style: TextStyle(color: StegosColors.white, fontSize: 18),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 45, right: 45, bottom: 20),
            child: Text(
              'This chat will be deleted only for you. ',
              textAlign: TextAlign.center,
              style: TextStyle(color: StegosColors.primaryColorDark, fontSize: 14),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 19),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                FlatButton(
                    onPressed: () {
                      StegosApp.navigatorState.pushReplacementNamed(Routes.wallet, arguments: 2);
                    },
                    child: Text(
                      'Delete',
                      style: TextStyle(
                          color: const Color(0xffff6363),
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold),
                    )),
                FlatButton(
                    onPressed: () => StegosApp.navigatorState.pop(false),
                    child: Text(
                      'No, Cancell',
                      style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                    )),
              ],
            ),
          )
        ],
      ),
    ),
  );

  Dialog leaveDialog = Dialog(
    backgroundColor: const Color(0xff343946),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3.0)),
    child: Container(
      width: 320,
      height: 211,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 40, left: 30, right: 30, bottom: 10),
            child: Text(
              'Are you sure you want to leave Group Lucky team?',
              textAlign: TextAlign.center,
              style: TextStyle(color: StegosColors.white, fontSize: 18),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 19),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                FlatButton(
                    onPressed: () {
                      StegosApp.navigatorState.pushReplacementNamed(Routes.wallet, arguments: 2);
                    },
                    child: Text(
                      'Leave',
                      style: TextStyle(
                          color: const Color(0xffff6363),
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold),
                    )),
                FlatButton(
                    onPressed: () => StegosApp.navigatorState.pop(false),
                    child: Text(
                      'No, Stay',
                      style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                    )),
              ],
            ),
          )
        ],
      ),
    ),
  );

  Widget buildListItem({@required Widget text, Widget tailing, Function() onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 60,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            text,
            Container(
              alignment: Alignment.centerRight,
              child: tailing,
            )
          ],
        ),
      ),
    );
  }

  Widget buildChannelAddress() {
    return Container(
      height: 84,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Stack(
            children: <Widget>[
              TextField(
                controller: channelAddressController,
                decoration: const InputDecoration(
                    contentPadding: EdgeInsets.only(right: 25),
                    border: UnderlineInputBorder(),
                    labelText: 'Channel address'),
                enabled: false,
              ),
              Container(
                height: 39,
                alignment: Alignment.bottomRight,
                child: GestureDetector(
                  onTap: () => {},
                  child: Image.asset(
                    'assets/images/qr.png',
                    height: 20,
                    width: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          InkWell(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.only(top: 5, bottom: 5),
              child: const Text(
                'Invite your contacts',
                style: TextStyle(fontSize: 18),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget buildConnectedAccount() {
    final env = Provider.of<StegosEnv>(context);
    final ValueKey<AccountStore> accountKey = ValueKey(env.nodeService.accountsList[0]);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text('Connected account', style: TextStyle(fontSize: 18)),
          const SizedBox(height: 14),
          AccountCard(
            key: accountKey,
            collapsed: true,
            onTap: () {},
            backgroundAlignment: const Alignment(0, -0.5),
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                flex: 3,
                child: Text('Approximately amount of the messages you can send',
                    style: TextStyle(color: StegosColors.primaryColorDark, fontSize: 14)),
              ),
              const SizedBox(width: 5),
              Expanded(
                flex: 2,
                child: Text('XXXX MESSAGES',
                    textAlign: TextAlign.end,
                    style: TextStyle(color: StegosColors.primaryColorDark, fontSize: 14)),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget buildChatName() {
    return Container(
      height: isChannel ? 243 : 140,
      padding: const EdgeInsets.only(left: 16, right: 16, top: 41, bottom: 26),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          Container(
            alignment: Alignment.topLeft,
            child: CircleAvatar(
              backgroundColor: const Color(0xffff9d4d),
              radius: 32,
              child: Icon(Icons.photo_camera, color: StegosColors.white),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(left: 80),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextField(
                  controller: chatNameController,
                  style: const TextStyle(fontSize: 20),
                  decoration: InputDecoration(
                      border: UnderlineInputBorder(
                          borderSide: BorderSide(width: 2, color: StegosColors.primaryColorDark)),
                      contentPadding:
                          const EdgeInsets.only(top: 3, bottom: 5, left: 13, right: 13)),
                ),
                const Padding(
                    padding: EdgeInsets.only(left: 13, top: 9),
                    child: Text(
                      '15 members',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
                    ))
              ],
            ),
          ),
          isChannel ? buildChannelAddress() : Container(),
        ],
      ),
    );
  }

  void muteChat() {
    showModalBottomSheet<Widget>(
        backgroundColor: Colors.transparent,
        builder: (context) {
          return Container(
            decoration: const BoxDecoration(
                color: Color(0xff343946),
                borderRadius:
                    BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6))),
            child: Material(
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6), topRight: Radius.circular(6)),
              color: Colors.transparent,
              child: Wrap(
                children: <Widget>[
                  ListTile(
                    title: const Text(
                      'Mute for 1 hour',
                      style: TextStyle(fontSize: 18),
                    ),
                    onTap: () {},
                  ),
                  ListTile(
                    title: const Text(
                      'Mute for 8 hour',
                      style: TextStyle(fontSize: 18),
                    ),
                    onTap: () {},
                  ),
                  ListTile(
                    title: const Text(
                      'Mute for 1 day',
                      style: TextStyle(fontSize: 18),
                    ),
                    onTap: () {},
                  ),
                  ListTile(
                    title: const Text(
                      'Mute until I turn it back on',
                      style: TextStyle(fontSize: 18),
                    ),
                    onTap: () {},
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20, top: 3),
                    child: ListTile(
                      title: const Text(
                        'Unmute',
                        style: TextStyle(fontSize: 18, color: Color(0xff32ff6b)),
                      ),
                      trailing: Text(
                        '10:12:19 left',
                        style: TextStyle(fontSize: 14, color: StegosColors.primaryColorDark),
                      ),
                      onTap: () {},
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        context: context);
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: StegosThemes.ChatTheme,
      child: Scaffold(
          key: scaffoldKey,
          appBar: AppBarWidget(
            centerTitle: false,
            backgroundColor: Theme.of(context).colorScheme.primary,
            leading: IconButton(
              icon: const SizedBox(
                width: 24,
                height: 24,
                child: Image(image: AssetImage('assets/images/arrow_back.png')),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: const Text('Chat settings'),
          ),
          body: ScaffoldBodyWrapperWidget(
            builder: (context) => SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  buildChatName(),
                  delimiter,
                  buildConnectedAccount(),
                  delimiter,
                  buildListItem(
                      text: const Text('Chat transactions', style: TextStyle(fontSize: 18)),
                      tailing: Icon(Icons.chevron_right, color: StegosColors.primaryColorDark),
                      onTap: () {}),
                  listDelimiter,
                  buildListItem(
                    text: const Text('Chat notifications', style: TextStyle(fontSize: 18)),
                    tailing: Row(
                      children: <Widget>[
                        Text('On',
                            style: TextStyle(color: StegosColors.primaryColorDark, fontSize: 14)),
                        Icon(
                          Icons.chevron_right,
                          color: StegosColors.primaryColorDark,
                        ),
                      ],
                    ),
                    onTap: muteChat,
                  ),
                  delimiter,
                  buildListItem(
                      text: Text('Leave ${isChannel ? 'channel' : 'group'}',
                          style: TextStyle(fontSize: 18, color: StegosColors.errorColor)),
                      tailing: Icon(Icons.chevron_right, color: StegosColors.primaryColorDark),
                      onTap: () {
                        showDialog(
                            context: context, builder: (BuildContext context) => leaveDialog);
                      }),
                  listDelimiter,
                  buildListItem(
                      text: Text('Delete ${isChannel ? 'channel' : 'group'}',
                          style: TextStyle(fontSize: 18, color: StegosColors.errorColor)),
                      tailing: Icon(Icons.chevron_right, color: StegosColors.primaryColorDark),
                      onTap: () {
                        showDialog(
                            context: context, builder: (BuildContext context) => deleteDialog);
                      }),
                  listDelimiter,
                ],
              ),
            ),
          )),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
