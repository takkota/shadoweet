import 'dart:collection';

import 'package:shadoweet/enum/item.dart';


class ChatTimeLine {
  // ここでチャット履歴を保持、管理する。
  // Repositoryクラス的なもの
  List<Message> _messageList = <Message>[];

  ChatTimeLine();

  UnmodifiableListView<Message> get items => UnmodifiableListView(_messageList);

  void add(Message message) async {
    _messageList.insert(0, message);
  }

  void clearAll() async {
    _messageList.clear();
  }
}

class Message {
  Message id;
  final String text;
  final int side;

  Message({this.id, this.text, this.side});
}
