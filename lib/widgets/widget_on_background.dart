import 'package:flutter/widgets.dart';

class WidgetOnBackground extends StatelessWidget {
  const WidgetOnBackground({Key key, @required this.child}) : super(key: key);

  static const backgrounds = [
    [1136.0 / 640.0, 'assets/images/background-16-9.png'],
    [1024.0 / 640.0, 'assets/images/background-16-10.png'],
    [853.0 / 640.0, 'assets/images/background-4-3.png'],
    [1088.0 / 640.0, 'assets/images/background-1088-640.png'],
  ];

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final screenRatio = mq.size.height / mq.size.width;
    final asset = backgrounds.fold(backgrounds[0], (value, item) {
      final itemRatio = item[0] as double;
      final valueRatio = value[0] as double;
      return (itemRatio - screenRatio).abs() < (valueRatio - screenRatio).abs() ? item : value;
    })[1] as String;
    return SafeArea(
        child: Stack(
      fit: StackFit.expand,
      children: <Widget>[
        Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage(asset),
                    fit: BoxFit.cover,
                    alignment: const Alignment(0, -1)))),
        child
      ],
    ));
  }
}
