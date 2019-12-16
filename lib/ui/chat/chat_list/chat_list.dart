import 'package:flutter/material.dart';
import 'package:stegos_wallet/ui/themes.dart';

class ChatList extends StatefulWidget {
  @override
  _ChatListState createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: StegosThemes.baseTheme,
      child: Scaffold(
        body: Stack(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(top: 17, bottom: 25),
              height: 90,
              child: Container(
                height: 47,
                decoration: BoxDecoration(
                    color: const Color(0x807D8B97), borderRadius: BorderRadius.circular(12)),
                child: const TextField(
                  cursorColor: Color(0xff2B2E3B),
                )
              ),
            )
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}
