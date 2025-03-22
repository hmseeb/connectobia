import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:pocketbase/pocketbase.dart';

class Funds {
  final String collectionId;
  final String collectionName;
  final String id;
  final String user;
  final double balance;
  final double locked;
  final DateTime created;
  final DateTime updated;

  Funds({
    required this.collectionId,
    required this.collectionName,
    required this.id,
    required this.user,
    required this.balance,
    required this.locked,
    required this.created,
    required this.updated,
  });

  factory Funds.fromJson(Map<String, dynamic> json) {
    try {
      return Funds(
        collectionId: json['collectionId'] ?? '',
        collectionName: json['collectionName'] ?? '',
        id: json['id'] ?? '',
        user: json['user'] ?? '',
        balance: _parseAmount(json['balance']),
        locked: _parseAmount(json['locked']),
        created: _parseDateTime(json['created']),
        updated: _parseDateTime(json['updated']),
      );
    } catch (e) {
      debugPrint('Error parsing Funds from JSON: $e');
      rethrow;
    }
  }

  factory Funds.fromRawJson(String str) => Funds.fromJson(json.decode(str));

  factory Funds.fromRecord(RecordModel record) {
    try {
      return Funds(
        collectionId: record.collectionId,
        collectionName: record.collectionName,
        id: record.id,
        user: record.data['user'] ?? '',
        balance: _parseAmount(record.data['balance']),
        locked: _parseAmount(record.data['locked']),
        created: _parseDateTime(record.created),
        updated: _parseDateTime(record.updated),
      );
    } catch (e) {
      debugPrint('Error parsing Funds from Record: $e');
      debugPrint('Record data: ${record.data}');
      rethrow;
    }
  }

  // Helper method to get available balance (total - locked)
  double get availableBalance => balance - locked;

  Map<String, dynamic> toJson() {
    return {
      'collectionId': collectionId,
      'collectionName': collectionName,
      'id': id,
      'user': user,
      'balance': balance,
      'locked': locked,
      'created': created.toIso8601String(),
      'updated': updated.toIso8601String(),
    };
  }

  String toRawJson() => json.encode(toJson());

  // Helper method to safely parse amounts
  static double _parseAmount(dynamic amount) {
    if (amount == null) return 0.0;
    if (amount is int) return amount.toDouble();
    if (amount is double) return amount;
    if (amount is String) {
      try {
        return double.parse(amount);
      } catch (_) {
        return 0.0;
      }
    }
    return 0.0;
  }

  // Helper method to safely parse DateTime values
  static DateTime _parseDateTime(dynamic dateValue) {
    if (dateValue == null) {
      return DateTime.now();
    }

    if (dateValue is DateTime) {
      return dateValue;
    }

    if (dateValue is String) {
      try {
        // Try standard ISO format
        return DateTime.parse(dateValue);
      } catch (_) {
        // Try alternative formats
        try {
          // Try format with space instead of T
          final fixedDate = dateValue.replaceAll(' ', 'T');
          return DateTime.parse(fixedDate);
        } catch (_) {
          return DateTime.now();
        }
      }
    }

    return DateTime.now();
  }
}
