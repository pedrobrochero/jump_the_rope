// To parse this JSON data, do
//
//     final userModel = userModelFromJson(jsonString);

import 'dart:convert';

UserModel userModelFromJson(String str) => UserModel.fromJson(json.decode(str));

String userModelToJson(UserModel data) => json.encode(data.toJson());

class UserModel {
    String id;
    String name;
    String photoUrl;
    String color;

    static const USERTYPE_DEV = 0;
    static const USERTYPE_CUSTOMER = 10;

    UserModel({
        this.id,
        this.name,
        this.photoUrl,
        this.color,
    });

    factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json["id"],
        name: json["name"],
        photoUrl: json["photoUrl"],
        color: json["color"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "photoUrl": photoUrl,
        "color": photoUrl,
    };
}
