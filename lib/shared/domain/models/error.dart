import 'dart:convert';

class ErrorModel {
  final Title title;
  final String dynamicKey; // To remember the key name for encoding back to JSON

  ErrorModel({required this.title, required this.dynamicKey});

  factory ErrorModel.fromRawJson(String str) =>
      ErrorModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ErrorModel.fromJson(Map<String, dynamic> json) {
    if (json.isEmpty) {
      throw Exception("JSON is empty");
    }
    String key = json.keys.first; // Fetch the first (and only) key
    return ErrorModel(
      title: Title.fromJson(json[key] as Map<String, dynamic>),
      dynamicKey: key,
    );
  }

  Map<String, dynamic> toJson() => {
        dynamicKey: title.toJson(), // Encode using the stored dynamic key
      };
}

class Title {
  final String code;
  final String message;

  Title({required this.code, required this.message});

  factory Title.fromRawJson(String str) => Title.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Title.fromJson(Map<String, dynamic> json) => Title(
        code: json["code"],
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "code": code,
        "message": message,
      };
}
