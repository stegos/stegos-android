import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stegos_wallet/stores/store_stegos.dart';
import 'package:stegos_wallet/ui/app.dart';
import 'package:stegos_wallet/ui/routes.dart';
import 'package:stegos_wallet/ui/themes.dart';
import 'package:stegos_wallet/utils/dialogs.dart';
import 'package:stegos_wallet/widgets/widget_scaffold_body_wrapper.dart';

class Contact {
  Contact({this.name = '', this.address = ''});

  String name;
  String address;
}

class Contacts extends StatefulWidget {
  @override
  _ContactsState createState() => _ContactsState();
}

class _ContactsState extends State<Contacts> {

  String getShortName(String name) {
    return name
        .split(' ')
        .map((String part) => part[0])
        .reduce((prev, current) => prev + current)
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final store = Provider.of<StegosStore>(context);
    final contacts = store.contactsList;
    return Theme(
      data: StegosThemes.contactsTheme,
      child: Scaffold(
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
                  children: contacts.map((ContactStore contact) {
                    final ValueKey<ContactStore> key = ValueKey(contact);
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
        floatingActionButton: _buildFloatingActionButton(context),
      ),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) => FloatingActionButton(
        onPressed: () => StegosApp.navigatorState.pushNamed(Routes.addContact),
        child: Icon(Icons.add),
      );

  Future<bool> _confirmDeleting(ContactStore contact) {
    final store = Provider.of<StegosStore>(context);
    return appShowDialog<bool>(
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
                  store.removeContact(contact.pkey);
                },
                child: const Text('DELETE'),
              )
            ],
          );
        },
      );
  }
}
