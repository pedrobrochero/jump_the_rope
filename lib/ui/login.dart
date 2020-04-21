
import 'package:flutter/material.dart';
import 'package:jump_the_rope/data/models/user_model.dart';
import 'package:jump_the_rope/providers/firestore.dart';

class LoginUI extends StatelessWidget {
  static const ROUTE = 'login';

  const LoginUI({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Theme.of(context).accentColor,
              Theme.of(context).primaryColor,
            ]
          )
        ),
        child: _body(context)
      )
    );
  }

  Widget _body(BuildContext context) {
    return StreamBuilder(
      stream: FirestoreProvider.db.getUsersStream(),
      builder: (BuildContext context, snapshot) {
        if (!snapshot.hasData) return Center(child: CircularProgressIndicator(), heightFactor:2,);
        
        final List<DocumentSnapshot> docs = snapshot.data.documents;
        if (docs.length == 0) return Center(child: Text('No hay informacion para mostrar.'),heightFactor: 2,);

        final List<UserModel> users = docs.map((e) => UserModel(
          id: e.documentID,
          name: e['name'],
          photoUrl: e['photoUrl'],
          color: e['color']
        )).toList();
        print(users);

        final avatars = Wrap(
          spacing: 24,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: users.map((user) {
            return GestureDetector(
              child: user.photoUrl.isNotEmpty ?
                ClipOval(
                  child: FadeInImage.assetNetwork(
                    height: 100,
                    placeholder: 'lib/assets/loading.gif',
                    image: 'https://i.pravatar.cc/300'
                  )
                ): 
                CircleAvatar(
                  radius: 50,
                  backgroundColor: int.tryParse(user.color) != null ? Color(int.parse(user.color)) : Colors.blueGrey,
                  child: Text(user.name, style: TextStyle(fontSize: 20, color: Colors.white70),),
                ),
              onTap: () =>_goToHome(context, user.id),
            );
          }).toList()
        );
        print(avatars);

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text('Selecciona tu avatar', 
              style: TextStyle(
                color: Colors.white54,
                fontSize: 24,
              ),
            ),
            SizedBox(height: 48,),
            avatars
          ],
        );
      }
    );
  }

  void _goToHome (BuildContext context, String userId) {
    Navigator.pushReplacementNamed(context, 'home', arguments: userId);
  }
}