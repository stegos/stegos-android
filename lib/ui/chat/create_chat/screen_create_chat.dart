import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:stegos_wallet/ui/themes.dart';
import 'package:stegos_wallet/widgets/widget_app_bar.dart';

class CreateChatScreen extends StatefulWidget {
  @override
  _CreateChatScreenState createState() => _CreateChatScreenState();
}

class _CreateChatScreenState extends State<CreateChatScreen> {
  Widget _chatItemBuilder(BuildContext context, int index) {
    return const ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      leading: CircleAvatar(
        radius: 35,
        child: Text(
          'AB',
          style: TextStyle(fontSize: 26),
        ),
      ),
      title: Text('Anton Bucharin', style: TextStyle(fontSize: 18)),
    );
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
          title: const Text('Create new chat'),
          actions: <Widget>[
            FlatButton.icon(onPressed: () {}, icon: const Icon(Icons.search), label: Container())
          ],
        ),
        body: Stack(
          children: <Widget>[
            _buildButtons(),
            Padding(
              padding: const EdgeInsets.only(top: 100),
              child: ListView.builder(itemBuilder: _chatItemBuilder),
            )
          ],
        ),
      ),
    );
  }

  Container _buildButtons() => Container(
    color: StegosColors.backgroundColor,
    child: Container(
      height: 100,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 65,
                child: RaisedButton(
                  padding: const EdgeInsets.all(10),
                  onPressed: () {
                  },
                  color: StegosColors.splashBackground,
                  child: Row(
                    children: <Widget>[
                      SvgPicture.asset('assets/images/new_group.svg'),
                      const Text(
                        'New\ngroup',
                        style: TextStyle(fontSize: 18),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 65,
                child: RaisedButton(
                  padding: const EdgeInsets.all(10),
                  onPressed: () {},
                  color: StegosColors.splashBackground,
                  child: Row(
                    children: <Widget>[
                      SvgPicture.asset('assets/images/new_channel.svg'),
                      Container(
                        child: const Text(
                          'New\nchannel',
                          style: TextStyle(fontSize: 18),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
