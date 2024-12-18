import 'dart:convert';

import 'package:connectobia/shared/domain/models/error.dart';
import 'package:flutter/foundation.dart';
import 'package:pocketbase/pocketbase.dart';

class ErrorRepository {
  // A function to map raw errors to user-friendly messages
  String handleError(Object originalError) {
    if (originalError is ClientException) {
      try {
        String errorRawJson = jsonEncode(originalError.response['data']);
        ErrorModel errorModel = ErrorModel.fromRawJson(errorRawJson);
        return errorModel.title.message;
      } catch (e) {
        return _mapClientError(originalError);
      }
    } else {
      return originalError.toString();
    }
  }

  String _mapClientError(ClientException e) {
    // Extract the message from the response (assuming the response contains the message field)
    try {
      // If the error contains a message in the response, we return it directly
      if (e.response.containsKey('message')) {
        if (e.response['message'].contains('Failed to authenticate')) {
          return 'Invalid credentials.';
        }
        if (e.statusCode == 400) {
          return e.response['message'];
        }
        if (e.statusCode == 401) {
          return 'Your session has expired. Please login again.';
        } else if (e.statusCode == 403) {
          return 'You do not have permission to perform this action.';
        } else if (e.statusCode == 404) {
          return 'The requested resource was not found.';
        }
      }
    } catch (error) {
      debugPrint('$error');
    }
    return 'Something went wrong. Please try again.';
  }
}
