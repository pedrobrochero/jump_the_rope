
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:jump_the_rope/data/models/session_model.dart';
import 'package:jump_the_rope/data/models/user_model.dart';
import 'package:jump_the_rope/providers/firestore.dart';

class GraphLinesWidget extends StatefulWidget {

  final Stream stream;

  GraphLinesWidget(this.stream);

  @override
  _GraphLinesWidgetState createState() => _GraphLinesWidgetState();
}

class _GraphLinesWidgetState extends State<GraphLinesWidget> {
  List<UserModel> _allUsersData;

  @override
  void initState() { 
    super.initState();
  _getUsersData();
  }

  @override
  Widget build(BuildContext context) {

    return StreamBuilder<QuerySnapshot>(
      stream: widget.stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
        if (snapshot.data.documents.length == 0) return Center(child: Text('No hay informacion para mostrar.', style: TextStyle(color: Colors.black54, fontSize: 12)),heightFactor: 2,);

        final data = List<SessionModel>();
        final usersId = List<String>();
        snapshot.data.documents.forEach((doc) {
          final session = SessionModel( 
            date: doc['date'].toDate(),
            rounds: doc['rounds'],
            userId: doc['userId'],
            id: doc.documentID
          );
          if (!usersId.contains(session.userId)) usersId.add(session.userId);
          data.add(session);
        });

        final sessionsByUser = List<List<SessionModel>>();
        usersId.forEach((userId) {
          sessionsByUser.add(data.where((session) => session.userId == userId).toList());
         });

        List<charts.Series<SessionModel, int>> series = sessionsByUser.map((e) {
          return charts.Series<SessionModel, int>(
            id: e[0].userId,
            colorFn: (_, __){ 
              UserModel selectedUser;
              if (_allUsersData != null) 
              selectedUser = _allUsersData.firstWhere((user) => user.id == e[0].userId);
              return charts.ColorUtil.fromDartColor(_getUserColor(selectedUser));
            },
            domainFn: (value, _) => value.date.millisecondsSinceEpoch,
            measureFn: (value, _) => value.getTotal(),
            data: e,
          );
        }).toList();

        return charts.LineChart(
          series,
          defaultRenderer: new charts.LineRendererConfig(),

          animate: true,
          behaviors: [
            charts.SlidingViewport(),
            charts.PanAndZoomBehavior(),
          ],
        );

      },
    );
  }

  Color _getUserColor(UserModel user) => user != null ? int.tryParse(user.color) != null ? Color(int.parse(user.color)) : Colors.purple : Colors.purple;
  _getUsersData () async {
    final collection = await FirestoreProvider.db.getUsers();
    if (collection != null) {
      if (collection.documents.length > 0) {
        final users = List<UserModel>();
        collection.documents.forEach((doc) {
          users.add(UserModel(
            id: doc.documentID,
            name: doc['name'],
            color: doc['color'],
            photoUrl: doc['photoUrl'],
          ));
        });
        setState(() {
          print('Users data gotten');
          _allUsersData = users;
        });
      }
    }
  }
}