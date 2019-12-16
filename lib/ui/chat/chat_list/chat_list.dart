import 'package:flutter/material.dart';
import 'package:stegos_wallet/ui/routes.dart';
import 'package:stegos_wallet/ui/themes.dart';

class ChatList extends StatefulWidget {
  @override
  _ChatListState createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  Widget _chatItemBuilder(BuildContext context, int index) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      leading: const CircleAvatar(
        radius: 35,
        child: Text(
          'AB',
          style: TextStyle(fontSize: 26),
        ),
      ),
      title: const Text('Anton Bucharin', style: TextStyle(fontSize: 18)),
      subtitle: Text('i am still waiting for your message...',
          style: TextStyle(color: StegosColors.primaryColorDark, fontWeight: FontWeight.w300)),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text('17:52', style: TextStyle(color: StegosColors.primaryColorDark)),
          Container(
            width: 22,
            height: 22,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(11), color: StegosColors.accentColor),
            child: Text(3.toString(), style: TextStyle(color: StegosColors.white, fontSize: 14)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: StegosThemes.ChatTheme,
      child: Scaffold(
        body: Stack(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(top: 17, bottom: 25),
              height: 90,
              child: Container(
                height: 47,
                padding: const EdgeInsets.only(right: 15),
                decoration: BoxDecoration(
                    color: const Color(0x807D8B97), borderRadius: BorderRadius.circular(12)),
                child: const TextField(
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.search,
                      color: Color(0xff2B2E3B),
                      size: 29,
                    ),
                    hintText: 'Search  for messages or users',
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 90),
              child: ListView.builder(itemBuilder: _chatItemBuilder),
            )
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => Navigator.of(context).pushNamed(Routes.createChat),
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}
