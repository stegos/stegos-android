import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:stegos_wallet/services/service_node.dart';

Future<Document> generateDocument(TxStore transaction, TxValidationInfo txvInfo) async {
  final Document pdf = Document(title: 'Stegos Certificate', author: 'stegos');

  pdf.addPage(Page(
    build: (Context context) => Column(
      children: <Widget>[
        Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Container(
              child: Container(
                  padding: const EdgeInsets.only(top: 15),
//                  color: StegosColors.splashBackground,
                  child: Column(
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.only(
                            left: 15, right: 15),
                        child:
                        Row(mainAxisAlignment: MainAxisAlignment
                            .spaceBetween, children: [
                          Text(transaction.humanCreationTime,
                              style: const TextStyle(fontSize: 14)),
                          Text(transaction.humanStatus,
                              style: const TextStyle(fontSize: 14))
                        ]),
                      ),
                      Text('${transaction.humanAmount} STG',
                          style: const TextStyle(fontSize: 32)),
                    ],
                  ))),
        ]),
        Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  alignment: Alignment.center,
                  child: Text(
                    'Transaction data',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                _buildTxValue(
                    'Sender', '${transaction.account.pkey}'),
                _buildTxValue('Recepient',
                    '${transaction.certOutput['recipient']}'),
                _buildTxValue('R-value',
                    '${transaction.certOutput['rvalue']}'),
                _buildTxValue('UTXO ID',
                    '${transaction.certOutput['output_hash']}'),
                if (txvInfo != null) ...[
                  Text(
                    'Transaction verification',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  Row(
                    children: [
                      Text('Sender: Valid'),
                      Text('UTXO ID: Valid'),
                    ],
                  ),
                  Row(
                    children: [
                      Text('Recipient: Valid'),
                      Text('UTXO Block: #${txvInfo.epoch}'),
                    ],
                  ),
                ]
              ],
            ),
      ],
    ),
  ));
  return pdf;
}

Widget _buildTxValue(String label, String value) {
  return Container(
    margin: const EdgeInsets.only(bottom: 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          label,
          style: TextStyle(
              fontSize: 12),
        ),
        Text(
          value,
          style: TextStyle(
              fontSize: 12),
        ),
      ],
    ),
  );
}