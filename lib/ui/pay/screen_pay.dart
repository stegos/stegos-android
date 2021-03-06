import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobx/mobx.dart';
import 'package:pedantic/pedantic.dart';
import 'package:provider/provider.dart';
import 'package:stegos_wallet/env_stegos.dart';
import 'package:stegos_wallet/services/service_node.dart';
import 'package:stegos_wallet/ui/app.dart';
import 'package:stegos_wallet/ui/pay/store_screen_pay.dart';
import 'package:stegos_wallet/ui/routes.dart';
import 'package:stegos_wallet/ui/themes.dart';
import 'package:stegos_wallet/ui/wallet/qr_reader/screen_qr_reader.dart';
import 'package:stegos_wallet/utils/cont.dart';
import 'package:stegos_wallet/utils/dialogs.dart';
import 'package:stegos_wallet/widgets/widget_app_bar.dart';
import 'package:stegos_wallet/widgets/widget_scaffold_body_wrapper.dart';

class PayScreenArguments {
  PayScreenArguments({@required this.account, this.recepientAddress});

  final AccountStore account;
  final String recepientAddress;
}

class PayScreen extends StatefulWidget {
  PayScreen({Key key, PayScreenArguments args})
      : account = args.account,
        recepientAddress = args.recepientAddress,
        super(key: key);

  final AccountStore account;
  final String recepientAddress;

  @override
  _PayScreenState createState() => _PayScreenState();
}

class _PayScreenState extends State<PayScreen> {
  static final _store = PayScreenStore();

  final _recepientFocusNode = FocusNode();

  final _addressTextController = TextEditingController();

  Color _recepientFieldColor = StegosColors.primaryColorDark;

