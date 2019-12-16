import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QrReader extends StatefulWidget {
  const QrReader({Key key, @required this.onStegosAddressFound, this.isScanning = true})
      : super(key: key);

  final void Function(String) onStegosAddressFound;
  final bool isScanning;

  @override
  _QrReaderState createState() => _QrReaderState();
}

class _QrReaderState extends State<QrReader> {
  final GlobalKey _qrViewKey = GlobalKey(debugLabel: 'QR');
  QRViewController controller;

  static final RegExp _stegosAddressRegExp = RegExp(
    r'^st[rgt]1[ac-hj-np-z02-9]{8,87}$',
    caseSensitive: false,
    multiLine: false,
  );

  bool isValidToAddress(String address) {
    if (address == null) {
      return false;
    } else {
      return _stegosAddressRegExp.hasMatch(address);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
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
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((String scanData) {
      if (widget.isScanning && isValidToAddress(scanData)) {
        widget.onStegosAddressFound(scanData);
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
