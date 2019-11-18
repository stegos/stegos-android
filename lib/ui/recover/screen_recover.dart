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
    _buildWords(wordsCount, words);
  }

  final _formKey = GlobalKey<FormState>();

  final phrazeWords = <String>[];
  final List<TextFormField> wordsInputs = <TextFormField>[];

  bool _isFormValid = false;

  Color get restoreButtonColor => const Color(0xff505050).withAlpha(_isFormValid ? 0xff : 0x88);

  EdgeInsets get defaultPadding => const EdgeInsets.all(16.0);

  void _onRestorePressed() {
    setState(() {
      _isFormValid = _formKey.currentState?.validate();
    });
    print('RESTORING ACCOUNT USING SEED WORDS: ');
    for (var i = 0; i < phrazeWords.length; i++) {
      print('${i + 1}. ${phrazeWords[i]}');
    }
    print('Form data is ${_isFormValid ? 'valid' : 'invalid'}');
  }

  TextFormField _buildRow(int i, String value) {
    final controller = TextEditingController(text: value);
    return TextFormField(
      validator: (value) {
        if (value.trim().isEmpty) {
          return 'Please enter some text';
        }
        return null;
      },
      controller: controller,
      onChanged: (text) {
        phrazeWords[i] = controller.text;
        _formKey.currentState?.validate();
      },
      decoration:
          InputDecoration(icon: Container(width: 24, child: Text('${i + 1}.')), hintText: ''),
    );
  }

  void _buildWords(int amount, List<String> words) {
    for (var i = 0; i < amount; i++) {
      phrazeWords.add(words != null && words.length > i ? words[i] : '');
      wordsInputs.add(_buildRow(i, phrazeWords[i]));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, false),
        ),
        title: const Text('Restore account'),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: defaultPadding,
            child: Text(
              'In order to restore your existing account, please fill all words from the recovery phrase in correct order.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 18, color: const Color(0xff656565)),
            ),
          ),
          Expanded(
              child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: wordsInputs
                    .map<Widget>((field) => Container(
                          height: 65,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: field,
                        ))
                    .toList(),
              ),
            ),
          )),
          SizedBox(
              width: double.infinity,
              child: Padding(
                  padding: defaultPadding,
                  child: RaisedButton(
                    onPressed: _onRestorePressed,
                    color: restoreButtonColor,
                    child: Text(
                      'RESTORE',
                      style: TextStyle(color: const Color(0xffffffff)),
                    ),
                  )))
        ],
      ));
}
