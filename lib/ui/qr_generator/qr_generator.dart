import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:stegos_wallet/ui/app.dart';
import 'package:stegos_wallet/ui/themes.dart';
import 'package:stegos_wallet/widgets/widget_app_bar.dart';

class QrGenerator extends StatefulWidget {
  QrGenerator({@required this.title, @required this.qrData});

  final String title;
  final String qrData;

  @override
  _QrGeneratorState createState() => _QrGeneratorState();
}

class _QrGeneratorState extends State<QrGenerator> {
  static const _iconBackImage = AssetImage('assets/images/arrow_back.png');
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBarWidget(
          backgroundColor: Colors.transparent,
          centerTitle: false,
          leading: IconButton(
            icon: const SizedBox(
              width: 24,
              height: 24,
              child: Image(image: _iconBackImage),
            ),
            onPressed: () => StegosApp.navigatorState.pop(null),
          ),
          title: Text(widget.title),
        ),
        body: Center(
            child: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
          final double maxWidth = constraints.maxWidth;
          return Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
            SizedBox(
                width: maxWidth * 0.9,
                child: SelectableText(
                  widget.qrData,
                  style: const TextStyle(fontSize: 9),
                  textAlign: TextAlign.center,
                )),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _copyToClipboard,
              child: QrImage(
                backgroundColor: StegosColors.white,
                data: widget.qrData,
                version: QrVersions.auto,
                size: maxWidth * 0.9,
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: maxWidth * 0.9,
              child: const Text(
                'Scan this QR code with app to send funds \n or tap to copy to clipboard',
                textAlign: TextAlign.center,
              ),
            )
          ]);
        })));
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: widget.qrData));
    _scaffoldKey.currentState.showSnackBar(const SnackBar(
      backgroundColor: StegosColors.accentColor,
      content: Text(
        'Copied to Clipboard',
        style: TextStyle(color: StegosColors.white),
      ),
    ));
  }
}
