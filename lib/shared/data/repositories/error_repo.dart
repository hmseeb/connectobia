import 'package:pocketbase/pocketbase.dart';

class ErrorRepository {
  // A function to map raw errors to user-friendly messages
  String handleError(Object e) {
    if (e is ClientException) {
      return _mapClientError(e);
    }

    return 'Something went wrong. Please try again.';
  }

  // Function to map ClientException to user-friendly message
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
        return e.response['message'] ??
            'Something went wrong. Please try again.';
      }
    } catch (error) {
      // In case the structure is different or something goes wrong, fallback to default message
    }
    return 'Human Error is inevitable, but this is unacceptable. We\'ll look into the matter now.';
  }
}
