import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jump_the_rope/utils/ui.dart';

class AddEditUser extends StatefulWidget {

  static const ROUTE = 'add_edit_user';
  const AddEditUser({Key key}) : super(key: key);

  @override
  _AddEditUserState createState() => _AddEditUserState();
}

class _AddEditUserState extends State<AddEditUser> {

  bool _isNewUser = true;
  List<String> _users = ['carlos', 'joana', 'mayi', 'pedro', 'ricardo'];
  String _selectedUser;
  String _newUserName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Crear usuario')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
          CheckboxListTile (
            title: Text('Crear usuario'),
            value: _isNewUser,
            onChanged: (value) {
              setState(() {
                _isNewUser = value;
              });
            },
          ),
          Visibility(
            visible: !_isNewUser,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: DropdownButton(
                items: _users.map((String name) {
                  return DropdownMenuItem<String>(
                    child: Text(name),
                    value: name,
                  );
                }).toList(),
                onChanged: (selected){
                  setState(() {
                    _selectedUser = selected;
                  });
                },
                isExpanded: true,
                value: _selectedUser,
              ),
            ),
          ),
          Visibility(
            visible: _isNewUser,
            child: textFormField(label: 'Nombre', onChanged: (value) => (){
              setState(() {
                _newUserName = value;
              });
            }),
          ),
          mySizedBox(),
          CircleAvatar(
            backgroundImage: NetworkImage('https://i.pravatar.cc/300'),
            radius: 70,
          )
        ],),
      ),
    );
  }
}