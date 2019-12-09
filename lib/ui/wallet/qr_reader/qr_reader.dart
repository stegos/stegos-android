import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QrReader extends StatefulWidget {
  @override
  _QrReaderState createState() => _QrReaderState();
}

class _QrReaderState extends State<QrReader> {
  final GlobalKey _qrViewKey = GlobalKey(debugLabel: 'QR');
  final _key = GlobalKey<ScaffoldState>();
  var qrText = '';
  QRViewController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      body: Column(
        children: <Widget>[
          Expanded(
              flex: 5,
              child: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
                final maxWidth = constraints.maxWidth;
//                final maxHeight = constraints.maxHeight;
                return Stack(
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
                        padding: EdgeInsets.symmetric(horizontal: maxWidth * 0.15),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.redAccent, width: 2)),
                          ),
                        ),
                      ),
                    )
                  ],
                );
              })),
          Expanded(
            flex: 1,
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    IconButton(
                        onPressed: controller != null
                            ? () {
                                controller.flipCamera();
                              }
                            : null,
                        icon: Icon(Icons.switch_camera)),
                    IconButton(
                        onPressed: controller != null
                            ? () {
                                controller.toggleFlash();
                              }
                            : null,
                        icon: Icon(Icons.flash_on))
                  ],
                ),
                Container(
                  height: 48,
                  alignment: Alignment.center,
                  child: qrText.isNotEmpty
                      ? FlatButton.icon(
                          icon: Icon(Icons.content_copy),
                          label: Text(qrText, overflow: TextOverflow.ellipsis),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: qrText));
                            _key.currentState.showSnackBar(const SnackBar(
                              content: Text('Copied to Clipboard'),
                            ));
                          },
                        )
                      : const Text('Scaning for QR code'),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      Feedback.forTap(context);
      setState(() {
        qrText = scanData;
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
