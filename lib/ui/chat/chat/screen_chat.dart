import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:stegos_wallet/ui/chat/message_bubble/message_bubble.dart';
import 'package:stegos_wallet/ui/themes.dart';
import 'package:stegos_wallet/widgets/widget_app_bar.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

final List<MessageBubble> messages = [
  const MessageBubble(
    'Hey, i heard you\'ve sent a red packet',
    senderName: 'Bill',
  ),
  const MessageBubble(
    'hello! What\'s up? yeah, it was yesterday.',
    side: DialogSide.right,
  ),
  const MessageBubble(
    'How was it?',
    senderName: 'Konstantine',
  ),
  const MessageBubble(
    'It was awesome actually. It became empty in 3 hours. I didn\'t expect it. Probably i was good idea to creare a channel from my Quara followers',
    side: DialogSide.left,
  ),
];

class _ChatScreenState extends State<ChatScreen> {
  Widget _chatItemBuilder(BuildContext context, int index) {
    return messages[index % 3];
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: StegosThemes.ChatTheme,
      child: Scaffold(
        appBar: AppBarWidget(
          centerTitle: false,
          backgroundColor: Theme.of(context).colorScheme.primary,
          leading: IconButton(
            icon: const SizedBox(
              width: 24,
              height: 24,
              child: Image(image: AssetImage('assets/images/arrow_back.png')),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text('Lucky team'),
          actions: <Widget>[IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert))],
        ),
        body: Stack(
          alignment: Alignment.bottomCenter,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 65),
              child: ListView.builder(
                itemBuilder: _chatItemBuilder,
                reverse: true,
              ),
            ),
            Container(
              height: 65,
              color: const Color(0xff0f0f1a),
              child: Stack(
                children: <Widget>[
                  Container(
                    width: 48,
                    alignment: Alignment.center,
                    child: IconButton(
                      icon: Transform.rotate(
                        angle: pi + pi / 4,
                        child: Icon(Icons.attach_file),
                      ),
                      onPressed: () {},
                    ),
                  ),
                  Container(
                    width: 48,
                    alignment: Alignment.center,
                    margin: const EdgeInsets.only(left: 48),
                    child: IconButton(
                      icon: Icon(Icons.insert_emoticon),
                      onPressed: () {},
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(left: 96, right: 20, top: 10),
                    alignment: Alignment.center,
                    child: TextField(
                      maxLines: 2,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w300),
                      cursorColor: StegosColors.accentColor,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Message',
                        hintStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w300),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
