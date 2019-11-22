import 'dart:math' as Math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stegos_wallet/ui/themes.dart';

/// Pinpad panel widget.
///
class PinpadWidget extends StatefulWidget {
  PinpadWidget(
      {Key key,
      @required this.onPinReady,
      this.digits = 4,
      this.title = 'PIN CODE',
      this.fingerprint = true})
      : super(key: key);

  final int digits;

  final String title;

  final bool fingerprint;

  final void Function(String) onPinReady;

  @override
  State<StatefulWidget> createState() => _PinpadWidgetState();
}

class _PinpadWidgetState extends State<PinpadWidget> {
  static const _logoIcon = Image(
    image: AssetImage('assets/images/stegos.png'),
    width: 140,
    height: 133,
  );

  static const _keyTextStyle =
      TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.w500);

  final _fingerprintIcon = SvgPicture.asset('assets/images/fingerprint.svg');

  String _code = '';

  void _ready() {
    if (widget.onPinReady != null) {
      widget.onPinReady(_code);
    }
  }

  void Function() _addDigit(String c) => () {
        setState(() {
          if (_code.length >= widget.digits) return;
          _code = _code + c;
          if (_code.length == widget.digits) {
            _ready();
          }
        });
      };

  void Function() _removeDigit() => () {
        setState(() {
          _code = _code.substring(0, Math.max(0, _code.length - 1));
        });
      };

  void Function() _onFingerprint() => () {
        // todo
        print('Scan fingerprint');
      };

  @override
  Widget build(BuildContext context) {
    final keySize = MediaQuery.of(context).size.width / 5.29;

    Widget buildTextKey(String text) => Text(text, style: _keyTextStyle);

    Widget buildOutlineBtn(Widget key, void Function() action) => Center(
          child: Container(
            width: keySize,
            height: keySize,
            child: OutlineButton(
              onPressed: action,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
              color: Colors.white,
              highlightedBorderColor: StegosColors.primaryColor,
              borderSide:
                  const BorderSide(width: 0.8, color: Colors.white, style: BorderStyle.solid),
              child: key,
            ),
          ),
        );

    Widget buildIcoBtn(Widget key, void Function() action) => Center(
          child: Container(
            width: keySize,
            height: keySize,
            child: IconButton(
              icon: key,
              onPressed: action,
              color: Colors.white,
            ),
          ),
        );

    List<Widget> buildDots() {
      final int codeLength = _code.length;
      final List<Widget> dots = [];
      for (int i = 0; i < widget.digits; i++) {
        dots.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Container(
              width: 17,
              height: 17,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.5),
                color: i < codeLength ? StegosColors.primaryColor : Colors.transparent,
                border: Border.all(
                  color: i < codeLength ? Colors.transparent : Colors.white,
                  width: 1,
                ),
              ),
            ),
          ),
        );
      }
      return dots;
    }

    Widget buildEmptyBtn() => SizedBox(height: keySize, width: keySize);

    final mapKeyToActions = <Widget>[
      ...List<Widget>.generate(
          9, (idx) => buildOutlineBtn(buildTextKey('${idx + 1}'), _addDigit('${idx + 1}'))),
      if (widget.fingerprint) buildIcoBtn(_fingerprintIcon, _onFingerprint()) else buildEmptyBtn(),
      buildOutlineBtn(buildTextKey('0'), _addDigit('0')),
      buildIcoBtn(Icon(Icons.backspace, color: Colors.white, size: keySize / 2), _removeDigit()),
    ];

    return Theme(
        data: StegosThemes.pinpadTheme,
        child: Container(
            decoration: BoxDecoration(
                image: DecorationImage(
              image: const AssetImage('assets/images/welcome_background.png'),
              fit: BoxFit.cover,
            )),
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: keySize - 17),
              children: <Widget>[
                const SizedBox(height: 20),
                _logoIcon,
                Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontWeight: FontWeight.normal, fontSize: 16, color: Colors.white),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 18, left: 0, right: 0, bottom: 14),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: buildDots()),
                ),
                GridView.count(
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  children: mapKeyToActions,
                ),
              ],
            )));
  }
}
