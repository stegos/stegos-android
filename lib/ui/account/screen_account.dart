import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobx/mobx.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:stegos_wallet/services/service_node.dart';
import 'package:stegos_wallet/ui/app.dart';
import 'package:stegos_wallet/ui/pay/screen_pay.dart';
import 'package:stegos_wallet/ui/qr_generator/qr_generator.dart';
import 'package:stegos_wallet/ui/routes.dart';
import 'package:stegos_wallet/ui/themes.dart';
import 'package:stegos_wallet/ui/transactions/screen_transactions.dart';
import 'package:stegos_wallet/ui/transactions/transactions_list.dart';
import 'package:stegos_wallet/widgets/widget_app_bar.dart';
import 'package:stegos_wallet/widgets/widget_scaffold_body_wrapper.dart';

class AccountScreen extends StatefulWidget {
  AccountScreen({Key key, this.account}) : super(key: key);

  final AccountStore account;

  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  ReactionDisposer _disposer;

  @override
  void initState() {
    super.initState();
    // Rebuild me if txList empty state changed
    _disposer = reaction((_) => [widget.account.txList.isNotEmpty], (_) => setState(() {}));
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
  Widget build(BuildContext context) => Theme(
      data: StegosThemes.AccountTheme,
      child: Scaffold(
        appBar: AppBarWidget(
            centerTitle: false,
            backgroundColor: Theme.of(context).colorScheme.primary,
            leading: IconButton(
              icon: const Image(
                image: AssetImage('assets/images/arrow_back.png'),
                width: 24,
                height: 24,
              ),
              onPressed: () => Navigator.pop(context, false),
            ),
            actions: <Widget>[
              IconButton(
                icon: SvgPicture.asset(
                  'assets/images/gear.svg',
                  width: 22,
                  height: 22,
                ),
                onPressed: () => StegosApp.navigatorState
                    .pushNamed(Routes.accountSettings, arguments: widget.account),
              )
            ],
            title: Observer(builder: (context) => Text(widget.account.humanName))),
        body: ScaffoldBodyWrapperWidget(
            builder: (context) => Column(
                  children: <Widget>[
                    Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                      Container(
                          child: Container(
                              padding: const EdgeInsets.only(top: 30),
                              color: StegosColors.splashBackground,
                              child: Observer(
                                builder: (context) => Column(
                                  children: <Widget>[
                                    const Text('Balance', style: TextStyle(fontSize: 14)),
                                    const SizedBox(height: 7),
                                    Text('${widget.account.humanBalance} STG',
                                        style: TextStyle(
                                            fontSize: 32,
                                            fontWeight: FontWeight.w500,
                                            color: StegosColors.primaryColor)),
                                    const SizedBox(height: 26),
                                    Container(
                                        height: 40,
                                        margin: const EdgeInsets.symmetric(horizontal: 22),
                                        decoration: const BoxDecoration(
                                          border: Border(
                                              bottom:
                                                  BorderSide(color: StegosColors.white, width: 1)),
                                        ),
                                        child: Center(
                                          child: SelectableText(widget.account.pkey,
                                              style: const TextStyle(fontSize: 10)),
                                        )),
                                    Container(
                                        alignment: Alignment.topRight,
                                        padding:
                                            const EdgeInsets.only(top: 14, right: 22, bottom: 19),
                                        child: InkWell(
                                          onTap: _showQRCode,
                                          child: QrImage(
                                            padding: EdgeInsets.zero,
                                            foregroundColor: StegosColors.white,
                                            data: widget.account.pkey,
                                            version: QrVersions.auto,
                                            size: 36,
                                          ),
                                        )),
                                    _buildButtons()
                                  ],
                                ),
                              ))),
                    ]),
                    Expanded(
                      child: Stack(
                        children: <Widget>[
                          Container(
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            height: 57,
                            alignment: Alignment.center,
                            child: Text(
                              'Transactions',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(
                              padding: const EdgeInsets.only(left: 10, right: 10),
                              height: 57,
                              alignment: Alignment.centerRight,
                              child: widget.account.txList.isNotEmpty
                                  ? GestureDetector(
                                      onTap: _seeAll,
                                      child: Text(
                                        'See all',
                                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                      ),
                                    )
                                  : null),
                          Container(
                              alignment: Alignment.topCenter,
                              padding: const EdgeInsets.only(top: 57),
                              child: TransactionsList(widget.account))
                        ],
                      ),
                    )
                  ],
                )),
      ));

  Container _buildButtons() => Container(
        color: StegosColors.backgroundColor,
        child: Container(
          padding: const EdgeInsets.only(top: 33, bottom: 25),
          margin: const EdgeInsets.symmetric(horizontal: 10),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: StegosColors.white, width: 1)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    width: 65,
                    height: 65,
                    child: RaisedButton(
                      padding: const EdgeInsets.all(10),
                      onPressed: () {
                        StegosApp.navigatorState.pushNamed(Routes.pay, arguments: PayScreenArguments(account: widget.account));
                      },
                      color: StegosColors.splashBackground,
                      child: SvgPicture.asset('assets/images/send.svg'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Send',
                    style: TextStyle(fontSize: 12),
                  )
                ],
              ),
              const SizedBox(width: 75),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    width: 65,
                    height: 65,
                    child: RaisedButton(
                      padding: const EdgeInsets.all(10),
                      onPressed: () {},
                      color: StegosColors.splashBackground,
                      child: SvgPicture.asset('assets/images/red_packet.svg'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: 71,
                    child: const Text(
                      'Generate Red Packet',
                      style: TextStyle(fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      );

  void _seeAll() {
    StegosApp.navigatorState.push(MaterialPageRoute(
      builder: (BuildContext context) => TransactionsScreen(account: widget.account),
      fullscreenDialog: true,
    ));
  }

  Future<String> _showQRCode() {
    return StegosApp.navigatorState.push(MaterialPageRoute(
      builder: (BuildContext context) => QrGenerator(
        title: 'QR code for ${widget.account.humanName}',
        qrData: widget.account.pkey,
      ),
      fullscreenDialog: true,
    ));
  }
}
