import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../domain/models/error.dart';

/// A repository to handle errors
///
/// This repository is used to handle errors that occur in the application.
/// It provides a function to map raw errors to user-friendly messages.
///
/// {@category Repositories}
class ErrorRepository {
  /// [handleError] function takes an error and passes it to the appropriate function to handle it
  String handleError(Object originalError) {
    debugPrint('$originalError');
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

  /// A function to map client exceptions to user-friendly messages
  ///
  /// This function maps client exceptions to user-friendly messages based on the status code
  /// and the response message.
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
