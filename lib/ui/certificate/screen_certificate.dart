import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:provider/provider.dart';
import 'package:stegos_wallet/env_stegos.dart';
import 'package:stegos_wallet/log/loggable.dart';
import 'package:stegos_wallet/services/service_node.dart';
import 'package:stegos_wallet/ui/themes.dart';
import 'package:stegos_wallet/widgets/widget_app_bar.dart';

import 'certificate_pdf.dart';

class CertificateScreen extends StatefulWidget {
  CertificateScreen({Key key, this.transaction}) : super(key: key);

  final TxStore transaction;

  @override
  CertificateScreenState createState() => CertificateScreenState();
}

class CertificateScreenState extends State<CertificateScreen> with Loggable<CertificateScreenState> {
  TxValidationInfo txvInfo;

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    if (txvInfo == null) {
      final env = Provider.of<StegosEnv>(context);
      final info = await env.nodeService.validateTxCertificate(
          widget.transaction);
      if (info != null) {
        setState(() {
          txvInfo = info;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const TextStyle verificationTextStyle = TextStyle(fontSize: 10);
    return Theme(
        data: StegosThemes.AccountTheme,
        child: Scaffold(
          appBar: AppBarWidget(
            centerTitle: false,
            backgroundColor: Theme
                .of(context)
                .colorScheme
                .primary,
            leading: IconButton(
              icon: const Image(
                image: AssetImage('assets/images/arrow_back.png'),
                width: 24,
                height: 24,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              )
            ],
            title: const Text('Certificate'),
          ),
          body: Column(
            children: <Widget>[
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Container(
                    child: Container(
                        padding: const EdgeInsets.only(top: 15),
                        color: StegosColors.splashBackground,
                        child: Column(
                          children: <Widget>[
                            Container(
                              padding: const EdgeInsets.only(
                                  left: 15, right: 15),
                              child:
                              Row(mainAxisAlignment: MainAxisAlignment
                                  .spaceBetween, children: [
                                Text(widget.transaction.humanCreationTime,
                                    style: const TextStyle(fontSize: 14)),
                                Text(widget.transaction.humanStatus,
                                    style: const TextStyle(fontSize: 14))
                              ]),
                            ),
                            const SizedBox(height: 34),
                            Text('${widget.transaction.humanAmount} STG',
                                style: const TextStyle(fontSize: 32)),
                            const SizedBox(height: 22),
                            if (txvInfo != null) _buildButtons()
                          ],
                        ))),
              ]),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(top: 27, left: 30, right: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        alignment: Alignment.center,
                        child: Text(
                          'Transaction data',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      _buildTxValue(
                          'Sender', '${widget.transaction.account.pkey}'),
                      _buildTxValue('Recepient',
                          '${widget.transaction.certOutput['recipient']}'),
                      _buildTxValue('R-value',
                          '${widget.transaction.certOutput['rvalue']}'),
                      _buildTxValue('UTXO ID',
                          '${widget.transaction.certOutput['output_hash']}'),
                      if (txvInfo != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          'Transaction verification',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 22),
                        Row(
                          children: const [
                            Expanded(
                              child: Text('Sender: Valid',
                                  style: verificationTextStyle),
                            ),
                            Expanded(
                              child: Text('UTXO ID: Valid',
                                  style: verificationTextStyle),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Expanded(
                              child: Text('Recipient: Valid',
                                  style: verificationTextStyle),
                            ),
                            Expanded(
                              child: Text('UTXO Block: #${txvInfo.epoch}',
                                  style: verificationTextStyle),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                      ]
                    ],
                  ),
                ),
              )
            ],
          ),
        ));
  }

  Widget _buildTxValue(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(
              width: 1, color: StegosColors.white.withOpacity(0.5)))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            label,
            style: TextStyle(
                fontSize: 12, color: StegosColors.white.withOpacity(0.54)),
          ),
          const SizedBox(height: 10),
          SelectableText(value,
              style: TextStyle(
                  fontSize: 12, color: StegosColors.white.withOpacity(0.87))),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Container _buildButtons() =>
      Container(
        color: StegosColors.backgroundColor,
        child: Container(
          padding: const EdgeInsets.only(top: 33, bottom: 25),
          margin: const EdgeInsets.symmetric(horizontal: 10),
          decoration: const BoxDecoration(
            border: Border(
                bottom: BorderSide(color: StegosColors.white, width: 1)),
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
                      onPressed: _saveAsPDF,
                      color: StegosColors.splashBackground,
                      child: SvgPicture.asset('assets/images/pdf.svg'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Save as PDF',
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
                      child: SvgPicture.asset('assets/images/share.svg'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: 71,
                    child: const Text(
                      'Share',
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

  void _saveAsPDF() async {
    final env = Provider.of<StegosEnv>(context);
    final dataDirectory = await getExternalStorageDirectory();
    final String appDocPath = dataDirectory.path;
    final File file = File('$appDocPath/certificate.pdf');
    log.info('Save as file ${file.path} ...');
    await file.writeAsBytes((await generateDocument(widget.transaction, txvInfo)).save());
    log.info('Saved successfully');
    await OpenFile.open(file.path);
  }
}