import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:stegos_wallet/env_stegos.dart';
import 'package:stegos_wallet/ui/app.dart';
import 'package:stegos_wallet/ui/pay/screen_pay.dart';
import 'package:stegos_wallet/ui/routes.dart';
import 'package:stegos_wallet/ui/themes.dart';
import 'package:stegos_wallet/ui/wallet/qr_reader/qr_reader.dart';
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

class _WalletScreenState extends State<WalletScreen> with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _drawerKey = GlobalKey();

  bool scanForAddress = false;
  int selectedItem = 0;
  TabController _tabController;

  Widget _buildTabIcon(String assetName, bool selected) => SvgPicture.asset(assetName,
      color: selected ? StegosColors.primaryColor : StegosColors.primaryColorDark);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 4, initialIndex: widget.initialTab);
    _tabController.addListener(() {
      setState(() {
        selectedItem = _tabController.index;
        scanForAddress = _tabController.index == 1;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: StegosThemes.walletTheme,
      child: DefaultTabController(
        initialIndex: 2,
        length: 4,
        child: Scaffold(
          key: _drawerKey,
          appBar: AppBarWidget(
            centerTitle: false,
            leading: IconButton(
              icon: SvgPicture.asset('assets/images/menu.svg'),
              onPressed: () => {_drawerKey.currentState.openDrawer()},
            ),
            title: const Text('Stegos Wallet'),
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
              controller: _tabController,
              tabs: [
                Tab(
                  icon: _buildTabIcon('assets/images/wallet.svg', selectedItem == 0),
                  text: 'Wallet',
                ),
                Tab(
                  icon: _buildTabIcon('assets/images/qr_reader.svg', selectedItem == 1),
                  text: 'QR Reader',
                ),
                Tab(
                  icon: _buildTabIcon('assets/images/chat.svg', selectedItem == 2),
                  text: 'Chat',
                ),
                Tab(
                  icon: _buildTabIcon('assets/images/contacts.svg', selectedItem == 3),
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
            controller: _tabController,
            children: [
              AccountsScreen(),
              QrReader(
                isScanning: scanForAddress,
                onStegosAddressFound: (String address) {
                  final env = Provider.of<StegosEnv>(context);
                  if (!env.nodeService.operable) {
                    return;
                  }
                  final account = env.nodeService.accountsList[0];
                  setState(() {
                    scanForAddress = false;
                  });
                  StegosApp.navigatorState.pushNamed(Routes.pay,
                      arguments: PayScreenArguments(account: account, recepientAddress: address));
                },
              ),
              Text('Chat'),
              Text('Contacts'),
            ],
          ),
        ),
      ),
    );
  }
}
