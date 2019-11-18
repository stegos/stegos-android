import 'dart:async';

class WebsocketService extends Stream<dynamic> {
  WebsocketService(this.url);
  final String url;

  @override
  @override
  StreamSubscription<dynamic> listen(void Function(dynamic) onData,
      {Function onError, void Function() onDone, bool cancelOnError}) {
    //
  }
}
