// To parse this JSON data, do
//
//     final sessionModel = sessionModelFromJson(jsonString);

import 'dart:convert';

import 'package:jump_the_rope/utils/datetime_utils.dart';

SessionModel sessionModelFromJson(String str) => SessionModel.fromJson(json.decode(str));

String sessionModelToJson(SessionModel data) => json.encode(data.toJson());

class SessionModel {
    String id;
    String userId;
    DateTime date;
    String rounds;

    SessionModel({
        this.id,
        this.userId,
        this.date,
        this.rounds,
    });


    factory SessionModel.fromJson(Map<String, dynamic> json) => SessionModel(
        id: json["id"],
        userId: json["userId"],
        date: json["date"],
        rounds: json["rounds"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "userId": userId,
        "date": date,
        "rounds": rounds,
    };

    String shortDate() {
      if (date == null) return '';
      return '${DateTimeUtils.monthsNames[date.month]} ${date.day}';
    }

    int getTotal() {
      int total = 0;
      rounds.split(',').forEach((round) {
        total += int.parse(round);
       });
       return total;
    }

    List<int> getRoundsList() => rounds.split(',').map((e) => int.parse(e)).toList();
}
