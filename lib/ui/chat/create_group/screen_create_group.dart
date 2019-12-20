import 'package:flutter/material.dart';
import 'package:stegos_wallet/services/service_node.dart';
import 'package:stegos_wallet/ui/chat/create_group/name_group.dart';
import 'package:stegos_wallet/ui/chat/create_group/select_account.dart';
import 'package:stegos_wallet/ui/chat/create_group/select_users.dart';
import 'package:stegos_wallet/ui/themes.dart';
import 'package:stegos_wallet/widgets/widget_app_bar.dart';
import 'package:stegos_wallet/widgets/widget_scaffold_body_wrapper.dart';

class Group {
  String name = '';
  String description = '';
  List<User> members = [];
  AccountStore account;
}

class CreateGroupScreen extends StatefulWidget {
  @override
  _CreateGroupScreenState createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  int step = 0;
  Group group = Group();

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
            onPressed: () {
              if (step > 0) {
                setState(() {
                  step--;
                });
              } else {
                Navigator.of(context).pop();
              }
            },
          ),
          title: const Text('Create new group'),
        ),
        body: ScaffoldBodyWrapperWidget(
          builder: (context) => Stack(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: 50),
                child: [
                  SelectUsers(
                    onUsersSelect: (List<User> users) {
                      setState(() {
                        group.members = users;
                      });
                    },
                  ),
                  NameGroup(
                    onDescriptionChanged: (String description) => setState(() {
                      group.description = description;
                    }),
                    onNameChanged: (String name) => setState(() {
                      group.name = name;
                    }),
                    groupMembers: group.members,
                  ),
                  SelectAccount(
                    onAccountSelected: (AccountStore account) => setState(() {
                      group.account = account;
                    }),
                  )
                ][step],
              ),
              Container(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(width: double.infinity, height: 50, child: _buildRecoverButton()))
            ],
          ),
        ),
      ),
    );
  }

  Function() onNextPressed() {
    switch (step) {
      case 0:
        if (group.members.isNotEmpty) {
          return () => setState(() {
                step++;
              });
        }
        break;
      case 1:
        if (group.name.isNotEmpty) {
          return () => setState(() {
                step++;
              });
        }
        break;
      case 2:
        if (group.account != null) {
          return () => setState(() {
//            create group
              });
        }
        break;
    }
    return null;
  }

  Widget _buildRecoverButton() => RaisedButton(
        elevation: 8,
        disabledElevation: 8,
        onPressed: onNextPressed(),
        child: const Text('NEXT'),
      );
}
