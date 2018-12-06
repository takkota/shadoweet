import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:shadoweet/model/ChatTimeLine.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shadoweet/model/Message.dart';
import 'package:shadoweet/urility/SharedPreferencesHelper.dart';
import 'package:uuid/uuid.dart';
import 'package:tuple/tuple.dart';

class ChatMessageBloc {
  ChatTimeLine _chatTimeLine = ChatTimeLine();

  String sessionId = Uuid().toString();

  bool _showTextMessage = false;
  bool get showTextMessage => _showTextMessage;
  bool _new = true;

  final StreamController<Message> _chatStreamController = StreamController();
  // input entry point
  Sink<Message> get chatSink => _chatStreamController.sink;

  final BehaviorSubject<List<Message>> _messages = BehaviorSubject<List<Message>>();
  // output entry point
  Stream<List<Message>> get chatStream => _messages.stream;

  ChatMessageBloc() {
    _chatStreamController.stream.listen((message) {
      // 過去のmessageを保持しておく
      _chatTimeLine.add(message);
      _messages.add(_chatTimeLine.items);
    });
  }

  void clear() async {
    _showTextMessage = false;
    _chatTimeLine.clearAll();
    _new = true;
    sessionId = Uuid().toString();
  }

  void startConversation() async {
    if (!_new) return;
    _new = false;
    var response = Tuple2(List<String>(), false);

    Future<Tuple2<List<String>, bool>> _randomChat() async {
      return await _queryDialogFlow(eventName: "quiz" + (Random().nextInt(10) + 1).toString());
    }

    if (await SharedPreferencesHelper.isFirstConversation()) {
      response = await _queryDialogFlow(eventName: "initial_conversation");
    } else {
      if (await SharedPreferencesHelper.getDogName() == "") {
        if (Random().nextBool()) {
          response = await _queryDialogFlow(eventName: "give_name");
        } else {
          response = await _randomChat();
        }
      } else {
        response = await _randomChat();
      }
    }

    // もっと綺麗に書きたい...
    final messageSize = response.item1.length;
    int loopCnt = 0;
    await Future.forEach(response.item1, (String text) async {
      if (loopCnt + 1 == messageSize) {
        _showTextMessage = response.item2;
      }
      chatSink.add(Message(text: text, side: 0));
      await new Future.delayed(new Duration(milliseconds: 2500));
      loopCnt++;
    });
  }

  Future sendMessage(String text) async {
    if (text == "") return;
    _showTextMessage = false;
    chatSink.add(Message(text: text, side: 1));
    final response = await _queryDialogFlow(query: text);
    response.item1.forEach((String text) {
      chatSink.add(Message(text: text, side: 0));
    });
    _showTextMessage = response.item2;
  }

  Future<Tuple2<List<String>, bool>> _queryDialogFlow({String query, String eventName}) async {
    final uri = Uri.http("peaceful-plateau-25751.herokuapp.com", "/chat", {"query": query, "session_id": sessionId, "event_name": eventName});
    final response = await http.get(uri.toString());
    final json = jsonDecode(response.body);
    final payload = DialogFlowResponse.fromJson(json);

    List<String> responseTextList = List();
    // text
    if (payload.consecutive != null && payload.consecutive) {
      responseTextList = payload.responseText.split(",");
    } else {
      responseTextList.add(payload.responseText);
    }

    // 返答を入力
    final expectResponse = payload.expectResponse!= null && payload.expectResponse;

    // affection up
    SharedPreferencesHelper.countUpAffection(1);
    // save data
    if (payload.saveDataKey != null) {
      switch (payload.saveDataKey) {
        case "name":
          SharedPreferencesHelper.setDogName(payload.saveDataValue);
      }
    }
    // set initial conversation done
    SharedPreferencesHelper.setFirstConversation(false);

    return Tuple2(responseTextList, expectResponse);
  }
}