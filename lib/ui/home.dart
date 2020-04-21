import 'package:flutter/material.dart';
import 'package:jump_the_rope/data/models/session_model.dart';
import 'package:jump_the_rope/data/models/user_model.dart';
import 'package:jump_the_rope/providers/prefs_provider.dart';
import 'package:jump_the_rope/ui/widgets/graph_bar_widget.dart';
import 'package:jump_the_rope/ui/widgets/graph_lines_widget.dart';
import 'package:jump_the_rope/utils/ui.dart';
import 'package:jump_the_rope/providers/firestore.dart';

class HomeUI extends StatefulWidget {
  static const ROUTE = 'home';

  const HomeUI({Key key}) : super(key: key);

  @override
  _HomeUIState createState() => _HomeUIState();
}

class _HomeUIState extends State<HomeUI> {

  UserModel _currentUser;
  Stream _mySessions;

  void _checkForUser() {
    String userId = ModalRoute.of(context).settings.arguments;
    final prefs = PrefsProvider();
    if (userId == null) {
      userId = prefs.userId;
    }
    else {
      prefs.userId = userId;
    }
    _getUserData(userId);
    _mySessions = FirestoreProvider.db.getSessionsByUser(userId);
  }

  @override
  void didChangeDependencies() {
    _checkForUser();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentUser != null ? _currentUser.name : 'Jump the rope'),
        actions: _currentUser != null ? _currentUser.name == 'Pedro' ? _menuItems() : null : null,
        backgroundColor: _getUserColor(),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.all(16),
          child: Column(
            children: [
              _myBestNumbers(_mySessions),
              mySizedBox(),
              Text('Mi rendimiento diario'),
              Container( // BarChart
                height: 250,
                child: GraphBarWidget(_mySessions, _getUserColor())
              ),
              mySizedBox(),
              Text('Detalle'),
              _getSessionsTable(),
              mySizedBox(),
              Text('Rendimiento de todos'),
              Container( // BarChart
                height: 250,
                child: GraphLinesWidget(FirestoreProvider.db.getSessions())
              ),
              mySizedBoxSmall(),
              _avatars(),
            ]
          ),
        ),
      ),
    );
  }
  Widget _myBestNumbers(Stream stream) {
    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (BuildContext context, snapshot) {
        int bestSession;
        int bestRound;

        if (snapshot.hasData) {
          final List docs = snapshot.data.documents;
          if (docs.length > 0) {
            bestSession = 0;
            bestRound = 0;
            docs.forEach((doc) { 
              final SessionModel session = SessionModel(rounds: doc['rounds']);
              
              final sessionCount = session.getTotal();
              if (sessionCount > bestSession) bestSession = sessionCount;

              final rounds = session.getRoundsList();
              rounds.forEach((round) {
                if (round > bestRound) bestRound = round;
              });
            });
          }
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column (
              children: [
                Text('Mi mejor sesión'),
                Text(bestSession != null ? bestSession.toString() : '-', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32),),
              ],
            ),
            Column (
              children: [
                Text('Mi mejor ronda'),
                Text(bestRound != null ? bestRound.toString() : '-', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32),),
              ],
            ),
          ],
        );
      },
    );
  }
  Widget _avatars() {
    return StreamBuilder(
      stream: FirestoreProvider.db.getUsersStream(),
      builder: (BuildContext context, snapshot) {
        if (!snapshot.hasData) return Center(child: CircularProgressIndicator(), heightFactor: 2,);
        
        final List<DocumentSnapshot> docs = snapshot.data.documents;
        if (docs.length == 0) return Center(child: Text('No hay informacion para mostrar.'),heightFactor: 2,);

        final List<UserModel> users = docs.map((e) => UserModel(
          id: e.documentID,
          name: e['name'],
          photoUrl: e['photoUrl'],
          color: e['color']
        )).toList();
        print(users);

        return Wrap(
          spacing: 24,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: users.map((user) {
            return  user.photoUrl.isNotEmpty ?
              Container(
                decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  width: 4,
                  color: int.tryParse(user.color) != null ? Color(int.parse(user.color)) : Colors.blueGrey,
                )),
                child: ClipOval(
                  child: FadeInImage.assetNetwork(
                    height: 22,
                    placeholder: 'lib/assets/loading.gif',
                    image: 'https://i.pravatar.cc/300'
                  )
                ),
              ): 
              CircleAvatar(
                radius: 15,
                backgroundColor: int.tryParse(user.color) != null ? Color(int.parse(user.color)) : Colors.blueGrey,
                child: Text(user.name.substring(0,1), style: TextStyle( color: Colors.white70),),
              );
          }).toList()
        );
      }
    );
  }
  Widget _getSessionsTable() {
    return StreamBuilder<QuerySnapshot>(
      stream: _mySessions,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Center(child: CircularProgressIndicator(), heightFactor: 2,);
        
        final List<DataColumn> columns = List();
        final List<List<DataCell>> cellsLists = List();
        final docs = snapshot.data.documents;

        if (docs.length == 0) return Center(child: Text('No hay informacion para mostrar.', style: TextStyle(color: Colors.black54, fontSize: 12)),heightFactor: 2,);

        columns.add(DataColumn(label: Text('Ronda')));
        // Recorrer documentos (sesiones)
        for (int i = 0; i < docs.length; i++) {
          final SessionModel session = SessionModel(date: docs[i]['date'].toDate());
          columns.add(DataColumn(label: Text(session.shortDate())));
          final rounds = docs[i]['rounds'].toString().split(',');
          // Recorrer rondas de la sesion y crear fila si es necesario
          for (int j = 0; j < rounds.length; j++) {
            if (j == cellsLists.length) {
              cellsLists.add(List());
              cellsLists[j].add(DataCell(Center(child: Text((j+1).toString()))));
            }
            // Rellenar celdas si es necesario
            while (cellsLists[j].length < i + 1)
            cellsLists[j].add(DataCell(Center(child: Text('-'))));
            // Celda con datos
            cellsLists[j].add(DataCell(Center(child: Text(rounds[j]))));
          }
        }
        // Rellenar celdas al finalizar si es necesario
        if (cellsLists.length > 0) {
          final numberOfSessions = cellsLists[0].length;
          cellsLists.forEach((row) {
            while(row.length < numberOfSessions)
            row.add(DataCell(Center(child: Text('-'))));
           });
        }

        Widget table = SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            dataRowHeight: 32,
            columns: columns,
            rows: cellsLists.map((e) => DataRow(cells: e)).toList(),
          ) ,
        );

        return table;
      },
    );
  }
  Color _getUserColor() => _currentUser != null ? int.tryParse(_currentUser.color) != null ? Color(int.parse(_currentUser.color)) : Colors.purple : Colors.purple;
  List<Widget> _menuItems() => [
      IconButton(
        icon: Icon(Icons.person),
        onPressed: () => _onMenuItemSelected('back_to_login'),
      ),
      PopupMenuButton<String>(
        onSelected: (String result) { _onMenuItemSelected(result); },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem(
          value: 'add_info',
          child: Text('Agregar info'),
        ),
        const PopupMenuItem(
          value: 'add_user',
          child: Text('Crear usuario'),
        ),
        const PopupMenuItem(
          value: 'edit_user',
          child: Text('Editar usuario'),
        ),
        ],
      )
    ];

  _getUserData(String userId) async {
    final doc = await FirestoreProvider.db.getUserById(userId);
    if (doc == null)  {
      print('Userdata from server is null');
      return;
    }
    setState(() {
      _currentUser = UserModel(
        id: doc.documentID,
        name:  doc['name'],
        photoUrl: doc['photoUrl'],
        color: doc['color'],
      );
    });
  }
  _eraseUserData() async {
    final prefs = PrefsProvider();
    prefs.userId = null; 
    _currentUser = null;
  }

  void _onMenuItemSelected(String selected) {
    switch (selected) {
      case 'add_info':
        Navigator.pushNamed(context, 'add_info');
      break;
      case 'back_to_login':{
        _eraseUserData();
        _goToLogin();
      }
      break;
      case 'add_user':
        Navigator.pushNamed(context, 'add_edit_user');
      break;
      case 'edit_user':
      break;
    }
  }
  void _goToLogin() {
    Navigator.pushReplacementNamed(context, 'login');
  }
}