import 'dart:async';

import 'package:shadoweet/model/ChatTimeLine.dart';
import 'package:rxdart/rxdart.dart';

class ChatMessageBloc {
  ChatTimeLine _chatTimeLine = ChatTimeLine();

  final StreamController<Message> _chatStreamController = StreamController();
  // input entry point
  Sink<Message> get chatSink => _chatStreamController.sink;

  final BehaviorSubject<List<Message>> _messages = BehaviorSubject<List<Message>>();
  // output entry point
  Stream<List<Message>> get chatStream => _messages.stream;

  ChatMessageBloc() {
    _chatStreamController.stream.listen((message) {
      print('stream' + message.message);
      _chatTimeLine.add(message);
      _messages.add(_chatTimeLine.items);
    });
  }
}