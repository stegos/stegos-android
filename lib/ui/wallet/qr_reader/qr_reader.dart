import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:stegos_wallet/utils/stegos_address.dart';

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
      if (widget.isScanning && validateStegosAddress(scanData)) {
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
