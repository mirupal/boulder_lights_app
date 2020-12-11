import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class EdBoardPage extends StatefulWidget {
  final BluetoothDevice server;
  const EdBoardPage({this.server});

  @override
  _EdBoardPage createState() => new _EdBoardPage();
}

class _EdBoardPage extends State<EdBoardPage> {
  static final clientID = 0;
  BluetoothConnection connection;
  bool isConnecting = true;
  bool get isConnected => connection != null && connection.isConnected;

  bool isDisconnecting = false;
  List<List<bool>> gridState = [
    [
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
    ],
    [
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
    ],
    [
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
    ],
    [
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
    ],
    [
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
    ],
    [
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
    ],
    [
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
    ],
    [
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
    ],
  ];

  List<Map<String, int>> holds = [];

  _EdBoardPage();

  @override
  void initState() {
    super.initState();
    BluetoothConnection.toAddress(widget.server.address).then((_connection) {
      print('Connected to the device');
      connection = _connection;
      setState(() {
        isConnecting = false;
        isDisconnecting = false;
      });

      connection.input.listen(_onDataReceived).onDone(() {
        // Example: Detect which side closed the connection
        // There should be `isDisconnecting` flag to show are we are (locally)
        // in middle of disconnecting process, should be set before calling
        // `dispose`, `finish` or `close`, which all causes to disconnect.
        // If we except the disconnection, `onDone` should be fired as result.
        // If we didn't except this (no flag set), it means closing by remote.
        if (isDisconnecting) {
          print('Disconnecting locally!');
        } else {
          print('Disconnected remotely!');
        }
        if (this.mounted) {
          setState(() {});
        }
      });
    }).catchError((error) {
      print('Cannot connect, exception occured');
      print(error);
    });
  }

  @override
  void dispose() {
    // Avoid memory leak (`setState` after dispose) and disconnect
    if (isConnected) {
      isDisconnecting = true;
      connection.dispose();
      connection = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: (isConnecting
              ? Text('Connecting to board ...')
              : isConnected
                  ? Text('Connected with board')
                  : Text('no connection')),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.replay),
              onPressed: () => print("pressed something!"),
            )
          ],
        ),
        body: _buildGameBody());
  }

  Widget _buildGameBody() {
    int gridStateLength = gridState.length;

    int gridWidth = gridState[0].length;
    int gridHeight = gridState.length;
    print("grid: " + gridState[0][0].toString());
    print("grid dimesions: " +
        gridWidth.toString() +
        "x" +
        gridHeight.toString());
    return Column(children: <Widget>[
      AspectRatio(
        aspectRatio: 1.0 / 1.2,
        child: Container(
          padding: const EdgeInsets.all(8.0),
          margin: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 2.0)),
          child: GridView.count(
              crossAxisCount: gridWidth,
              childAspectRatio: 1.0,
              padding: const EdgeInsets.all(3.0),
              mainAxisSpacing: 3.0,
              crossAxisSpacing: 3.0,
              children: [
                for (var i = 0; i < (gridWidth * gridHeight); i++)
                  _buildHoldChild(context, i)
              ]),
        ),
      ),
    ]);
  }

  Widget _buildHoldChild(BuildContext context, int index) {
    int gridWidth = gridState[0].length;
    int gridHeight = gridState.length;
    int x, y = 0;
    y = (index / gridWidth).floor();
    x = (index % gridWidth);

    return GestureDetector(
        onTap: () {
          print("tapped coord x" + x.toString() + " y" + y.toString());
          // on gridstate coordinates are inverted
          gridState[y][x] = !gridState[y][x];
          if (gridState[y][x]) {
            holds.add({'x': x, 'y': y});
          } else {
            holds.removeWhere(
                (element) => element['x'] == x && element['y'] == y);
          }
          print(holds.toString());
          _sendMessage(json.encode(holds));
          this.setState(() {});
        },
        child: GridTile(
          child: Container(
            decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 0.3)),
            child: Center(
              child: _buildGridItem(y, x, index),
            ),
          ),
        ));
  }

  Widget _buildGridItem(int x, int y, int index) {
    switch (gridState[x][y]) {
      // case '':
      //   return Text('');
      //   break;
      // case 'P1':
      //   return Container(
      //     color: Colors.blue,
      //   );
      //   break;
      // case 'P2':
      //   return Container(
      //     color: Colors.yellow,
      //   );
      //   break;
      // case 'T':
      //   return Icon(
      //     Icons.terrain,
      //     size: 40.0,
      //     color: Colors.red,
      //   );
      //   break;
      // case 'B':
      //   return Icon(Icons.remove_red_eye, size: 40.0);
      //   break;
      default:
        return Text(gridState[x][y] ? 'x' : 'o');
      //return Text(index.toString());
    }
  }

  void _onDataReceived(Uint8List data) {
    // nothing todo
  }

  void _sendMessage(String text) async {
    text = text.trim();

    if (text.length > 0) {
      try {
        connection.output.add(utf8.encode(text + "\r\n"));
        await connection.output.allSent;
      } catch (e) {
        // Ignore error, but notify state
        setState(() {});
      }
    }
  }
}
