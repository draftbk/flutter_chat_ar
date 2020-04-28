import 'package:arkit_plugin/arkit_plugin.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vector;
import 'dart:collection';

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
        appBar: AppBar(title: const Text('Tap Gesture Sample')),
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

    final material = ARKitMaterial(
        diffuse: ARKitMaterialProperty(
          color: Colors.white,
        ),
        transparency: 0.5);

    for (int i = 1; i <= 9; i++) {
      sphereHashMap[i.toString()] = ARKitSphere(
        materials: [material],
        radius: 0.05,
      );
    }

    this.arkitController.add(_createChess("1", -0.1, -0.1));
    this.arkitController.add(_createChess("2", 0.1, -0.1));
    this.arkitController.add(_createChess("3", 0.3, -0.1));

    this.arkitController.add(_createChess("4", -0.1, 0.1));
    this.arkitController.add(_createChess("5", 0.1, 0.1));
    this.arkitController.add(_createChess("6", 0.3, 0.1));

    this.arkitController.add(_createChess("7", -0.1, 0.3));
    this.arkitController.add(_createChess("8", 0.1, 0.3));
    this.arkitController.add(_createChess("9", 0.3, 0.3));
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
}
