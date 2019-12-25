import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stegos_wallet/ui/themes.dart';

enum DialogSide {
  left,
  right,
}

class MessageBubble extends StatelessWidget {
  const MessageBubble(this.message, {Key key, this.side = DialogSide.left, this.senderName = ''})
      : super(key: key);

  final DialogSide side;
  final String senderName;
  final String message;

  Color get color {
    return side == DialogSide.left
        ? const Color(0xff1e2432)
        : StegosColors.primaryColorDark.withOpacity(0.4);
  }

  Widget get bubbleTail => Container(
        alignment: side == DialogSide.left ? Alignment.bottomLeft : Alignment.bottomRight,
          child: Icon(
            side == DialogSide.left ? Icons.arrow_left : Icons.arrow_right,
            color: color,
          ),
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: side == DialogSide.left ? Alignment.topLeft : Alignment.topRight,
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment:
            side == DialogSide.left ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: <Widget>[
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: senderName.isNotEmpty
                  ? Text(senderName, style: TextStyle(color: StegosColors.primaryColorDark))
                  : null),
          Stack(
            alignment: Alignment.bottomCenter,
            children: <Widget>[
              Container(
                alignment: side == DialogSide.left ? Alignment.topLeft : Alignment.topRight,
                child: ConstrainedBox(
                  constraints: BoxConstraints.loose(Size(230, double.maxFinite)),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    margin: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
                    child: Text(
                      message,
                      style: TextStyle(color: StegosColors.white, fontSize: 18),
                    ),
                  ),
                ),
              ),
              bubbleTail,
            ],
          ),
        ],
      ),
    );
  }
}
