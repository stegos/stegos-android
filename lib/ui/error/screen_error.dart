import 'package:flutter/widgets.dart';

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({Key key, @required this.message}) : super(key: key);

  final String message;

  @override
  Widget build(BuildContext context) {
    // todo:
    return Container(
      alignment: Alignment.center,
      child: Text('Recover screen'),
    );
  }
}
