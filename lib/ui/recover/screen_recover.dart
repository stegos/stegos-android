import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// Stegos account recovering screen
///
class RecoverScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _RecoverScreenState();
}

class _RecoverScreenState extends State<RecoverScreen> {
  _RecoverScreenState({int wordsCount = 12, List<String> words}) {
    for (var i = 0; i < wordsCount; i++) {
      phrazeWords.add(words != null && words.length > i ? words[i] : '');
    }
  }

  final phrazeWords = <String>[];
  bool isAllWordsFilled = false;

  bool checkAllWordsFilled() {
    for (var i = 0; i < phrazeWords.length; i++) {
      if (phrazeWords[i].trim().isEmpty) {
        isAllWordsFilled = false;
        return false;
      }
    }
    isAllWordsFilled = true;
    return true;
  }

  Color get restoreButtonColor {
    // todo:
    return Color(0xff505050).withAlpha(isAllWordsFilled ? 0xff : 0x88);
  }

  EdgeInsets get defaultPadding => const EdgeInsets.all(16.0);

  void _onRestorePressed() {
    // todo:
    print('RESTORING ACCOUNT USING SEED WORDS: ');
    for (var i = 0; i < phrazeWords.length; i++) {
      print(phrazeWords[i]);
    }
  }

  Widget _buildRow(int i) {
    return ListTile(
        title: TextField(
      onChanged: (text) {
        phrazeWords[i] = text;
        checkAllWordsFilled();
      },
      decoration: InputDecoration(icon: Text('${i + 1}.'), hintText: ''),
    ));
  }

  Widget _buildWords(int amount) {
    return ListView.builder(
        padding: defaultPadding,
        itemBuilder: (context, i) {
          return i < phrazeWords.length ? _buildRow(i) : null;
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context, false),
          ),
          title: Text('Restore account'),
        ),
        body: Column(
          children: <Widget>[
            Padding(
              padding: defaultPadding,
              child: Text(
                'In order to restore your existing account, please fill all words from the recovery phrase in correct order.',
                textAlign: TextAlign.center,
                style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xff656565)),
              ),
            ),
            Expanded(child: _buildWords(12)),
            SizedBox(
                width: double.infinity,
                child: Padding(
                    padding: defaultPadding,
                    child: RaisedButton(
                      onPressed: _onRestorePressed,
                      color: restoreButtonColor,
                      child: Text(
                        'RESTORE',
                        style: TextStyle(color: Color(0xffffffff)),
                      ),
                    )))
          ],
        ));
  }
}
