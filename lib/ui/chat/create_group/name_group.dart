import 'package:flutter/material.dart';
import 'package:stegos_wallet/ui/chat/create_group/select_users.dart';
import 'package:stegos_wallet/ui/themes.dart';

class NameGroup extends StatefulWidget {
  const NameGroup({Key key, this.onNameChanged, this.onDescriptionChanged, this.groupMembers})
      : super(key: key);

  final void Function(String) onNameChanged;
  final void Function(String) onDescriptionChanged;
  final List<User> groupMembers;

  @override
  _NameGroupState createState() => _NameGroupState();
}

class _NameGroupState extends State<NameGroup> {
  final TextEditingController groupNameController = TextEditingController();
  final TextEditingController groupDescriptionController = TextEditingController();
  List<User> _groupMembers = [];

  @override
  void initState() {
    if (widget.onNameChanged is void Function(String)) {
      groupNameController.addListener(() => widget.onNameChanged(groupNameController.text));
    }
    if (widget.onDescriptionChanged is void Function(String)) {
      groupDescriptionController
          .addListener(() => widget.onNameChanged(groupDescriptionController.text));
    }
    setState(() {
      _groupMembers = widget.groupMembers;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          buildGroupName(),
          buildGroupDescription(),
          buildGroupMembers(),
        ],
      ),
    );
  }

  Widget buildGroupName() {
    return Container(
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
                controller: groupNameController,
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

  Widget buildGroupMembers() {
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 41, bottom: 26),
      child: Container(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Group members',
            style: TextStyle(color: StegosColors.primaryColorDark),
          ),
          const SizedBox(height: 6),
          Text(
            _groupMembers.map((User user) => user.name).join(', '),
            style: TextStyle(color: StegosColors.primaryColorDark, fontWeight: FontWeight.w300),
          )
        ],
      )),
    );
  }

  @override
  void dispose() {
    groupNameController.dispose();
    groupDescriptionController.dispose();
    super.dispose();
  }
}
