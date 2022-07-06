// To parse this JSON data, do
//
//     final chartDayModel = chartDayModelFromJson(jsonString);

import 'dart:convert';

ChartRangeModel chartRangeModelFromJson(String str) => ChartRangeModel.fromJson(json.decode(str));

String chartRangeModelToJson(ChartRangeModel data) => json.encode(data.toJson());

class ChartRangeModel {
  ChartRangeModel({
    required this.err,
    required this.status,
    required this.message,
  });

  bool err;
  bool status;
  List<Message> message;

  factory ChartRangeModel.fromJson(Map<String, dynamic> json) => ChartRangeModel(
        err: json["err"],
        status: json["status"],
        message: List<Message>.from(json["message"].map((x) => Message.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "err": err,
        "status": status,
        "message": List<dynamic>.from(message.map((x) => x.toJson())),
      };
}

class Message {
  Message({
    required this.datalogId,
    required this.userId,
    required this.datalogCount,
    required this.datalogTempavg,
    required this.compair,
    required this.datalogTime,
  });

  int datalogId;
  int userId;
  int datalogCount;
  int compair;
  double datalogTempavg;
  DateTime datalogTime;

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        datalogId: json["datalog_id"],
        userId: json["user_id"],
        datalogCount: json["datalog_count"],
        compair: json["compair"],
        datalogTempavg: json["datalog_tempavg"].toDouble(),
        datalogTime: DateTime.parse(json["datalog_time"]),
      );

  Map<String, dynamic> toJson() => {
        "datalog_id": datalogId,
        "user_id": userId,
        "datalog_count": datalogCount,
        "compair": compair,
        "datalog_tempavg": datalogTempavg,
        "datalog_time": datalogTime.toIso8601String(),
      };
}
