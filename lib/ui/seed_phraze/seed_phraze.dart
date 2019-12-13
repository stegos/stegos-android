import 'package:flutter/material.dart';
import 'package:stegos_wallet/ui/themes.dart';

class SeedPhraze extends StatefulWidget {
  SeedPhraze({Key key, this.words, this.onChanged, this.readOnly = false}) : super(key: key);

  final Map<int, String> words;
  final Function(int, String) onChanged;
  final bool readOnly;

  @override
  _SeedPhrazeState createState() => _SeedPhrazeState();
}

class _SeedPhrazeState extends State<SeedPhraze> {
  Map<int, String> words;
  Function(int, String) onChanged;
  bool readOnly;

  @override
  void initState() {
    super.initState();
    setState(() {
      words = widget.words;
      readOnly = widget.readOnly;
      onChanged = widget.onChanged;
    });
  }

  @override
  void didUpdateWidget(SeedPhraze oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {
      words = widget.words;
      readOnly = widget.readOnly;
      onChanged = widget.onChanged;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: _buildForm(),
    );
  }

  Widget _buildForm() => Form(
        child: Column(
          children: words.entries
              .map((e) => Container(
                    height: 65,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildTextField(e.key, e.value),
                  ))
              .toList(),
        ),
      );

  Widget _buildTextField(int idx, String text) {
    final controller = TextEditingController(text: text);
    return Stack(
      alignment: Alignment.centerLeft,
      children: <Widget>[
        Builder(
            builder: (context) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 13.0, vertical: 6.0),
                  child: Text(
                    '${idx + 1}.',
                    style: StegosThemes.defaultInputTextStyle,
                  ),
                )),
        TextField(
          controller: controller,
          onChanged: (val) => _onTextFieldChanged(idx, val),
          readOnly: readOnly,
          enabled: !readOnly,
          style: StegosThemes.defaultInputTextStyle,
        )
      ],
    );
  }

  void _onTextFieldChanged(int idx, String value) {
    if (onChanged is Function(int, String)) {
      onChanged(idx, value);
    }
  }
}
