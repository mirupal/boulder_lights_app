import 'dart:io';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import './SelectBondedDevicePage.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import './EdBoardPage.dart';
import 'package:boulder_lights_app/model/route.dart';

class RouteSelectionPage extends StatefulWidget {
  @override
  _RouteSelectionPageState createState() => _RouteSelectionPageState();
}
class _RouteSelectionPageState extends State<RouteSelectionPage> {
  File _file;
  bool _loading = false;
  static List<BoardRoute> _routes = [];

  // constructor
  _RouteSelectionPageState() {
    print('route selected constructor');
  }

  @override
  void initState() {
    super.initState();
    print('route selecttion initialized');
    _initDatabase();
  }

  ///
  /// Initializes local databsae
  ///
  Future<Null> _initDatabase() async {
    setState(() {
      _routes = [];
      _loading = true;
    });

    var data;
    final directory = await getApplicationDocumentsDirectory();
    _file = File('${directory.path}/routes.json');
    if (!_file.existsSync()) {
      _file.createSync();
      await _file.writeAsString('[]'); // create new with 0 routes
    } else {
      // final text =
      //     '[{"id": "add-uu-id-here","createdAt": "2020-01-01","title": "Route1","config": "xy coords object here","creator": "Eduard","difficulty": "5a"}, {"id": "add-uu-id-here","createdAt": "2020-01-01", "title": "Route 66","config": "xy coords object here","creator": "Eduard","difficulty": "5a"}]';
      // await _file.writeAsString(text);
    }

    String routesJson = await _file.readAsString();
    print('route json raw ' + routesJson);
    try {
      data = jsonDecode(routesJson);

      for (Map i in data) {
        _routes.add(BoardRoute.fromJson(i));
      }
      setState(() {
        _loading = false;
      });
      print('JSON decoded routes: num ' +
          _routes.length.toString() +
          " " +
          _routes.toString());
    } catch (e) {
      print('invalid json ' + e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
        'Select route',
      )),
      body: Container(
          child: _loading
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: _routes.length,
                  itemBuilder: (context, i) {
                    var route = _routes[i];
                    return ListTile(
                        leading: Icon(Icons.trending_up),
                        trailing: Icon(Icons.chevron_right),
                        title: Text(route.title + " (" + route.difficulty + ")"),
                        subtitle: Text(route.creator + ", am " + DateFormat('dd.MM.yyyy kk:mm').format(route.createdAt)),
                        onTap: () async {
                          final BluetoothDevice selectedDevice =
                              await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) {
                                return SelectBondedDevicePage(checkAvailability: false);
                              },
                            ),
                          );

                          if (selectedDevice != null) {
                            print('Connect -> selected ' + selectedDevice.address);
                            //_startChat(context, selectedDevice);
                            _startShowBoard(context, selectedDevice, route.guid);
                          } else {
                            print('Connect -> no device selected');
                          }
                        });
                  })),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          // Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          //   return EditNotePage(
          //     initialNote: null,
          //   );
          // }));
        },
      ),
    );
  }


  void _startShowBoard(BuildContext context, BluetoothDevice server, String routeGuid) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return EdBoardPage(server: server, routeGuid: routeGuid);
        },
      ),
    );
  }
}
