import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import 'package:provider/provider.dart';
import 'package:stegos_wallet/env_stegos.dart';
import 'package:stegos_wallet/services/service_node.dart';
import 'package:stegos_wallet/ui/pay/store_screen_pay.dart';
import 'package:stegos_wallet/ui/themes.dart';
import 'package:stegos_wallet/utils/cont.dart';
import 'package:stegos_wallet/widgets/widget_app_bar.dart';
import 'package:stegos_wallet/widgets/widget_scaffold_body_wrapper.dart';

class PayScreen extends StatefulWidget {
  @override
  _PayScreenState createState() => _PayScreenState();
}

class _PayScreenState extends State<PayScreen> {
  final _firstLabelStyle = TextStyle(fontSize: 12, color: StegosColors.white.withOpacity(0.8));
  final _secondLabelStyle = TextStyle(fontSize: 12, color: StegosColors.white.withOpacity(0.5));
  final _store = PayScreenStore();

  @override
  Widget build(BuildContext context) {
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
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('Send STG'),
        ),
        body: ScaffoldBodyWrapperWidget(
          builder: (context) => SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _buildAccountDropdown(),
                //_buildToDropdown(),
                _buildToAddress(),
                _buildAmount(),
                _buildFeeDropdown(),
                _buildCertificateCheckbox(),
                _buildSendButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _withLabel(Widget label, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          height: 16,
          child: label,
        ),
        Container(
          child: content,
        )
      ],
    );
  }

  Widget _buildAccountDropdown() => Observer(builder: (context) {
        final env = Provider.of<StegosEnv>(context);
        final List<AccountStore> accountsList = env.nodeService.accountsList;
        return _withLabel(
            Text('from', style: _secondLabelStyle),
            _withLabel(
                Text('Choose account', style: _firstLabelStyle),
                Container(
                  padding: const EdgeInsets.only(bottom: 19),
                  child: DropdownButton<AccountStore>(
                    value: _store.senderAccount,
                    icon: const Icon(Icons.keyboard_arrow_down),
                    isExpanded: true,
                    iconSize: 24,
                    elevation: 16,
                    underline: Container(
                      height: 1,
                      color: StegosColors.white,
                    ),
                    onChanged: (AccountStore acc) {
                      runInAction(() {
                        _store.senderAccount = acc;
                      });
                    },
                    items: accountsList.map<DropdownMenuItem<AccountStore>>((AccountStore value) {
                      return DropdownMenuItem<AccountStore>(
                        value: value,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(value.humanName),
                            Text('${value.humanBalance} STG')
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                )));
      });

  // Widget _buildToDropdown() {
  //   return _withLabel(
  //       Text('to', style: secondLabelStyle),
  //       _withLabel(
  //           Text('choose user from your contact', style: firstLabelStyle),
  //           Container(
  //             padding: const EdgeInsets.only(bottom: 19),
  //             child: DropdownButton<String>(
  //               value: selectedRecipient,
  //               icon: Icon(Icons.keyboard_arrow_down),
  //               isExpanded: true,
  //               iconSize: 24,
  //               elevation: 16,
  //               underline: Container(
  //                 height: 1,
  //                 color: StegosColors.white,
  //               ),
  //               onChanged: (String newValue) {
  //                 setState(() {
  //                   selectedRecipient = newValue;
  //                 });
  //               },
  //               items: ['account1', 'account2', 'account3']
  //                   .map<DropdownMenuItem<String>>((String value) {
  //                 return DropdownMenuItem<String>(
  //                   value: value,
  //                   child: Text(value),
  //                 );
  //               }).toList(),
  //             ),
  //           )));
  //}

  Widget _buildToAddress() => _withLabel(
      Text('to', style: _secondLabelStyle),
      _withLabel(
          Text('recipient address', style: _firstLabelStyle),
          Container(
            padding: const EdgeInsets.only(bottom: 19),
            child: TextField(
              controller: TextEditingController(text: _store.toAddress),
              onChanged: (String value) {
                runInAction(() {
                  _store.toAddress = value;
                });
              },
            ),
          )));

  Widget _buildAmount() => _withLabel(
      Text('type amount', style: _firstLabelStyle),
      Row(
        children: <Widget>[
          Container(
            width: 92,
            padding: const EdgeInsets.only(bottom: 19),
            child: TextField(
              keyboardType: TextInputType.number,
              onChanged: (String value) {
                final v = double.tryParse(value);
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
      ));

  Widget _buildFeeDropdown() => Observer(builder: (context) {
        return _withLabel(
            Text('Fee', style: _firstLabelStyle),
            Container(
              padding: const EdgeInsets.only(bottom: 19),
              child: DropdownButton<double>(
                value: _store.fee,
                icon: const Icon(Icons.keyboard_arrow_down),
                isExpanded: true,
                iconSize: 24,
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
                                  Text(value.first),
                                  Text(
                                    '${value.second} STG per UTXO',
                                    style: _secondLabelStyle,
                                  )
                                ],
                              ),
                            ))
                        .toList(),
              ),
            ));
      });

  Widget _buildCertificateCheckbox() => Observer(builder: (context) {
        return Container(
          padding: const EdgeInsets.only(bottom: 19),
          child: Row(
            children: <Widget>[
              Checkbox(
                onChanged: (v) {
                  runInAction(() {
                    _store.generateCertificate = v;
                  });
                },
                value: _store.generateCertificate,
              ),
              const Text('Generate certificate')
            ],
          ),
        );
      });

  Widget _buildSendButton() {
    return RaisedButton(
      onPressed: () {
        // todo: validation
        // todo:
      },
      child: const Text('SEND'),
    );
  }
}