  @override
  void initState() {
    _store.reset();
    _store.senderAccount = widget.account;
    _recepientFocusNode.addListener(() => setState(() {
          _recepientFieldColor = _recepientFocusNode.hasFocus
              ? StegosColors.accentColor
              : StegosColors.primaryColorDark;
        }));

    if (widget.recepientAddress != null && widget.recepientAddress.isNotEmpty) {
      _store.toAddress = widget.recepientAddress;
      _addressTextController.text = widget.recepientAddress;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: StegosThemes.payScreenTheme,
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
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('Send STG'),
        ),
        body: ScaffoldBodyWrapperWidget(
          builder: (context) => Column(
            children: <Widget>[
              Expanded(
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 22, vertical: 14).copyWith(top: 55),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      _buildAccountDropdown(),
                      _buildToAddress(),
                      _buildAmount(),
                      _buildFeeDropdown(),
                      _buildCommentTextField(),
                      _buildCertificateCheckbox(),
                    ],
                  ),
                ),
              ),
              SizedBox(width: double.infinity, height: 50, child: _buildSendButton())
            ],
          ),
        ),
      ),
    );
  }

  Widget _withLabel(String label, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          child: Text(label, style: TextStyle(fontSize: 12, color: StegosColors.primaryColorDark)),
        ),
        Container(
          child: content,
        )
      ],
    );
  }

  Widget _buildAccountDropdown() => Observer(builder: (context) {
        final env = Provider.of<StegosEnv>(context);
        final accountsList = env.nodeService.accountsList;
        return _withLabel(
            'Account to debit',
            Container(
              padding: const EdgeInsets.only(bottom: 19),
              child: DropdownButton<AccountStore>(
                value: _store.senderAccount,
                isExpanded: true,
                elevation: 16,
                underline: Container(
                  height: 1,
                  color: _store.senderAccount != null ? StegosColors.white : Colors.redAccent,
                ),
                onChanged: (AccountStore acc) {
                  runInAction(() {
                    _store.senderAccount = acc;
                    if (_store.toAddress == acc.pkey) {
                      _addressTextController.text = '';
                    }
                  });
                },
                items: accountsList.map<DropdownMenuItem<AccountStore>>((AccountStore value) {
                  return DropdownMenuItem<AccountStore>(
                    value: value,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(value.humanName),
                        Text('${value.humanBalance} STG', style: const TextStyle(fontSize: 18))
                      ],
                    ),
                  );
                }).toList(),
              ),
            ));
      });

  Widget _buildMyAccountsDropdown() => Observer(builder: (context) {
        final env = Provider.of<StegosEnv>(context);
        final accountsList =
            env.nodeService.accountsList.where((a) => a.id != _store.senderAccount?.id);
        return PopupMenuButton<String>(
          elevation: 16,
          onSelected: (String value) {
            runInAction(() {
              setState(() {
                _store.toAddress = value;
                _addressTextController.text = value;
              });
            });
          },
          itemBuilder: (context) => accountsList.map<PopupMenuItem<String>>((AccountStore value) {
            return PopupMenuItem<String>(
              value: value.pkey,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(value.humanName),
                  Text('${value.humanBalance} STG', style: const TextStyle(fontSize: 18))
                ],
              ),
            );
          }).toList(),
          child: FlatButton.icon(
            padding: const EdgeInsets.only(left: 10),
            splashColor: StegosColors.primaryColorDark,
            highlightColor: Colors.transparent,
            icon: SvgPicture.asset(
              'assets/images/accounts.svg',
              height: 21,
              color: _recepientFieldColor,
            ),
            label: Text(
              'My accounts',
              style: TextStyle(fontSize: 12, color: _recepientFieldColor),
            ),
            onPressed: null,
          ),
        );
      });

  Widget _buildToAddress() {
    final UnderlineInputBorder textFieldBorder = UnderlineInputBorder(
        borderSide: BorderSide(
            color: _store.isValidToAddress ? StegosColors.white : Colors.redAccent, width: 1));
    return _withLabel(
        'Recepient address',
        Container(
          child: Column(
            children: <Widget>[
              Stack(
                children: <Widget>[
                  TextField(
                    controller: _addressTextController,
                    onChanged: (String value) {
                      runInAction(() {
                        _store.toAddress = value;
                      });
                    },
                    focusNode: _recepientFocusNode,
                    decoration: InputDecoration(
                        contentPadding: const EdgeInsets.only(
                          right: 25,
                        ),
                        focusedBorder: textFieldBorder,
                        enabledBorder: textFieldBorder),
                  ),
                  Container(
                    height: 34,
                    alignment: Alignment.bottomRight,
                    child: GestureDetector(
                      onTap: _scanQr,
                      child: Image.asset(
                        'assets/images/qr.png',
                        height: 20,
                        width: 20,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  FlatButton.icon(
                      padding: const EdgeInsets.only(right: 10),
                      onPressed: () async {
                        final pkey = await Navigator.pushNamed(context, Routes.contacts, arguments: true);
                        _addressTextController.text = pkey as String;
                      },
                      splashColor: StegosColors.primaryColorDark,
                      highlightColor: Colors.transparent,
                      icon: SvgPicture.asset(
                        'assets/images/contacts.svg',
                        height: 26,
                        color: _recepientFieldColor,
                      ),
                      label: Text(
                        'Open contacts',
                        style: TextStyle(fontSize: 12, color: _recepientFieldColor),
                      )),
                  _buildMyAccountsDropdown()
                ],
              )
            ],
          ),
        ));
  }

  Widget _buildAmount() => Observer(builder: (context) {
        final UnderlineInputBorder textFieldBorder = UnderlineInputBorder(
            borderSide: BorderSide(
                color: _store.amount > 0 ? StegosColors.white : Colors.redAccent, width: 1));
        return _withLabel(
          'type amount',
          Row(
            children: <Widget>[
              Container(
                width: 118,
                padding: const EdgeInsets.only(bottom: 19),
                child: TextField(
                  decoration: InputDecoration(
                      enabledBorder: textFieldBorder, focusedBorder: textFieldBorder),
                  keyboardType: TextInputType.number,
                  onChanged: (String value) {
                    final v = double.tryParse(value.replaceAll(',', '.'));
                    if (v != null) {
                      runInAction(() {
                        _store.amount = v;
                      });
                    }
                  },
                ),
              ),
              const Text('STG'),
            ],
          ),
        );
      });

  Widget _buildFeeDropdown() => Observer(builder: (context) {
        return _withLabel(
            'Fee',
            Stack(children: [
              Container(
                padding: const EdgeInsets.only(bottom: 19).copyWith(right: 165),
                child: DropdownButton<double>(
                  value: _store.fee,
                  isExpanded: true,
                  elevation: 16,
                  underline: Container(
                    height: 1,
                    color: StegosColors.white,
                  ),
                  onChanged: (v) {
                    runInAction(() {
                      _store.fee = v;
                    });
                  },
                  items:
                      [Pair<String, double>('Standard', 0.001), Pair<String, double>('Fast', 0.005)]
                          .map<DropdownMenuItem<double>>((value) => DropdownMenuItem<double>(
                                value: value.second,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text('${value.first}'),
                                  ],
                                ),
                              ))
                          .toList(),
                ),
              ),
              Container(
                alignment: Alignment.bottomRight,
                child: Container(
                  width: 150,
                  height: 40,
                  padding: const EdgeInsets.only(top: 9),
                  margin: const EdgeInsets.only(bottom: 19),
                  decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(width: 1, color: StegosColors.white))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        '${_store.fee} STG ',
                        style: const TextStyle(fontSize: 18),
                      ),
                      const Text(
                        'per UTXO',
                        style: TextStyle(fontSize: 12),
                      )
                    ],
                  ),
                ),
              )
            ]));
      });

  Widget _buildCommentTextField() => _withLabel(
        'Comment',
        Container(
          padding: const EdgeInsets.only(bottom: 19),
          child: TextField(
            onChanged: (v) {
              runInAction(() {
                _store.comment = v;
              });
            },
          ),
        ),
      );

  Widget _buildCertificateCheckbox() => Observer(builder: (context) {
        return Transform.translate(
          offset: const Offset(-10, 0),
          child: Row(
            children: <Widget>[
              Checkbox(
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                onChanged: (v) {
                  runInAction(() {
                    _store.generateCertificate = v;
                  });
                },
                value: _store.generateCertificate,
                checkColor: StegosColors.backgroundColor,
              ),
              const Text('Generate certificate')
            ],
          ),
        );
      });

  Widget _buildSendButton() => Observer(builder: (context) {
        final env = Provider.of<StegosEnv>(context);
        final nodeService = env.nodeService;
        return RaisedButton(
          elevation: 8,
          disabledElevation: 8,
          onPressed: _store.isValidForm && nodeService.operable
              ? () async {
                  await nodeService.unsealAccount(widget.account, force: true);
                  unawaited(nodeService.pay(
                      account: _store.senderAccount,
                      recipient: _store.toAddress,
                      amount: (_store.amount * 1e6).ceil(),
                      comment: _store.comment,
                      withCertificate: _store.generateCertificate));
                  await StegosApp.navigatorState
                      .pushReplacementNamed(Routes.account, arguments: _store.senderAccount);
                }
              : null,
          child: const Text('SEND'),
        );
      });

  void _scanQr() async {
    final toAddress = await appShowDialog<String>(builder: (context) => QrReaderScreen());
    if (toAddress == null) {
      return;
    }
    runInAction(() {
      _store.toAddress = toAddress;
      setState(() {
        _addressTextController.text = toAddress;
      });
    });
  }
}
