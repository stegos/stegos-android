import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:stegos_wallet/ui/app.dart';
import 'package:stegos_wallet/ui/wallet/qr_reader/qr_reader.dart';
import 'package:stegos_wallet/widgets/widget_app_bar.dart';

class QrReaderScreen extends StatefulWidget {
  @override
  _QrReaderScreenState createState() => _QrReaderScreenState();
}

class _QrReaderScreenState extends State<QrReaderScreen> {
  bool isScanning = true;

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
        body: QrReader(
          isScanning: isScanning,
          onStegosAddressFound: onStegosAddressFound,
        ));
  }

  void onStegosAddressFound(String address) {
    setState(() {
      isScanning = false;
    });
    StegosApp.navigatorState.pop(address);
  }
}
