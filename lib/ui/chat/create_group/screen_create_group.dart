import 'package:flutter/material.dart';
import 'package:stegos_wallet/ui/chat/create_group/name_group.dart';
import 'package:stegos_wallet/ui/chat/create_group/select_users.dart';
import 'package:stegos_wallet/ui/themes.dart';
import 'package:stegos_wallet/widgets/widget_app_bar.dart';
import 'package:stegos_wallet/widgets/widget_scaffold_body_wrapper.dart';

class CreateGroupScreen extends StatefulWidget {
  @override
  _CreateGroupScreenState createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  int step = 0;
  List<User> members = [];
  List<Widget> steps = [];

  @override
  void initState() {
    steps.add(SelectUsers(
      onUsersSelect: (List<User> users) => setState(() {
        members = users;
      }),
    ));
    steps.add(NameGroup());
    super.initState();
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
          title: const Text('Create new group'),
        ),
        body: ScaffoldBodyWrapperWidget(
          builder: (context) => Stack(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: 50),
                child: steps[step],
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

  Widget _buildRecoverButton() => RaisedButton(
        elevation: 8,
        disabledElevation: 8,
        onPressed: () => setState(() {
          step = step + 1;
        }),
        child: const Text('NEXT'),
      );
}
