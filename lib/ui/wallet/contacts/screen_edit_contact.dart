import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import 'package:provider/provider.dart';
import 'package:stegos_wallet/stores/store_stegos.dart';
import 'package:stegos_wallet/ui/app.dart';
import 'package:stegos_wallet/ui/qr_generator/qr_generator.dart';
import 'package:stegos_wallet/ui/themes.dart';
import 'package:stegos_wallet/ui/wallet/contacts/store_screen_edit_contact.dart';
import 'package:stegos_wallet/ui/wallet/qr_reader/screen_qr_reader.dart';
import 'package:stegos_wallet/utils/dialogs.dart';
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
  static final _store = EditContactScreenStore();

  final TextEditingController _contactAddressController = TextEditingController();

  @override
  void initState() {
    _store.reset();
    if (widget.contact != null) {
      _contactAddressController.text = widget.contact.pkey;
      _store.address = widget.contact.pkey;
      _store.name = widget.contact.name;
    } else if (widget.address != null) {
      _contactAddressController.text = widget.address;
      _store.address = widget.address;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
        data: StegosThemes.contactsTheme,
        child: Scaffold(
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
                SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: buildSendButton())
              ],
            ),
          ),
        ));
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
                onChanged: (String value) {
                  runInAction(() {
                    _store.name = value;
                  });
                },
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
                controller: _contactAddressController,
                onChanged: (String value) {
                  runInAction(() {
                    _store.address = value;
                  });
                },
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
    runInAction(() {
      _store.address = address;
      setState(() {
        _contactAddressController.text = address;
      });
    });
  }

  Future<String> showQRCode() {
    return StegosApp.navigatorState.push(MaterialPageRoute(
      builder: (BuildContext context) => QrGenerator(
        title: 'QR code for ${widget.contact.name}',
        qrData: widget.contact.pkey,
      ),
      fullscreenDialog: true,
    ));
  }

  Widget buildSendButton() => widget.readOnly
      ? Container()
      : Observer(builder: (context) {
          return RaisedButton(
            elevation: 8,
            disabledElevation: 8,
            onPressed: _store.isValidForm
                ? (widget.contact != null ? _editContact : _addContact)
                : null,
            child: Text(widget.contact != null ? 'SAVE' : 'CREATE'),
          );
        });

  void _addContact() {
    final store = Provider.of<StegosStore>(context);
    store.addContact(_store.name, _store.address).then((_) {
      StegosApp.navigatorState
          .pushReplacementNamed(Routes.wallet, arguments: 3);
    });
  }

  void _editContact() {
    if (widget.contact == null) {
      return;
    }
    final store = Provider.of<StegosStore>(context);
    store.editContact(widget.contact.id, _store.name, _store.address).then((_) {
      StegosApp.navigatorState.pop();
    });
  }

  @override
  void dispose() {
    _contactAddressController.dispose();
    super.dispose();
  }
}
