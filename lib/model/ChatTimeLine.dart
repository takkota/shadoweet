import 'dart:collection';

class ChatTimeLine {
  // ここでチャット履歴を保持、管理する。
  // Repositoryクラス的なもの
  List<Message> _messageList = <Message>[];

  ChatTimeLine();

  UnmodifiableListView<Message> get items => UnmodifiableListView(_messageList);

  void add (Message message) {
    _messageList.insert(0, message);
  }
}

class Message {
  final String message;
  final int side;
  const Message(this.message, this.side);
}
