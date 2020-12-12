import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:boulder_lights_app/model/route.dart';

class RouteSelectionPage extends StatefulWidget {
  @override
  _RouteSelectionPageState createState() => _RouteSelectionPageState();
}

// final directory = await getApplicationDocumentsDirectory();
// final file = File('${directory.path}/my_file.txt');

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
    // if (!_file.existsSync()) {
    _file.createSync();
    final text = '[{"title": "Route1", "config": "xy coords object here"}, {"title": "Route 66", "config": "xy coords object here"}]';
    await _file.writeAsString(text);
    // }

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
          'NotePad',
        )),
        body: Container(
            child: _loading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _routes.length,
                    itemBuilder: (context, i) {
                      return Container(
                        child: Text(_routes[i].title),
                      );
                    }))
        // body: StreamBuilder<List<BoardRoute>>(
        //   stream: noteProvider.onNotes(), // TODO add stream from json file
        //   builder: (context, snapshot) {
        //     var notes = snapshot.data;
        //     if (notes == null) {
        //       return Center(
        //         child: CircularProgressIndicator(),
        //       );
        //     }
        //     return ListView.builder(
        //         itemCount: notes?.length,
        //         itemBuilder: (context, index) {
        //           var note = notes[index];
        //           return ListTile(
        //             title: Text(note.title?.v ?? ''),
        //             subtitle: Text("tdodo add description"),
        //             onTap: () async {
        //               Navigator.of(context).push(
        //                 MaterialPageRoute(
        //                   builder: (context) {
        //                     return EdBoardPage(
        //                       server: server,
        //                     );

        //                     /// TODO need to set serverin a singleton sevice so its accessible from everywhere. Use get_it for this
        //                   },
        //                 ),
        //               );
        //             },
        //           );
        //         });
        //   },
        // ),
        // floatingActionButton: FloatingActionButton(
        //   child: Icon(Icons.add),
        //   onPressed: () {
        //     Navigator.of(context).push(MaterialPageRoute(builder: (context) {
        //       return EditNotePage(
        //         initialNote: null,
        //       );
        //     }));
        //   },
        // ),
        );
  }
}
