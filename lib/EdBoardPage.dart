import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:boulder_lights_app/model/route.dart';

import 'model/route.dart';

class EdBoardPage extends StatefulWidget {
  final BluetoothDevice server;
  const EdBoardPage({this.server});

  @override
  _EdBoardPage createState() => new _EdBoardPage();
}

class _EdBoardPage extends State<EdBoardPage> {

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  BluetoothConnection connection;
  bool isConnecting = true;
  bool get isConnected => connection != null && connection.isConnected;

  var _currentIndex = 1;
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
      body: _buildBoard(),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (int index) {
          onTabTapped(index, context);
        }, // new
        currentIndex: _currentIndex, // new
        items: [
          new BottomNavigationBarItem(
            icon: Icon(Icons.save),
            label: 'Save',
          ),
          new BottomNavigationBarItem(
            icon: Icon(Icons.replay),
            label: 'Reset',
          ),
          new BottomNavigationBarItem(
              icon: Icon(Icons.star), label: 'Enable')
        ],
      ),
    );
  }

  Widget _buildBoard() {
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

  void onTabTapped(int index, context) async {
    setState(() {
      _currentIndex = index;
    });

    print ('tapped index ' + index.toString());
    if (index == 0) { // save
      Map<String, dynamic> data = await _saveAs(context);
      if (data != null) {
        print('save data' + data.toString());
        _saveCurrentRoute(data);

      } else {
        print(' do nothing as modal was just closed');
      }
    }

    if (index == 1) { // reset
      _resetHolds();
    }

    if (index == 2) { // send to board
      _sendMessage(json.encode(holds));
    }

  }

  void _resetHolds() {
    for (int i = 0; i < gridState.length; i++) {
      for (int j = 0; j < gridState[i].length; j++) {
        gridState[i][j] = false;
      }
    }

    holds = [];
    _sendMessage(json.encode(holds));

    this.setState(() {});
  }

  void _saveCurrentRoute(Map<String, dynamic> config) async {
      var data;
      List<BoardRoute> routes = [];
      final directory = await getApplicationDocumentsDirectory();
      final file= File('${directory.path}/routes.json');
      if (!file.existsSync()) {
        file.createSync();
        await file.writeAsString('[]'); // create new with 0 routes
      }

      // load route db
      String routesJson = await file.readAsString();
      try {
        data = jsonDecode(routesJson);
        for (Map i in data) {
          routes.add(BoardRoute.fromJson(i));
        }

        // current holds config to json
        var holdsJson = json.encode(holds);

        // new rout init
        BoardRoute newRoute = BoardRoute(creator: 'Test',
          createdAt: DateTime.now(), difficulty: '7a', title: config["name"], config: holdsJson);

        // add new route
        routes.add(newRoute);

        // save routes

      } catch (e) {
        print('invalid json ' + e.toString());
      }


      final text =
          '[{"id": "add-uu-id-here","createdAt": "2020-01-01","title": "Route1","config": "xy coords object here","creator": "Eduard","difficulty": "5a"}, {"id": "add-uu-id-here","createdAt": "2020-01-01", "title": "Route 66","config": "xy coords object here","creator": "Eduard","difficulty": "5a"}]';

      var tmpData = [];
      for (BoardRoute r in routes) {
        tmpData.add(r.toJson());
      }
      final routesEncodedJson = json.encode(tmpData);
      print ("routes to save " + routesEncodedJson);
      await file.writeAsString(routesEncodedJson);
  }

  _saveAs(context) {
    TextEditingController _controller = TextEditingController();

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Stack(
            overflow: Overflow.visible,
            children: <Widget>[
              Positioned(
                right: -40.0,
                top: -40.0,
                child: InkResponse(
                  onTap: () {
                    Navigator.pop(context, "noice");
                  },
                  child: CircleAvatar(
                    child: Icon(Icons.close),
                    backgroundColor: Colors.red,
                  ),
                ),
              ),
              Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: TextFormField(controller: _controller),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: TextFormField(),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: RaisedButton(
                        child: Text("Speichern"),
                        onPressed: () {
                          if (_formKey.currentState.validate()) {
                            _formKey.currentState.save();
                            Navigator.pop(context, {"name": _controller.text});
                          }
                        },
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        );
      }).then((val) {
        print ('something returned? ' + val.toString());
        return val;
      });
  }
}
