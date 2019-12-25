import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stegos_wallet/ui/app.dart';
import 'package:stegos_wallet/ui/routes.dart';
import 'package:stegos_wallet/ui/themes.dart';
import 'package:stegos_wallet/utils/dialogs.dart';
import 'package:stegos_wallet/widgets/widget_scaffold_body_wrapper.dart';

class Contact {
  Contact({this.name = '', this.address = ''});

  String name;
  String address;

  String get shortAddress {
    return address.length > 10
        ? '${address.substring(0, 8)}...${address.substring(address.length - 10)}'
        : address;
  }
}

class Contacts extends StatefulWidget {
  @override
  _ContactsState createState() => _ContactsState();
}

class _ContactsState extends State<Contacts> {
  final List<Contact> contacts = [
    Contact(
        name: 'Anna Kristova',
        address: 'stt1rqtmwyy5rp5xzk3k84spahdphccxa6w848phuxs5cs82h5mg2yqsxuhxkr'),
    Contact(
        name: 'Alina Grey',
        address: 'stt1rqtmwyy5rp5xzk3k84spahdphccxa6w848phuxs5cs82h5mg2yqsxuhxkr'),
    Contact(
        name: 'Bill Poll',
        address: 'stt1rqtmwyy5rp5xzk3k84spahdphccxa6w848phuxs5cs82h5mg2yqsxuhxkr'),
    Contact(
        name: 'Bill Gonzales',
        address: 'stt1rqtmwyy5rp5xzk3k84spahdphccxa6w848phuxs5cs82h5mg2yqsxuhxkr'),
    Contact(
        name: 'Bill Gonzales',
        address: 'stt1rqtmwyy5rp5xzk3k84spahdphccxa6w848phuxs5cs82h5mg2yqsxuhxkr'),
  ];

  String getShortName(String name) {
    return name
        .split(' ')
        .map((String part) => part[0])
        .reduce((prev, current) => prev + current)
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: StegosThemes.contactsTheme,
      child: Scaffold(
        body: ScaffoldBodyWrapperWidget(
          builder: (context) => Stack(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(top: 17, bottom: 28),
                height: 90,
                child: Container(
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
                        hintText: 'Search for contacts',
                        border: InputBorder.none),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.only(top: 90),
                child: SingleChildScrollView(
                  child: Column(
                    children: contacts.map((Contact contact) {
                      final ValueKey<Contact> key = ValueKey(contact);
                      return Dismissible(
                        secondaryBackground: Container(
                          padding: const EdgeInsets.all(10),
                          color: StegosColors.errorColor.withOpacity(0.9),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              const Text('Delete'),
                              const SizedBox(width: 5),
                              Icon(Icons.delete_forever),
                            ],
                          ),
                        ),
                        key: key,
                        direction: DismissDirection.horizontal,
                        background: Container(
                            padding: const EdgeInsets.all(10),
                            color: StegosColors.primaryColorDark,
                            child: Row(
                              children: <Widget>[
                                Icon(Icons.edit),
                                const SizedBox(width: 5),
                                const Text('Edit'),
                              ],
                            )),
                        confirmDismiss: (DismissDirection direction) {
                          if (direction == DismissDirection.startToEnd) {
                            return editContact(contact);
                          } else {
                            return confirmDeleting(contact);
                          }
                        },
                        child: ListTile(
                          subtitle: Text(contact.shortAddress),
                          onTap: () {
                            StegosApp.navigatorState
                                .pushNamed(Routes.viewContact, arguments: contact);
                          },
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          leading: Container(
                            child: CircleAvatar(
                              radius: 35,
                              child: Text(
                                getShortName(contact.name),
                                style: const TextStyle(fontSize: 26),
                              ),
                            ),
                          ),
                          title: Text(contact.name,
                              style: const TextStyle(fontSize: 18, color: StegosColors.white)),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: buildFloatingActionButton(context),
      ),
    );
  }

  Widget buildFloatingActionButton(BuildContext context) => FloatingActionButton(
        onPressed: () => StegosApp.navigatorState.pushNamed(Routes.editContact),
        child: Icon(Icons.add),
      );

  Future<bool> confirmDeleting(Contact contact) => appShowDialog<bool>(
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Delete contact ${contact.name}?'),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  StegosApp.navigatorState.pop(false);
                },
                child: const Text('CANCEL'),
              ),
              FlatButton(
                onPressed: () {
                  StegosApp.navigatorState.pop(true);
                  contacts.remove(contact);
                },
                child: const Text('DELETE'),
              )
            ],
          );
        },
      );

  Future<bool> editContact(Contact contact) {
    StegosApp.navigatorState.pushNamed(Routes.editContact, arguments: contact);
    return Future.value(false);
  }
}
