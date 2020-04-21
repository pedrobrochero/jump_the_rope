import 'package:flutter/material.dart';

Widget mySizedBox() => SizedBox(height: 24,);
Widget mySizedBoxSmall() => SizedBox(height: 12,);

Widget circleAvatarWithBorder(ImageProvider image,{color = Colors.red, double radius = 16}) {
  return Container(
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(
        width: 3,
        color: color
      )
    ),
    child: CircleAvatar(
      backgroundImage: image,
      radius: radius,
    ),
  );
}

textFormField ({String label ,String hint, IconData icon , Function onChanged(String s), TextInputType inputType = TextInputType.text,TextAlign align = TextAlign.start }) {
  return TextFormField(
    textCapitalization: TextCapitalization.sentences,
    keyboardType: inputType,
    textAlign: align,
    textInputAction: TextInputAction.next,
    decoration: InputDecoration(
      contentPadding: EdgeInsets.symmetric(horizontal: 16),
      labelText: label,
      hintText: hint,
      border: inputBorder(),
      icon: icon == null ? null : Icon(icon),
    ),
    onChanged: onChanged
  );
}
dateFormField(BuildContext context, TextEditingController controller, Function onTap) => TextFormField(
  controller: controller,
  textAlign: TextAlign.center,
  enableInteractiveSelection: false,
  decoration: InputDecoration(
    labelText: 'Fecha',
    border: inputBorder(),
  ),
  onTap: () => onTap(controller)
);
button(BuildContext context, {String title, Function onPressed}) => Container(
  child: FlatButton(
    child: Text(title != null ? title : 'ACEPTAR'),
    textTheme: ButtonTextTheme.primary,
    onPressed: onPressed,
    color: Theme.of(context).primaryColor,
  ),
  width: double.infinity,
  height: 48,
);

showSnackBar(BuildContext context, String text) {
  final snackBar = SnackBar(
    content: Text(text),
  );
  Scaffold.of(context).showSnackBar(snackBar);
}

OutlineInputBorder inputBorder() => OutlineInputBorder(borderRadius: BorderRadius.circular(20));