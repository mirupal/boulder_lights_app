import 'package:flutter/material.dart';
import 'package:boulder_lights_app/model/route.dart';

class RouteSelectionPage extends StatefulWidget {
  @override
  _RouteSelectionPageState createState() => _RouteSelectionPageState();
}

class _RouteSelectionPageState extends State<RouteSelectionPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
        'NotePad',
      )),
      body: StreamBuilder<List<BoardRoute>>(
        stream: noteProvider.onNotes(), // TODO add stream from json file
        builder: (context, snapshot) {
          var notes = snapshot.data;
          if (notes == null) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return ListView.builder(
              itemCount: notes?.length,
              itemBuilder: (context, index) {
                var note = notes[index];
                return ListTile(
                  title: Text(note.title?.v ?? ''),
                  subtitle: Text("tdodo add description"),
                  onTap: () async {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) {
                          return EdBoardPage(
                            server: server,
                          );

                          /// TODO need to set serverin a singleton sevice so its accessible from everywhere. Use get_it for this
                        },
                      ),
                    );
                  },
                );
              });
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            return EditNotePage(
              initialNote: null,
            );
          }));
        },
      ),
    );
  }
}
