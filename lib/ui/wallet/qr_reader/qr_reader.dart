import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:stegos_wallet/ui/app.dart';
import 'package:stegos_wallet/widgets/widget_app_bar.dart';

class QrReader extends StatefulWidget {
  @override
  _QrReaderState createState() => _QrReaderState();
}

class _QrReaderState extends State<QrReader> {
  static final RegExp _stegosAddressRegExp = RegExp(
    r'^st[rgt]1[ac-hj-np-z02-9]{8,87}$',
    caseSensitive: false,
    multiLine: false,
  );

  final GlobalKey _qrViewKey = GlobalKey(debugLabel: 'QR');
  QRViewController controller;

  bool isValidToAddress(String address) {
    if (address == null) {
      return false;
    } else {
      return _stegosAddressRegExp.hasMatch(address);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        backgroundColor: Colors.transparent,
        centerTitle: false,
        leading: IconButton(
          icon: const SizedBox(
            width: 24,
            height: 24,
            child: Image(image: AssetImage('assets/images/arrow_back.png')),
          ),
          onPressed: () => StegosApp.navigatorState.pop(null),
        ),
        title: const Text('Scaning QR code'),
      ),
      body: Stack(
        children: <Widget>[
          Container(
              child: Stack(
              children: <Widget>[
                Container(
                  alignment: Alignment.center,
                  child: QRView(
                    key: _qrViewKey,
                    onQRViewCreated: _onQRViewCreated,
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 50),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Container(
                        decoration:
                            BoxDecoration(border: Border.all(color: Colors.redAccent, width: 2)),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          Container(
            alignment: Alignment.bottomCenter,
            child: controller != null
                ? Container(
                    height: 120,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        IconButton(
                            onPressed: () {
                              controller.toggleFlash();
                            },
                            icon: Icon(Icons.flash_on))
                      ],
                    ),
                  )
                : null,
          )
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        if (isValidToAddress(scanData)) {
          controller?.dispose();
          StegosApp.navigatorState.pop(scanData);
        }
        // do something
      });
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
