import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:jump_the_rope/data/models/session_model.dart';
import 'package:jump_the_rope/utils/datetime_utils.dart';
import 'package:jump_the_rope/utils/ui.dart';
import 'package:jump_the_rope/providers/firestore.dart';
import 'package:jump_the_rope/utils/validators.dart';

class AddInfoUI extends StatefulWidget {
  static const ROUTE = 'add_info';

  const AddInfoUI({Key key}) : super(key: key);

  @override
  _AddInfoUIState createState() => _AddInfoUIState();
}

class _AddInfoUIState extends State<AddInfoUI> {

  Stream<QuerySnapshot> _usersStream;

  String _selectedUser;
  String _photoUrl;
  List<String> _session = [''];
  DateTime _date;
  TextEditingController _dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _usersStream = FirestoreProvider.db.getUsersStream();
    _photoUrl = 'https://i.pravatar.cc/300';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Ingresar info')),
      body: Builder (
        builder: (context) => Column(
        children: [Expanded(
          child: ListView(
            padding: EdgeInsets.all(16),
            children: <Widget>[
              dateFormField(context, _dateController, onTapDate),
              mySizedBox(),
              Center(child: CircleAvatar(
                backgroundImage: _photoUrl != null ? 
                NetworkImage(_photoUrl) : AssetImage('lib/assets/ph_person.png'),
                radius: 50,
              )),
              StreamBuilder<QuerySnapshot>( // Dropdown users
                stream: _usersStream ,
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
                  return Container(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 48),
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _selectedUser,
                        onChanged: (String newValue) {
                          setState(() {
                            _selectedUser = newValue;
                            print(_selectedUser);
                          });
                        },
                        items: snapshot.hasData ? snapshot.data.documents
                          .map<DropdownMenuItem<String>>((DocumentSnapshot doc) {
                            return DropdownMenuItem<String>(
                              value: doc.documentID,
                              child: Text(doc['name']),
                            );
                          })
                          .toList() : [],
                      ),
                    ),
                  );
                },
              ),
              ListView.builder( // Rounds data
                shrinkWrap: true, 
                padding: const EdgeInsets.symmetric(horizontal: 48),
                physics: ClampingScrollPhysics(),
                itemCount: _session.length,
                itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text((index + 1).toString()),
                      ),
                      Expanded(
                        child: textFormField(
                          hint: '# de saltos', 
                          onChanged: (s) => onChangedText(index, s),
                          inputType: TextInputType.number,
                          align: TextAlign.center
                        )
                      )
                    ]
                  ),
                );
               },
              ),
            ],
          ),
        ),
          button(context,title: 'GUARDAR DATOS' , onPressed: () => validateForm(context))
        ]
      ),
      )
    );
  }
  onTapDate(TextEditingController controller) async {
    FocusScope.of(context).requestFocus(FocusNode());
    DateTime date = await showDatePicker(
      context: context, 
      initialDate: DateTime.now(), 
      firstDate: DateTime(DateTime.now().year - 100), 
      lastDate: DateTime(DateTime.now().year + 100),
    );
    if (date != null) {
        controller.text = DateTimeUtils.dateToString(date);
        _date = date;
    } 
  }

  validateForm(BuildContext context) {
    bool thereAreErrors = false;
    if (!isNotEmpty(_dateController.text)) {
      print('Date error');
      thereAreErrors = true;
    }
    if (!isNotEmpty(_selectedUser)) {
      print('User error');
      thereAreErrors = true;
    }
    if (_session.length == 1) {
      print('Rounds error');
      thereAreErrors = true;
    }
    for (int i = 0; i < _session.length -1; i++) {
      if (!isInt(_session[i])) {
        print('Rounds error');
        thereAreErrors = true;
      }
    }
    if (thereAreErrors) showSnackBar(context, ' Verifique los errores');
    else saveData();
  }
  saveData() {
    if ( _session.last.isEmpty) _session.removeLast();
    var rounds = _session.join(',');
    // rounds = rounds.substring(0, rounds.length-2);
    print(rounds);
    final session = SessionModel(
      date: _date,
      userId: _selectedUser,
      rounds: rounds,
    );

    FirestoreProvider.db.createSession(session);
    Navigator.pop(context);
  }

  onChangedText(int index, String text) {
    setState(() {
      _session[index] = text;
      if ((index + 1) == _session.length) {
          if (text?.isNotEmpty == true)
            _session.add('');
      } else if ((index + 1) == _session.length -1) {
        if (!(text?.isNotEmpty == true)  && !(_session[index+1]?.isNotEmpty == true)) {
          _session.removeLast();
        }
      }
    });
  }
}