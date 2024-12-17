import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:get_ip_address/get_ip_address.dart';
import 'package:http/http.dart' as http;

class DeviceInfoRepository {
  Future<Map<String, dynamic>> getDeviceDetails() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    Map<String, dynamic> deviceData = {};

    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        deviceData = {
          'Platform': 'Android',
          'Model': androidInfo.model,
          'Manufacturer': androidInfo.manufacturer,
          'Android Version': androidInfo.version.release,
          'Device ID': androidInfo.id,
        };
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        deviceData = {
          'Platform': 'iOS',
          'Model': iosInfo.utsname.machine,
          'System Name': iosInfo.systemName,
          'System Version': iosInfo.systemVersion,
          'Identifier for Vendor': iosInfo.identifierForVendor,
        };
      } else if (Platform.isWindows) {
        WindowsDeviceInfo windowsInfo = await deviceInfo.windowsInfo;
        deviceData = {
          'Platform': 'Windows',
          'Computer Name': windowsInfo.computerName,
          'Number of Cores': windowsInfo.numberOfCores,
          'System Memory': '${windowsInfo.systemMemoryInMegabytes} MB',
        };
      } else if (Platform.isMacOS) {
        MacOsDeviceInfo macInfo = await deviceInfo.macOsInfo;
        deviceData = {
          'Platform': 'macOS',
          'Model': macInfo.model,
          'Kernel Version': macInfo.kernelVersion,
          'OS Release': macInfo.osRelease,
        };
      } else if (Platform.isLinux) {
        LinuxDeviceInfo linuxInfo = await deviceInfo.linuxInfo;
        deviceData = {
          'Platform': 'Linux',
          'Name': linuxInfo.name,
          'Version': linuxInfo.version,
          'ID': linuxInfo.id,
        };
      } else {
        deviceData = {'Platform': 'Unknown'};
      }
    } catch (e) {
      debugPrint('Error fetching device info: $e');
    }

    return deviceData;
  }

  Future<String> getPublicIp() async {
    try {
      var ipAddress = IpAddress(
          type: RequestType.json); // You can change the type if needed
      dynamic data = await ipAddress.getIpAddress();

      if (data is String) {
        // If type is RequestType.text (default)
        return data;
      } else if (data is Map<String, dynamic>) {
        // If type is RequestType.json
        return data['ip'] ?? 'Unavailable';
      } else {
        return 'Unavailable';
      }
    } on IpAddressException catch (e) {
      debugPrint('IpAddressException: $e');
      return 'Unavailable';
    } catch (e) {
      debugPrint('Unexpected error: $e');
      return 'Unavailable';
    }
  }

  Future<String> getCountryFromIp(String ip) async {
    try {
      final response = await http.get(Uri.parse('http://ip-api.com/json/$ip'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          return data['country'] ?? 'Unknown';
        } else {
          return 'Unknown';
        }
      } else {
        throw Exception('Failed to load country');
      }
    } catch (e) {
      debugPrint('Error fetching country: $e');
      return 'Unavailable';
    }
  }

  Future<String> getCityFromIp(String ip) async {
    try {
      final response = await http.get(Uri.parse('http://ip-api.com/json/$ip'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          return data['city'] ?? 'Unknown';
        } else {
          return 'Unknown';
        }
      } else {
        throw Exception('Failed to load city');
      }
    } catch (e) {
      debugPrint('Error fetching city: $e');
      return 'Unavailable';
    }
  }

  Future<String> fetchDeviceInfo() async {
    // Get device details
    Map<String, dynamic> deviceDetails = await getDeviceDetails();

    // Get public IP using get_ip_address package
    String ip = await getPublicIp();

    // Get country from IP
    String country = 'Unavailable';
    String city = 'Unavailable';

    if (ip != 'Unavailable') {
      country = await getCountryFromIp(ip);
      city = await getCityFromIp(ip);
    }

    deviceDetails.addEntries([
      MapEntry('Public IP', ip),
      MapEntry('Country', country),
      MapEntry('City', city),
    ]);

    return jsonEncode(deviceDetails);
  }
}
