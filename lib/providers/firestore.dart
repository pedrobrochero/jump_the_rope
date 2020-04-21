import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jump_the_rope/data/models/session_model.dart';
export 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreProvider {
  static Firestore _database;
  static final FirestoreProvider db = FirestoreProvider._();

  FirestoreProvider._();

  Firestore get database {
    if (_database != null) return _database;

    _database = Firestore.instance;
    return _database;
  }

  Stream<QuerySnapshot> getSessions()  {
    final db =  database;
    return db.collection('jump_the_rope').document('jump_the_rope')
      .collection('sessions')
      .orderBy("date")
      .snapshots();
  }
  Stream<QuerySnapshot> getSessionsByUser(String userId)  {
    final db =  database;
    return db.collection('jump_the_rope').document('jump_the_rope')
      .collection('sessions')
      .where("userId", isEqualTo: userId)
      .orderBy("date")
      .snapshots();
  }
  Future<QuerySnapshot> getUsers()  {
    final db = database;
    return db.collection('jump_the_rope')
      .document('jump_the_rope')
      .collection('users')
      .orderBy('name')
      .getDocuments();
  }
  Stream<QuerySnapshot> getUsersStream()  {
    final db = database;
    return db.collection('jump_the_rope')
      .document('jump_the_rope')
      .collection('users')
      .orderBy('name')
      .snapshots();
  }
  Future<DocumentSnapshot> getUserById(String id)  {
    final db = database;
    return db.collection('jump_the_rope')
      .document('jump_the_rope')
      .collection('users')
      .document(id)
      .get();
  }

  // Insert
  createSession(SessionModel session) {
    final db =  database;
    db.collection('jump_the_rope').document('jump_the_rope')
    .collection('sessions').add({ 
        'date': session.date,
        'rounds': session.rounds ,
        'userId': session.userId ,
       });
  }
}