import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shadoweet/bloc/ChatMessageBloc.dart';
import 'package:shadoweet/provider/ChatMessageProvider.dart';
import 'package:shadoweet/model/ChatTimeLine.dart';
import 'package:shadoweet/urility/SharedPreferencesHelper.dart';
import 'package:tuple/tuple.dart';

class ChatScreen extends StatefulWidget {
  @override
  ChatScreenState createState() => new ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  ChatMessageBloc chatMessageBloc;
  TextEditingController _textController;
  AnimationController animationController;

  @override
  void initState() {
    super.initState();
    animationController =  new AnimationController(
        vsync: this,
        duration: new Duration(milliseconds: 700)
    );
    _textController = new TextEditingController();
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
                            decoration: new InputDecoration.collapsed(hintText: "返答を入力する")
                        ),
                      ],
                    ),
                  ),
                  new Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: new IconButton(
                        icon: new Icon(Icons.send),
                        onPressed: () {
                          chatMessageBloc.sendMessage(_textController.text);
                          setState(() {});
                        }
                    ),
                  ),
                ]
            )
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    chatMessageBloc = ChatMessageBlocProvider.of(context);
    chatMessageBloc.startConversation();

    return new Scaffold(
      appBar: new AppBar(title: new Text("会話")),
      body: new StreamBuilder<List<Message>>(
        stream: chatMessageBloc.chatStream,
        builder: (context, snapshot) {
          animationController.forward();
          if (snapshot.data == null || snapshot.data.isEmpty) {
            return Container(
            );
          }
          final list = snapshot.data.map((item) {
            return MessageRow(
                side: item.side,
                text: item.text,
                animationController: animationController
            );
          }).toList();
          return Column(
              children: <Widget>[
                Expanded(
                  child: ListView.builder(
                    padding: new EdgeInsets.all(8.0),
                    reverse: true,
                    itemBuilder: (_, int index) => list[index],
                    itemCount: list.length,
                  ),
                ),
                showTextInputIfNeed()
              ],
          );
        },
      ),
    );
  }

  Widget showTextInputIfNeed() {
    // showTextInputはBlocに持って行く
    if (chatMessageBloc.showTextMessage) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Divider(height: 1.0),
          new Container(
              decoration: new BoxDecoration(
                  color: Theme.of(context).cardColor
              ),
              child: _buildTextIntput()
          )
        ],
      );
    } else {
      return Divider(height: 1.0);
    }
  }

  @override
  void dispose() {
    super.dispose();
    chatMessageBloc.clear();
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
            child: _constructRow(context)
        )
    );
  }

  Widget constructRow(BuildContext context) {
    return Expanded(
      child: _constructRow(context),
    );
  }

  Widget _constructRow(BuildContext context) {
    return FutureBuilder<String>(
      future: SharedPreferencesHelper.getDogName(),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.data != null) {
          if (side == 0) {
            return new Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  new Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: new CircleAvatar(backgroundImage: AssetImage('assets/dog_face.png'))
                  ),
                  new Expanded(
                    child: new Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        new Text(snapshot.data, style: Theme.of(context).textTheme.subhead),
                        new Container(
                            margin: const EdgeInsets.only(top: 5.0),
                            child: Text(text)
                        ),
                      ],
                    ),
                  )

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
                      new Text("あなた", style: Theme.of(context).textTheme.subhead),
                      new Container(
                        margin: const EdgeInsets.only(top: 5.0),
                        child: new Text(text),
                      )
                    ],
                  ),
                  new Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: new CircleAvatar(child: FittedBox(child: Text("あなた"), fit: BoxFit.scaleDown)),
                  ),
                ]
            );
          }
        } else {
          return Container();
        }
      }
    );
  }
}
