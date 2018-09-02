import 'package:flutter/material.dart';
import 'package:flutter_dialogflow/flutter_dialogflow.dart';
import 'package:shadoweet/bloc/ChatMessageBloc.dart';
import 'dart:async';
import 'package:shadoweet/model/ChatTimeLine.dart';

class ChatScreen extends StatefulWidget {
  @override
  ChatScreenState createState() => new ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  ChatMessageBloc chatMessageBloc = new ChatMessageBloc();
  TextEditingController _textController = new TextEditingController();
  String queryMessage = "";
  AnimationController animationController;

  @override
  void initState() {
    super.initState();
    //chatMessageBloc = ChatMessageBloc();
    animationController =  new AnimationController(
        vsync: this,
        duration: new Duration(milliseconds: 700)
    );

  }

  void _handleSubmitted(String text) async {
    _textController.clear();

    chatMessageBloc.chatSink.add(Message(text, 1));
    String response = await queryResponse(text);
    chatMessageBloc.chatSink.add(Message(response, 0));
  }

  Future<String> queryResponse(query) async {
    Dialogflow dialogflow = Dialogflow(token: "6f8235ecfadc493eaf3e85e783321f86");
    AIResponse response = await dialogflow.sendQuery(query);
    return response.getMessageResponse();
  }


  Widget _buildTextIntput() {
    return new IconTheme(
        data: new IconThemeData(color: Theme.of(context).accentColor),
        child: new Container(
            margin: const EdgeInsets.symmetric(horizontal: 8.0),
            child: new Row(
                children: <Widget>[
                  new Flexible(
                    child: new Column(
                      children: <Widget>[
                        new TextField(
                            controller: _textController,
                            onSubmitted: _handleSubmitted,
                            decoration: new InputDecoration.collapsed(hintText: "返答を入力する")
                        ),
                      ],
                    ),
                  ),
                  new Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: new IconButton(
                        icon: new Icon(Icons.send),
                        onPressed: () => _handleSubmitted(_textController.text)
                    ),
                  ),
                ]
            )
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        //appBar: new AppBar(title: new Text("会話")),
        body: new Column(
          children: <Widget>[
            new StreamBuilder<List<Message>>(
              stream: chatMessageBloc.chatStream,
              initialData: [Message("aaa", 0)],
              builder: (context, snapshot) {
                animationController.forward();
                if (snapshot.data == null || snapshot.data.isEmpty) {
                  return Flexible(child: Text("test"));
                };
                final list = snapshot.data.map((item) {
                  return MessageRow(
                      side: item.side,
                      text: item.message,
                      animationController: animationController
                  );
                }).toList();
                return Flexible(
                    child: ListView.builder(
                        padding: new EdgeInsets.all(8.0),
                        reverse: true,
                        itemBuilder: (_, int index) => list[index],
                        itemCount: list.length,
                    )
                );
              },
            ),
            new Divider(height: 1.0),
            new Container(
                decoration: new BoxDecoration(
                    color: Theme.of(context).cardColor
                ),
                child: _buildTextIntput()
            )
          ],
        )
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}


class MessageRow extends StatelessWidget {
  const MessageRow({this.text, this.animationController, this.side = 0});
  final String text;
  final int side;
  final AnimationController animationController;

  @override
  Widget build(BuildContext context) {
    return new SizeTransition(
        sizeFactor: new CurvedAnimation(parent: animationController, curve: Curves.decelerate),
        child: new Container(
            margin: const EdgeInsets.symmetric(vertical: 10.0),
            child: constructRow(context)
        )
    );
  }

  Row constructRow(BuildContext context) {
    if (side == 0) {
      return new Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Container(
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                child: new CircleAvatar(child: new Text("me"))
            ),
            new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new Text("me", style: Theme.of(context).textTheme.subhead),
                new Container(
                  margin: const EdgeInsets.only(top: 5.0),
                  child: new Text(text),
                )
              ],
            ),
          ]
      );
    } else {
      return new Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new Text("me", style: Theme.of(context).textTheme.subhead),
                new Container(
                  margin: const EdgeInsets.only(top: 5.0),
                  child: new Text(text),
                )
              ],
            ),
            new Container(
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                child: new CircleAvatar(child: new Text("me"))
            ),
          ]
      );
    }
  }
}
