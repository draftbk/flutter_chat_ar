import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ar/hello_world.dart';
import 'package:dio/dio.dart';
import 'dart:developer' as developer;

void main() {
  runApp(new FriendlychatApp());
}

const String _name = "Lifan";

class FriendlychatApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: "Friendlychat",
      home: new ChatScreen(),
    );
  }
}

class ChatMessage extends StatelessWidget {
  ChatMessage({this.text, this.animationController});

  final String text;
  final AnimationController animationController;

  @override
  Widget build(BuildContext context) {
    return new SizeTransition(
        sizeFactor: new CurvedAnimation(
            parent: animationController, curve: Curves.easeOut),
        axisAlignment: 0.0,
        child: new Container(
          margin: const EdgeInsets.symmetric(vertical: 10.0),
          child: new Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new Container(
                margin: const EdgeInsets.only(right: 16.0),
                child: new CircleAvatar(child: new Text(_name[0])),
              ),
              new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  new Text(_name, style: Theme.of(context).textTheme.subhead),
                  new Container(
                    margin: const EdgeInsets.only(top: 5.0),
                    child: new Text(text),
                  ),
                ],
              ),
            ],
          ),
        ));
  }
}

class ChatScreen extends StatefulWidget {
  @override
  State createState() => new ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final List<ChatMessage> _messages = <ChatMessage>[];
  final TextEditingController _textController = new TextEditingController();

  void _handleSubmitted(String text) {
    _textController.clear();
    ChatMessage message = new ChatMessage(
      text: text,
      animationController: new AnimationController(
        duration: new Duration(milliseconds: 700),
        vsync: this,
      ),
    );
    setState(() {
      _messages.insert(0, message);
    });
    message.animationController.forward();
    dioPost(text);
//    dioGet();
  }

  void dioGet() async {
    String result = "";
    try {
      var dio = new Dio();
      var postUrl =
          "https://4q885jrcg6.execute-api.us-east-1.amazonaws.com/prod/ride";
      var response = await dio.get(postUrl);
      if (response.statusCode == 200) {
        result = response.data.toString();
      } else {
        result = 'Error getting result:\nHttp status ${response.statusCode}';
      }
    } catch (exception) {
      result = 'Failed getting result';
    }
    developer.log(result, name: 'my.app.category');
  }

  void dioPost(text) async {
    String result = "";
    try {
      var dio = new Dio();
      var postUrl =
          "https://4q885jrcg6.execute-api.us-east-1.amazonaws.com/prod/ride";
      var response = await dio.post(postUrl, data: {
        "queryParameters": {"Index":"123123","UserId": _name, "Message": text}
      });

      if (response.statusCode == 200) {
        result = response.data.toString();
      } else {
        result = 'Error getting result:\nHttp status ${response.statusCode}';
      }
    } catch (exception) {
      result = 'Failed getting result';
    }
    developer.log(result, name: 'my.app.category');
  }

  void _handleAR() {
    Navigator.of(context).push(
      CupertinoPageRoute<bool>(
        builder: (BuildContext context) => HelloWorldPage(),
      ),
    );
  }

  void dispose() {
    for (ChatMessage message in _messages)
      message.animationController.dispose();
    super.dispose();
  }

  Widget _buildTextComposer() {
    return new Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: new Row(children: <Widget>[
          new Container(
            margin: new EdgeInsets.symmetric(horizontal: 4.0),
            child: new IconButton(
                icon: new Icon(Icons.picture_in_picture),
                onPressed: () => _handleAR()),
          ),
          new Flexible(
            child: new TextField(
              controller: _textController,
              onSubmitted: _handleSubmitted,
              decoration:
                  new InputDecoration.collapsed(hintText: "Send a message"),
            ),
          ),
          new Container(
            margin: new EdgeInsets.symmetric(horizontal: 4.0),
            child: new IconButton(
                icon: new Icon(Icons.send),
                onPressed: () => _handleSubmitted(_textController.text)),
          ),
        ]));
  }

  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(title: new Text("Friendlychat")),
      body: new Column(children: <Widget>[
        new Flexible(
            child: new ListView.builder(
          padding: new EdgeInsets.all(8.0),
          reverse: true,
          itemBuilder: (_, int index) => _messages[index],
          itemCount: _messages.length,
        )),
        new Divider(height: 1.0),
        new Container(
          decoration: new BoxDecoration(color: Theme.of(context).cardColor),
          child: _buildTextComposer(), //modified
        ),
      ]),
    );
  }
}
