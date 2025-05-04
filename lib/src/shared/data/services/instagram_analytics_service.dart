import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class InstagramAnalyticsService {
  static const String _baseUrl =
      'https://instagram-statistics-api.p.rapidapi.com/community';
  static const String _apiHost = 'instagram-statistics-api.p.rapidapi.com';
  static const String _apiKey =
      'bf2365c2d0msh223d8b7ce02a1b2p19d49ejsne41381fa48cb';

  /// Fetches detailed analytics for an Instagram profile
  static Future<Map<String, dynamic>> getProfileAnalytics(
      {required String username}) async {
    try {
      debugPrint('Fetching Instagram analytics for $username');

      final Uri uri = Uri.parse(_baseUrl).replace(
          queryParameters: {'url': 'https://www.instagram.com/$username/'});

      final response = await http.get(
        uri,
        headers: {
          'x-rapidapi-host': _apiHost,
          'x-rapidapi-key': _apiKey,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['meta']['code'] == 200) {
          final profile = data['data'];

          // Extract the required data
          return {
            'avgInteractions': profile['avgInteractions'] ?? 0,
            'avgLikes': profile['avgLikes'] ?? 0,
            'avgComments': profile['avgComments'] ?? 0,
            'avgVideoLikes': profile['avgVideoLikes'] ?? 0,
            'avgVideoComments': profile['avgVideoComments'] ?? 0,
            'avgVideoViews': profile['avgVideoViews'] ?? 0,
            'country': profile['country'] ?? '',
            'gender': profile['gender'] ?? '',
          };
        } else {
          throw Exception('API returned error: ${data['meta']['message']}');
        }
      } else {
        throw Exception(
            'Failed to fetch Instagram analytics: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching Instagram analytics: $e');
      // Return default values in case of an error
      return {
        'avgInteractions': 0,
        'avgLikes': 0,
        'avgComments': 0,
        'avgVideoLikes': 0,
        'avgVideoComments': 0,
        'avgVideoViews': 0,
        'country': '',
        'gender': '',
      };
    }
  }
}
