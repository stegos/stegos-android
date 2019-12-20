import 'package:flutter/material.dart';
import 'package:stegos_wallet/ui/themes.dart';

class NameGroup extends StatefulWidget {
  @override
  _NameGroupState createState() => _NameGroupState();
}

class _NameGroupState extends State<NameGroup> {
  final TextEditingController chatNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        buildGroupName(),
        buildGroupDescription(),
      ],
    );
  }

  Widget buildGroupName() {
    return Container(
      height: 140,
      padding: const EdgeInsets.only(left: 16, right: 16, top: 41, bottom: 26),
      child: Stack(
        alignment: Alignment.centerLeft,
        children: <Widget>[
          Container(
            alignment: Alignment.centerLeft,
            child: CircleAvatar(
              backgroundColor: const Color(0xffff9d4d),
              radius: 32,
              child: Icon(Icons.photo_camera, color: StegosColors.white),
            ),
          ),
          Container(
              padding: const EdgeInsets.only(left: 80),
              child: TextField(
                controller: chatNameController,
                style: const TextStyle(fontSize: 20),
                decoration: InputDecoration(
                    hintText: 'Group name',
                    hintStyle: TextStyle(color: StegosColors.primaryColorDark),
                    border: UnderlineInputBorder(
                        borderSide: BorderSide(width: 2, color: StegosColors.primaryColorDark)),
                    contentPadding: const EdgeInsets.only(top: 0, bottom: 0, left: 13, right: 13)),
              )),
        ],
      ),
    );
  }

  Widget buildGroupDescription() {
    return Container(
      height: 160,
      padding: const EdgeInsets.only(left: 16, right: 16, top: 41, bottom: 26),
      child: Container(
          child: Column(
        children: <Widget>[
          TextField(
            decoration: InputDecoration(
              hintText: 'Group Description',
              hintStyle: TextStyle(color: StegosColors.primaryColorDark),
              border: UnderlineInputBorder(
                  borderSide: BorderSide(width: 1, color: StegosColors.primaryColorDark)),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'You can provide an optional description for your group.',
            style: TextStyle(color: StegosColors.primaryColorDark, fontWeight: FontWeight.w300),
          )
        ],
      )),
    );
  }
}
