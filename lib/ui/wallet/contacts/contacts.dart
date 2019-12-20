import 'package:flutter/material.dart';
import 'package:stegos_wallet/env_stegos.dart';
import 'package:stegos_wallet/ui/app.dart';
import 'package:stegos_wallet/ui/themes.dart';
import 'package:stegos_wallet/utils/dialogs.dart';
import 'package:stegos_wallet/widgets/widget_scaffold_body_wrapper.dart';

class Contact {
  Contact({this.name, this.address});

  final String name;
  final String address;
}

class Contacts extends StatefulWidget {
  @override
  _ContactsState createState() => _ContactsState();
}

class _ContactsState extends State<Contacts> {
  final List<Contact> contacts = [
    Contact(name: 'Anna Kristova', address: ''),
    Contact(name: 'Alina Grey', address: ''),
    Contact(name: 'Bill Poll', address: ''),
    Contact(name: 'Bill Gonzales', address: ''),
    Contact(name: 'Bill Gonzales', address: ''),
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
    return Scaffold(
      body: ScaffoldBodyWrapperWidget(
        builder: (context) => SingleChildScrollView(
          child: Column(
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
                        hintText: 'Search for contacts',
                        border: InputBorder.none),
                  ),
                ),
              ),
              Column(
                children: contacts.map((Contact contact) {
                  final ValueKey<Contact> key = ValueKey(contact);
                  return Dismissible(
                    key: key,
                    direction: DismissDirection.endToStart,
                    confirmDismiss: (DismissDirection direction) => _confirmDeleting(contact),
                    child: ListTile(
                      selected: true,
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
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _confirmDeleting(Contact contact) => appShowDialog<bool>(
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
}
