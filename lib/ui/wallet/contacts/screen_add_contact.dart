import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stegos_wallet/stores/store_stegos.dart';
import 'package:stegos_wallet/ui/app.dart';
import 'package:stegos_wallet/ui/themes.dart';
import 'package:stegos_wallet/ui/wallet/qr_reader/screen_qr_reader.dart';
import 'package:stegos_wallet/utils/dialogs.dart';
import 'package:stegos_wallet/widgets/widget_app_bar.dart';
import 'package:stegos_wallet/widgets/widget_scaffold_body_wrapper.dart';

import 'contacts.dart';

class AddContactScreen extends StatefulWidget {
  const AddContactScreen({Key key, this.onNameChanged, this.onDescriptionChanged, this.address})
      : super(key: key);

  final void Function(String) onNameChanged;
  final void Function(String) onDescriptionChanged;
  final String address;

  @override
  _AddContactScreenState createState() => _AddContactScreenState();
}

class _AddContactScreenState extends State<AddContactScreen> {
  final TextEditingController contactNameController = TextEditingController();
  final TextEditingController contactAddressController = TextEditingController();
  Contact contact = Contact();

  static final RegExp _stegosAddressRegExp = RegExp(
    r'^st[rgt]1[ac-hj-np-z02-9]{8,87}$',
    caseSensitive: false,
    multiLine: false,
  );

  bool isValidAddress(String address) {
    if (address == null) {
      return false;
    } else {
      return _stegosAddressRegExp.hasMatch(address);
    }
  }

  @override
  void initState() {
    contactAddressController.text = widget.address;
    contact.address = widget.address;
    if (widget.onNameChanged is void Function(String)) {
      contactNameController.addListener(() => widget.onNameChanged(contactNameController.text));
    }
    if (widget.onDescriptionChanged is void Function(String)) {
      contactAddressController
          .addListener(() => widget.onNameChanged(contactAddressController.text));
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        backgroundColor: Colors.transparent,
        centerTitle: false,
        leading: IconButton(
          icon: const SizedBox(
            width: 24,
            height: 24,
            child: Image(image: AssetImage('assets/images/arrow_back.png')),
          ),
          onPressed: () => StegosApp.navigatorState.pop(null),
        ),
        title: const Text('Add contact'),
      ),
      body: ScaffoldBodyWrapperWidget(
        builder: (context) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    buildContactName(),
                    buildContactAddress(),
                  ],
                ),
              ),
            ),
            SizedBox(width: double.infinity, height: 50, child: buildSendButton())
          ],
        ),
      ),
    );
  }

  Widget buildContactName() {
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 41, bottom: 10),
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
                onChanged: (String name) => setState(() {
                  contact.name = name;
                }),
                controller: contactNameController,
                style: const TextStyle(fontSize: 18),
                decoration: const InputDecoration(
                    hintText: 'Name',
                    hintStyle: TextStyle(color: StegosColors.primaryColorDark),
                    border: UnderlineInputBorder(
                        borderSide: BorderSide(width: 2, color: StegosColors.primaryColorDark))),
              )),
        ],
      ),
    );
  }

  Widget buildContactAddress() {
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 26),
      child: Column(
        children: <Widget>[
          Stack(
            children: <Widget>[
              TextField(
                controller: contactAddressController,
                onChanged: (String address) => setState(() {
                  contact.address = address;
                }),
                decoration: const InputDecoration(
                  hintText: 'Address',
                  hintStyle: TextStyle(color: StegosColors.primaryColorDark),
                  contentPadding: EdgeInsets.only(
                    right: 25,
                  ),
                ),
              ),
              Container(
                height: 34,
                alignment: Alignment.bottomRight,
                child: GestureDetector(
                  onTap: scanQr,
                  child: Image.asset(
                    'assets/images/qr.png',
                    height: 20,
                    width: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void scanQr() async {
    final address = await appShowDialog<String>(builder: (context) => QrReaderScreen());
    if (address == null) {
      return;
    }
    setState(() {
      contactAddressController.text = address;
      contact.address = address;
    });
  }

  bool get isValid {
    //todo true validation
    return isValidAddress(contact.address) && contact.name.isNotEmpty;
  }

  Widget buildSendButton() => RaisedButton(
        elevation: 8,
        disabledElevation: 8,
        onPressed: _addContact,
        child: const Text('CREATE'),
      );

  void _addContact(){
    final store = Provider.of<StegosStore>(context);
    if(isValid){
      store.addContact(contactNameController.text, contactAddressController.text)
          .then((_) {
        StegosApp.navigatorState.pop();
      });
    }
  }

  @override
  void dispose() {
    contactNameController.dispose();
    contactAddressController.dispose();
    super.dispose();
  }
}
