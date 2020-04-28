import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ar/tap_page.dart';
import 'package:dio/dio.dart';
import 'dart:developer' as developer;

void main() {
  runApp(new FriendlychatApp());
}

const String _name = "User1";
const int LIMIT = 10;

class FriendlychatApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: "ARChat",
      debugShowCheckedModeBanner: false,
      home: new ChatScreen(),
    );
  }
}

class ChatMessage extends StatelessWidget {
  ChatMessage({this.textMap, this.animationController});

  final Map textMap;
  final AnimationController animationController;

  @override
  Widget build(BuildContext context) {
    var name = textMap['name'];
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
                child: new CircleAvatar(
                    child: new Text(name.contains("User1") ? "Z" : "S")),
              ),
              new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  new Text(textMap['name'],
                      style: Theme.of(context).textTheme.subhead),
                  new Container(
                    margin: const EdgeInsets.only(top: 5.0),
                    child: new Text(textMap['message']),
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
  LinkedHashSet _messageIndexs = new LinkedHashSet();
  final TextEditingController _textController = new TextEditingController();

  void _handleSubmitted(String text) {
    if (text == "") {
      handleMessages();
      return;
    }
    _textController.clear();
    ChatMessage message = new ChatMessage(
      textMap: {'name': _name, 'message': text},
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
  }

  void dioPost(text) async {
    String result = "";
    String index = new DateTime.now().millisecondsSinceEpoch.toString();
    try {
      var dio = new Dio();
      var postUrl =
          "xx";
      var response = await dio.post(postUrl, data: {
        "queryParameters": {
          "Index": index,
          "UserId": _name,
          "Message": text,
          "Time": index
        }
      });

      if (response.statusCode == 200) {
        result = response.data.toString();
        _messageIndexs.add(index);
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
        builder: (BuildContext context) => TapPage(),
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
      appBar: new AppBar(title: new Text("ARChat")),
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

  void handleMessages() async {
    _messages.clear();
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
    handleResult(result);
  }

  void handleResult(String result) {
    result = result.substring(25, result.length - 2);
    var resultList = result.split("},");
    var chatItems = [];
    for (String item in resultList) {
      var itemList = item.split(",");
      chatItems.add(ChatItem(
          itemList[2].substring(6, itemList[2].length),
          itemList[3].substring(7, itemList[3].length),
          itemList[0].substring(9, itemList[0].length),
          itemList[1].substring(9, itemList[1].length)));
    }
    chatItems.sort((a, b) => b.time.compareTo(a.time));

    for (int i = 0; i < LIMIT; i++) {
      _handleReceivedMessage(chatItems[i].name, chatItems[i].message);
    }
  }

  void _handleReceivedMessage(String name, String text) {
    ChatMessage message = new ChatMessage(
      textMap: {'name': name, 'message': text},
      animationController: new AnimationController(
        duration: new Duration(milliseconds: 700),
        vsync: this,
      ),
    );
    setState(() {
      _messages.insert(_messages.length, message);
    });
    message.animationController.forward();
  }
}

class ChatItem {
  String index;
  String time;
  String name;
  String message;

  ChatItem(String index, String time, String name, String message) {
    this.index = index;
    this.time = time;
    this.name = name;
    this.message = message;
  }
}
