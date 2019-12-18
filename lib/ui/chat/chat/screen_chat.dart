import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:stegos_wallet/ui/chat/message_bubble/message_bubble.dart';
import 'package:stegos_wallet/ui/routes.dart';
import 'package:stegos_wallet/ui/themes.dart';
import 'package:stegos_wallet/widgets/widget_app_bar.dart';
import 'package:stegos_wallet/widgets/widget_scaffold_body_wrapper.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  Widget _chatItemBuilder(BuildContext context, int index) {
    return messages.length > index ? messages[index] : null;
  }

  final FocusNode messageInputFocusNode = FocusNode();
  final TextEditingController messageController = TextEditingController();
  final List<MessageBubble> messages = [];
  bool messageInputHasFocus = false;

  @override
  void initState() {
    messageInputFocusNode.addListener(() {
      setState(() {
        messageInputHasFocus = messageInputFocusNode.hasFocus;
      });
    });
    super.initState();
  }

  void onSubminMessage(String value) {
    setState(() {
      messages.insert(
        0,
        MessageBubble(
          messageController.text,
          side: DialogSide.right,
        ),
      );
    });

    messageController.text = '';
    messageInputFocusNode.unfocus();
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
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text('Lucky team'),
              Text('2 members',
                  style: TextStyle(
                    color: StegosColors.primaryColorDark,
                    fontWeight: FontWeight.w300,
                    fontSize: 14,
                  )),
            ],
          ),
          actions: <Widget>[
            IconButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.chatSettings);
                },
                icon: const Icon(Icons.more_vert))
          ],
        ),
        body: ScaffoldBodyWrapperWidget(
          builder: (context) => Stack(
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
                child: Material(
                  color: Colors.transparent,
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
                        padding: const EdgeInsets.only(left: 102, right: 64, top: 10),
                        alignment: Alignment.center,
                        child: TextField(
                          onSubmitted: onSubminMessage,
                          controller: messageController,
                          focusNode: messageInputFocusNode,
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
                      Container(
                        alignment: Alignment.centerRight,
                        child: Container(
                          width: 64,
                          alignment: Alignment.center,
                          margin: const EdgeInsets.only(left: 48),
                          child: messageInputHasFocus
                              ? IconButton(
                                  icon: Container(
                                    width: 32,
                                    height: 32,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      color: StegosColors.accentColor,
                                    ),
                                    child: Icon(
                                      Icons.arrow_upward,
                                      color: const Color(0xff0f0f1a),
                                    ),
                                  ),
                                  onPressed: () => onSubminMessage(''),
                                )
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
