import 'package:flutter/material.dart';
import 'package:stegos_wallet/ui/themes.dart';

class User {
  User(this.name, this.selected);

  final String name;
  bool selected;
}

class SelectUsers extends StatefulWidget {
  const SelectUsers({Key key, this.onUsersSelect}) : super(key: key);

  final void Function(List<User>) onUsersSelect;

  @override
  _SelectUsersState createState() => _SelectUsersState();
}

class _SelectUsersState extends State<SelectUsers> {
  final List<User> users = [
    User('Anna Kristova', false),
    User('Alina Grey', false),
    User('Bill Poll', false),
    User('Bill Gonzales', false),
    User('Konstantin Bedov', false),
    User('Mattue', false),
  ];

  List<User> get selectedUsers => users.where((user) => user.selected).toList();

  String getShortName(String name) {
    return name
        .split(' ')
        .map((String part) => part[0])
        .reduce((prev, current) => prev + current)
        .toUpperCase();
  }

  Widget buildSelectedUsersChips() {
    final List<User> users = selectedUsers;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
          children: users
              .map(
                (User user) => FlatButton.icon(
                  onPressed: () => setState(() {
                    user.selected = !user.selected;
                    if (widget.onUsersSelect != null) {
                      widget.onUsersSelect(selectedUsers);
                    }
                  }),
                  icon: Icon(
                    Icons.close,
                    color: StegosColors.primaryColorDark,
                  ),
                  label: Text(
                    '${user.name}${user == users.last ? '' : ','}',
                    style: TextStyle(
                        color: StegosColors.primaryColorDark, fontWeight: FontWeight.w300),
                  ),
                ),
              )
              .toList()),
    );
  }

  Widget userBuilder(BuildContext context, int index) {
    if (users.length <= index) {
      return null;
    }
    final User user = users[index];
    return ListTile(
      selected: true,
      onTap: () => setState(() {
        user.selected = !user.selected;
        if (widget.onUsersSelect != null) {
          widget.onUsersSelect(selectedUsers);
        }
      }),
      contentPadding: const EdgeInsets.symmetric(horizontal: 33, vertical: 10),
      leading: Container(
        width: 103,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              width: 17,
              height: 17,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.5),
                border: !user.selected ? Border.all(color: StegosColors.white) : null,
                color: user.selected ? StegosColors.accentColor : Colors.transparent,
              ),
            ),
            CircleAvatar(
              radius: 35,
              child: Text(
                getShortName(user.name),
                style: const TextStyle(fontSize: 26),
              ),
            ),
          ],
        ),
      ),
      title: Text(user.name, style: const TextStyle(fontSize: 18, color: StegosColors.white)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
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
                hintText: 'Search for users',
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 75),
          child: buildSelectedUsersChips(),
        ),
        Padding(
          padding: EdgeInsets.only(top: selectedUsers.isNotEmpty ? 128 : 90),
          child: ListView.builder(itemBuilder: userBuilder),
        )
      ],
    );
  }
}
