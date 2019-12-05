import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stegos_wallet/env_stegos.dart';
import 'package:stegos_wallet/services/service_node.dart';
import 'package:stegos_wallet/ui/themes.dart';
import 'package:stegos_wallet/widgets/widget_app_bar.dart';
import 'package:stegos_wallet/widgets/widget_scaffold_body_wrapper.dart';

class FeeType {
  FeeType(this.name, this.amount);

  final String name;
  final double amount;
}

class PayScreen extends StatefulWidget {
  @override
  _PayScreenState createState() => _PayScreenState();
}

class _PayScreenState extends State<PayScreen> {
  static const _iconBackImage = AssetImage('assets/images/arrow_back.png');

  AccountStore selectedAccount;
  String selectedRecipient;
  String toAddress;
  FeeType selectedFee;
  bool generateCertificate = false;

  final firstLabelStyle = TextStyle(fontSize: 12, color: StegosColors.white.withOpacity(0.8));
  final secondLabelStyle = TextStyle(fontSize: 12, color: StegosColors.white.withOpacity(0.5));

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
              child: Image(image: _iconBackImage),
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
                _buildToDropdown(),
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

  Widget _buildAccountDropdown() {
    final env = Provider.of<StegosEnv>(context);
    final List<AccountStore> accountsList = env.nodeService.accountsList;
    return _withLabel(
        Text('from', style: secondLabelStyle),
        _withLabel(
            Text('Choose account', style: firstLabelStyle),
            Container(
              padding: const EdgeInsets.only(bottom: 19),
              child: DropdownButton<AccountStore>(
                value: selectedAccount,
                icon: Icon(Icons.keyboard_arrow_down),
                isExpanded: true,
                iconSize: 24,
                elevation: 16,
                underline: Container(
                  height: 1,
                  color: StegosColors.white,
                ),
                onChanged: (AccountStore newValue) {
                  setState(() {
                    selectedAccount = newValue;
                  });
                },
                items: accountsList.map<DropdownMenuItem<AccountStore>>((AccountStore value) {
                  return DropdownMenuItem<AccountStore>(
                    value: value,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[Text(value.humanName), Text('${value.humanBalance} STG')],
                    ),
                  );
                }).toList(),
              ),
            )));
  }

  Widget _buildToDropdown() {
    return _withLabel(
        Text('to', style: secondLabelStyle),
        _withLabel(
            Text('choose user from your contact', style: firstLabelStyle),
            Container(
              padding: const EdgeInsets.only(bottom: 19),
              child: DropdownButton<String>(
                value: selectedRecipient,
                icon: Icon(Icons.keyboard_arrow_down),
                isExpanded: true,
                iconSize: 24,
                elevation: 16,
                underline: Container(
                  height: 1,
                  color: StegosColors.white,
                ),
                onChanged: (String newValue) {
                  setState(() {
                    selectedRecipient = newValue;
                  });
                },
                items: ['account1', 'account2', 'account3']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            )));
  }

  Widget _buildToAddress() {
    return _withLabel(
        Text('or', style: secondLabelStyle),
        _withLabel(
            Text('Choose user from your contact', style: firstLabelStyle),
            Container(
              padding: const EdgeInsets.only(bottom: 19),
              child: TextField(
                onChanged: (String value) {
                  toAddress = value;
                },
              ),
            )));
  }

  Widget _buildAmount() {
    return _withLabel(
        Text('type amount', style: firstLabelStyle),
        Row(
          children: <Widget>[
            Container(
              width: 92,
              padding: const EdgeInsets.only(bottom: 19),
              child: TextField(
                keyboardType: TextInputType.number,
                onChanged: (String value) {
                  toAddress = value;
                },
              ),
            ),
            const Text('STG'),
          ],
        ));
  }

  Widget _buildFeeDropdown() {
    return _withLabel(
        Text('Fee', style: firstLabelStyle),
        Container(
          padding: const EdgeInsets.only(bottom: 19),
          child: DropdownButton<FeeType>(
            value: selectedFee,
            icon: Icon(Icons.keyboard_arrow_down),
            isExpanded: true,
            iconSize: 24,
            elevation: 16,
            underline: Container(
              height: 1,
              color: StegosColors.white,
            ),
            onChanged: (FeeType newValue) {
              setState(() {
                selectedFee = newValue;
              });
            },
            items: [FeeType('Standard', 0.01), FeeType('Fast', 0.05)]
                .map<DropdownMenuItem<FeeType>>((FeeType value) {
              return DropdownMenuItem<FeeType>(
                value: value,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(value.name),
                    Text(
                      '${value.amount} STG per UTXO',
                      style: secondLabelStyle,
                    )
                  ],
                ),
              );
            }).toList(),
          ),
        ));
  }

  Widget _buildCertificateCheckbox() {
    return Container(
      padding: const EdgeInsets.only(bottom: 19),
      child: Row(
        children: <Widget>[
          Checkbox(
            onChanged: (bool value) {
              setState(() {
                generateCertificate = value;
              });
            },
            value: generateCertificate,
          ),
          const Text('Generate certificate')
        ],
      ),
    );
  }

  Widget _buildSendButton() {
    return RaisedButton(
      onPressed: () {},
      child: const Text('SEND'),
    );
  }
}
