import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stegos_wallet/stores/store_stegos.dart';
import 'package:stegos_wallet/ui/app.dart';
import 'package:stegos_wallet/ui/qr_generator/qr_generator.dart';
import 'package:stegos_wallet/ui/themes.dart';
import 'package:stegos_wallet/ui/wallet/qr_reader/screen_qr_reader.dart';
import 'package:stegos_wallet/utils/dialogs.dart';
import 'package:stegos_wallet/utils/stegos_address.dart';
import 'package:stegos_wallet/widgets/widget_app_bar.dart';
import 'package:stegos_wallet/widgets/widget_scaffold_body_wrapper.dart';

import '../../routes.dart';

class EditContactScreenArguments {
  EditContactScreenArguments({this.contact, this.address});

  final ContactStore contact;
  final String address;
}

class EditContactScreen extends StatefulWidget {
  EditContactScreen(
      {Key key, EditContactScreenArguments args, this.readOnly = false})
      : contact = args?.contact,
        address = args?.address,
        super(key: key);

  final ContactStore contact;
  final String address;
  final bool readOnly;

  @override
  _EditContactScreenState createState() => _EditContactScreenState();
}

class _EditContactScreenState extends State<EditContactScreen> {
  final TextEditingController contactNameController = TextEditingController();
  final TextEditingController contactAddressController = TextEditingController();
  ContactStore contact;

  @override
  void initState() {
    if (widget.contact != null) {
      contact = widget.contact;
      contactAddressController.text = contact.pkey;
      contactNameController.text = contact.name;
    } else if (widget.address != null) {
      contactAddressController.text = widget.address;
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
        title: Text(widget.readOnly
            ? 'View contact'
            : widget.contact != null ? 'Edit contact' : 'Create contact'),
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
                readOnly: widget.readOnly,
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
                readOnly: widget.readOnly,
                controller: contactAddressController,
                decoration: const InputDecoration(
                  hintText: 'Address',
                  hintStyle: TextStyle(color: StegosColors.primaryColorDark),
                ),
              ),
              Container(
                height: 34,
                alignment: Alignment.bottomRight,
                child: GestureDetector(
                  onTap: widget.readOnly ? showQRCode : scanQr,
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
    });
  }

  Future<String> showQRCode() {
    return StegosApp.navigatorState.push(MaterialPageRoute(
      builder: (BuildContext context) => QrGenerator(
        title: 'QR code for ${contact.name}',
        qrData: contact.pkey,
      ),
      fullscreenDialog: true,
    ));
  }

  bool get isValid {
    return validateStegosAddress(contactAddressController.text) && contactNameController.text.isNotEmpty;
  }

  Widget buildSendButton() => widget.readOnly
      ? Container()
      : RaisedButton(
          elevation: 8,
          disabledElevation: 8,
          onPressed: widget.contact != null ? _editContact : _addContact,
          child: Text(widget.contact != null ? 'SAVE' : 'CREATE'),
        );

  void _addContact(){
    final store = Provider.of<StegosStore>(context);
    if(isValid){
      store.addContact(contactNameController.text, contactAddressController.text)
          .then((_) {
        StegosApp.navigatorState.pushReplacementNamed(Routes.wallet, arguments: 3);
      });
    }
  }

  void _editContact(){
    if(contact == null) {
      return;
    }
    final store = Provider.of<StegosStore>(context);
    if(isValid){
      store.editContact(contact.id, contactNameController.text, contactAddressController.text)
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
