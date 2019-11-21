import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stegos_wallet/ui/routes.dart';
import 'package:stegos_wallet/ui/themes.dart';

class PinpadScreen extends StatefulWidget {
  PinpadScreen({Key key, final this.size}) : super(key: key);

  final int size;

  @override
  PinpadScreenState createState() => PinpadScreenState(size);
}

class PinpadScreenState extends State<PinpadScreen> {
  PinpadScreenState(this.size) {
    mapKeyToActions = [
      _buildOutlineBtn(_buildTextKey('1'), _setChar('1')),
      _buildOutlineBtn(_buildTextKey('2'), _setChar('2')),
      _buildOutlineBtn(_buildTextKey('3'), _setChar('3')),
      _buildOutlineBtn(_buildTextKey('4'), _setChar('4')),
      _buildOutlineBtn(_buildTextKey('5'), _setChar('5')),
      _buildOutlineBtn(_buildTextKey('6'), _setChar('6')),
      _buildOutlineBtn(_buildTextKey('7'), _setChar('7')),
      _buildOutlineBtn(_buildTextKey('8'), _setChar('8')),
      _buildOutlineBtn(_buildTextKey('9'), _setChar('9')),
      _buildIcoBtn(fingerprintIcon, _onFingerprint()),
      _buildOutlineBtn(_buildTextKey('0'), _setChar('0')),
      _buildIcoBtn(Icon(Icons.backspace, color: Colors.white, size: 32), _removeChar()),
    ];
  }

  final keyTextStyle = TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.w500);
  final fingerprintIcon = SvgPicture.asset('assets/images/fingerprint.svg');
  final stegosLogoIcon = const Image(
    image: AssetImage('assets/images/stegos.png'),
    width: 140,
    height: 133,
  );

  int size;

  List<Widget> mapKeyToActions;

  void Function() _setChar(String c) => () {
        setState(() {
          if (code.length >= size) return;
          code = code + c;
          if (code.length == size) {
            _submit();
          }
        });
      };

  void Function() _onFingerprint() => () {
        print('Scan fingerprint');
      };

  void Function() _removeChar() => () {
        setState(() {
          code = code.substring(0, max(0, code.length - 1));
        });
      };

  void _submit() {
    print(code);
    Navigator.pushNamed(context, Routes.welcome);
  }

  String code = '';

  Widget _buildTextKey(String text) => Text(text, style: keyTextStyle);

  Widget _buildOutlineBtn(Widget key, void Function() action) => Center(
        child: Container(
          width: 68,
          height: 68,
          child: OutlineButton(
            onPressed: action,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
            ),
            color: Colors.white,
            highlightedBorderColor: StegosColors.primaryColor,
            borderSide: BorderSide(width: 0.8, color: Colors.white, style: BorderStyle.solid),
            child: key,
          ),
        ),
      );

  Widget _buildIcoBtn(Widget key, void Function() action) => Center(
        child: Container(
          width: 68,
          height: 68,
          child: IconButton(
            icon: key,
            onPressed: action,
            color: Colors.white,
          ),
        ),
      );

  List<Widget> _dots() {
    final int codeLength = code.length;
    final List<Widget> dots = [];
    for (int i = 0; i < size; i++) {
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

  @override
  Widget build(BuildContext context) => Theme(
        data: StegosThemes.pinpadTheme,
        child: Scaffold(
          body: Container(
            decoration: BoxDecoration(
                image: DecorationImage(
              image: const AssetImage('assets/images/welcome_background.png'),
              fit: BoxFit.cover,
            )),
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: <Widget>[
                const SizedBox(height: 20),
                stegosLogoIcon,
                Text(
                  'PIN CODE',
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(fontWeight: FontWeight.normal, fontSize: 16, color: Colors.white),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 18, left: 10, right: 10, bottom: 14),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: _dots()),
                ),
                GridView.count(
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  children: mapKeyToActions,
                ),
              ],
            ),
          ),
        ),
      );
}
