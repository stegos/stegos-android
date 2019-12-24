import 'package:pdf/widgets.dart';
import 'package:stegos_wallet/services/service_node.dart';

Future<Document> generateDocument(
    TxStore transaction, TxValidationInfo txvInfo) async {
  final Document pdf = Document(title: 'Stegos Certificate', author: 'stegos');

  pdf.addPage(Page(
      build: (Context context) => Column(children: <Widget>[
            Container(
                child: Text('Payment Certificate',
                    style: const TextStyle(fontSize: 32))),
            Container(
                margin: const EdgeInsets.only(top: 5),
                child: Text('Generated on ${transaction.humanCreationTime}',
                    style: const TextStyle(fontSize: 12))),
            Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                alignment: Alignment.centerLeft,
                child: Text('Transaction Data',
                    style: const TextStyle(fontSize: 24))),
            _buildTxValue('Sender', '${transaction.account.pkey}'),
            _buildTxValue(
                'Recipient', '${transaction.certOutput['recipient']}'),
            _buildTxValue('R-value', '${transaction.certOutput['rvalue']}'),
            _buildTxValue(
                'UTXO ID', '${transaction.certOutput['output_hash']}'),
            Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                alignment: Alignment.centerLeft,
                child: Text('Transaction verification',
                    style: const TextStyle(fontSize: 24))),
            Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Sender: Valid'),
                      Text('Recipient: Valid'),
                      Text('UTXO ID: Valid'),
                    ])),
            Container(
                alignment: Alignment.centerRight,
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: Text('UTXO Block No: ${txvInfo.epoch}')),
            Container(
                alignment: Alignment.centerLeft,
                child: Text(
                    'Amount: ${(txvInfo.amount / 1e6).toStringAsFixed(4)} STG')),
          ])));
  return pdf;
}

Widget _buildTxValue(String label, String value) {
  return Container(
    margin: const EdgeInsets.only(bottom: 10),
    child: Row(
      children: <Widget>[
        Text(
          '${label}: ',
          style: const TextStyle(fontSize: 12),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    ),
  );
}
