import 'package:arkit_plugin/arkit_plugin.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vector;
import 'dart:collection';
import 'package:dio/dio.dart';
import 'dart:developer' as developer;

class TapPage extends StatefulWidget {
  @override
  _TapPageState createState() => _TapPageState();
}

class _TapPageState extends State<TapPage> {
  ARKitController arkitController;
  ARKitSphere sphere;
  HashMap sphereHashMap = new HashMap<String, ARKitSphere>();
  int stepNumber = 0;
  var chessboard = [
    [0, 0, 0],
    [0, 0, 0],
    [0, 0, 0]
  ];

  @override
  void dispose() {
    arkitController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Tic-Tac-Toe')),
        body: Container(
          child: ARKitSceneView(
            enableTapRecognizer: true,
            onARKitViewCreated: onARKitViewCreated,
          ),
        ),
      );

  void onARKitViewCreated(ARKitController arkitController) {
    this.arkitController = arkitController;
    this.arkitController.onNodeTap = (nodes) => onNodeTapHandler(nodes);
    this.arkitController.add(_createTube(0.0, 0.1, -0.5, 0.0));
    this.arkitController.add(_createTube(0.2, 0.1, -0.5, 0.0));
    this.arkitController.add(_createTube(0.1, 0.22, -0.5, 0.37));
    this.arkitController.add(_createTube(0.1, -0.02, -0.5, 0.37));
    clearCheeseboard();
    listenChessBoard();
    final material = ARKitMaterial(
        diffuse: ARKitMaterialProperty(
          color: Colors.white,
        ),
        transparency: 0.1);

    for (int i = 1; i <= 9; i++) {
      sphereHashMap[i.toString()] = ARKitSphere(
        materials: [material],
        radius: 0.05,
      );
    }

    this.arkitController.add(_createChess("1", -0.1, 0.3));
    this.arkitController.add(_createChess("2", 0.1, 0.3));
    this.arkitController.add(_createChess("3", 0.3, 0.3));

    this.arkitController.add(_createChess("4", -0.1, 0.1));
    this.arkitController.add(_createChess("5", 0.1, 0.1));
    this.arkitController.add(_createChess("6", 0.3, 0.1));

    this.arkitController.add(_createChess("7", -0.1, -0.1));
    this.arkitController.add(_createChess("8", 0.1, -0.1));
    this.arkitController.add(_createChess("9", 0.3, -0.1));
  }

  void onNodeTapHandler(List<String> nodesList) {
    final name = nodesList.first;
    final color = stepNumber % 2 == 0 ? Colors.white : Colors.black;
    sphereHashMap[name].materials.value = [
      ARKitMaterial(
          diffuse: ARKitMaterialProperty(color: color), transparency: 1)
    ];
    var x = ((int.parse(name) - 1) / 3).floor();
    var y = (int.parse(name) - 1) % 3;
    chessboard[x][y] = stepNumber % 2 == 0 ? 1 : 2;
    updateCheeseboardPosition(name, stepNumber % 2 == 0 ? "1" : "2");
    var result = checkResult();
    if (result != 0) {
      showDialog<void>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
            content: Text(result == 1 ? "white wins!" : "black wins!")),
      );
    }
    stepNumber = stepNumber + 1;
  }

  ARKitNode _createChess(name, x, y) => ARKitNode(
        name: name,
        geometry: sphereHashMap[name],
        position: vector.Vector3(x, y, -0.5),
      );

  ARKitNode _createTube(x, y, z, r) => ARKitNode(
        geometry: ARKitTube(
            innerRadius: 0.02,
            outerRadius: 0.03,
            height: 0.60,
            materials: _createRandomColorMaterial()),
        position: vector.Vector3(x, y, z),
        rotation: vector.Vector4(0.0, 0.0, r, 1.57),
      );

  List<ARKitMaterial> _createRandomColorMaterial() {
    return [
      ARKitMaterial(
        lightingModelName: ARKitLightingModel.physicallyBased,
        diffuse: ARKitMaterialProperty(
          color: Colors.brown,
        ),
      )
    ];
  }

  int checkResult() {
    for (int i = 0; i < 3; i++) {
      if (chessboard[i][0] == chessboard[i][1] &&
          chessboard[i][1] == chessboard[i][2]) {
        return chessboard[i][0];
      }
      if (chessboard[0][i] == chessboard[1][i] &&
          chessboard[1][i] == chessboard[2][i]) {
        return chessboard[0][i];
      }
    }
    if (chessboard[0][0] == chessboard[1][1] &&
        chessboard[1][1] == chessboard[2][2]) {
      return chessboard[0][0];
    }
    if (chessboard[0][2] == chessboard[1][1] &&
        chessboard[1][1] == chessboard[2][0]) {
      return chessboard[0][2];
    }
    return 0;
  }

  void getCheeseboardPositions() async {
    String result = "";
    try {
      var dio = new Dio();
      var postUrl =
          "xx";
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

  void updateCheeseboardPosition(position, tag) async {
    String result = "";
    try {
      var dio = new Dio();
      var postUrl =
          "xx";
      var response = await dio.post(postUrl, data: {
        "queryParameters": {
          "ChessPosition": position,
          "ChessTag": tag,
        }
      });

      if (response.statusCode == 200) {
        result = response.data.toString();
      } else {
        result = 'Error getting result:\nHttp status ${response.statusCode}';
      }
    } catch (exception) {
      result = 'Failed getting result';
    }
  }

  void handleResult(String result) {
    result = result.substring(25, result.length - 2);
    var resultList = result.split("},");
    stepNumber = 0;
    for (String item in resultList) {
      var itemList = item.split(",");
      var x = ((int.parse(getNumberFromString(itemList[1])) - 1) / 3).floor();
      var y = (int.parse(getNumberFromString(itemList[1])) - 1) % 3;
      chessboard[x][y] = int.parse(getNumberFromString(itemList[0]));
      if(getNumberFromString(itemList[0])=="0"){
        continue;
      }
      stepNumber = stepNumber +1;
      final color = chessboard[x][y] == 1 ? Colors.white : Colors.black;
      sphereHashMap[getNumberFromString(itemList[1])].materials.value = [
        ARKitMaterial(
            diffuse: ARKitMaterialProperty(color: color), transparency: 1)
      ];
    }
  }

  String getNumberFromString(item) {
    for (int i = 0; i <= 9; i++) {
      if (item.contains(i.toString())) {
        return i.toString();
      }
    }
    return "0";
  }

  void clearCheeseboard() {
    for (int i = 1; i <= 9; i++) {
      updateCheeseboardPosition(i.toString(), "0");
    }
  }

  Future<void> listenChessBoard() async{
    while(true){
      try{
        await Future.delayed(Duration(seconds: 2));
        getCheeseboardPositions();
      }catch(e){
        print('failed: ${e.toString()}');
      }
    }
  }
}
