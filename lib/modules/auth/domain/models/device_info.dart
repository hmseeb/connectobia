import 'dart:convert';

class DeviceInfo {
  final String platform;
  final String model;
  final String systemName;
  final String systemVersion;
  final String identifierForVendor;
  final String publicIp;
  final String country;
  final String city;

  DeviceInfo({
    required this.platform,
    required this.model,
    required this.systemName,
    required this.systemVersion,
    required this.identifierForVendor,
    required this.publicIp,
    required this.country,
    required this.city,
  });

  factory DeviceInfo.fromRawJson(String str) =>
      DeviceInfo.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory DeviceInfo.fromJson(Map<String, dynamic> json) => DeviceInfo(
        platform: json["Platform"],
        model: json["Model"],
        systemName: json["System Name"],
        systemVersion: json["System Version"],
        identifierForVendor: json["Identifier for Vendor"],
        publicIp: json["Public IP"],
        country: json["Country"],
        city: json["City"],
      );

  Map<String, dynamic> toJson() => {
        "Platform": platform,
        "Model": model,
        "System Name": systemName,
        "System Version": systemVersion,
        "Identifier for Vendor": identifierForVendor,
        "Public IP": publicIp,
        "Country": country,
        "City": city,
      };
}
