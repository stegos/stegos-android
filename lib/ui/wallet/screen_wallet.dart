import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stegos_wallet/ui/chat/chat_list/chat_list.dart';
import 'package:stegos_wallet/ui/routes.dart';
import 'package:stegos_wallet/ui/themes.dart';
import 'package:stegos_wallet/ui/wallet/contacts/contacts.dart';
import 'package:stegos_wallet/ui/wallet/qr_reader/qr_reader_tab.dart';
import 'package:stegos_wallet/ui/wallet/wallet/screen_accounts.dart';
import 'package:stegos_wallet/widgets/widget_app_bar.dart';

/// Main wallet screen with integrated TabBar.
///
class WalletScreen extends StatefulWidget {
  WalletScreen({this.initialTab = 0});

  final int initialTab;

  @override
  State<StatefulWidget> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> drawerKey = GlobalKey();

  bool scanForAddress = false;
  int selectedItem = 0;
  TabController tabController;

  final List<String> tabNames = [
    'Stegos Wallet', 'QR Reader',
    // 'Chat',
    'Contacts'
  ];

  Widget buildTabIcon(String assetName, bool selected) => SvgPicture.asset(
      assetName,
      color:
          selected ? StegosColors.primaryColor : StegosColors.primaryColorDark);

  @override
  void initState() {
    super.initState();
    tabController = TabController(vsync: this, length: 3);
    tabController.index = widget.initialTab ?? 0;
    updateTabParams();
    tabController.addListener(updateTabParams);
  }

  void updateTabParams() {
    setState(() {
      selectedItem = tabController.index;
      scanForAddress = tabController.index == 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: StegosThemes.walletTheme,
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          key: drawerKey,
          appBar: AppBarWidget(
            centerTitle: false,
            leading: IconButton(
              icon: SvgPicture.asset('assets/images/menu.svg'),
              onPressed: () => {drawerKey.currentState.openDrawer()},
            ),
            title: Text(tabNames[selectedItem]),
          ),
          drawer: Drawer(
            child: ListView(
              // Important: Remove any padding from the ListView.
              padding: EdgeInsets.zero,
              children: <Widget>[
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: StegosColors.accentColor,
                  ),
                  child: const Text('Stegos'),
                ),
                ListTile(
                  title: const Text('Settings'),
                  onTap: () {
                    Navigator.pushNamed(context, Routes.settings);
                  },
                ),
                ListTile(
                  title: const Text('Development'),
                  onTap: () {
                    Navigator.pushNamed(context, Routes.devmenu);
                  },
                ),
              ],
            ),
          ),
          bottomNavigationBar: Container(
            color: StegosColors.splashBackground,
            child: TabBar(
              controller: tabController,
              tabs: [
                Tab(
                  icon: buildTabIcon(
                      'assets/images/wallet.svg', selectedItem == 0),
                  text: 'Wallet',
                ),
                Tab(
                  icon: buildTabIcon(
                      'assets/images/qr_reader.svg', selectedItem == 1),
                  text: 'QR Reader',
                ),
                // Tab(
                //   icon: buildTabIcon('assets/images/chat.svg', selectedItem == 2),
                //   text: 'Chat',
                // ),
                Tab(
                  icon: buildTabIcon(
                      'assets/images/contacts.svg', selectedItem == 2),
                  text: 'Contacts',
                ),
              ],
              indicator: UnderlineTabIndicator(
                borderSide: BorderSide.none,
                insets: EdgeInsets.zero,
              ),
            ),
          ),
          body: TabBarView(
            physics: const NeverScrollableScrollPhysics(),
            controller: tabController,
            children: [
              AccountsScreen(),
              QrReaderTab(
                isScanning: scanForAddress,
              ),
              // ChatList(),
              Contacts(),
            ],
          ),
        ),
      ),
    );
  }
}
