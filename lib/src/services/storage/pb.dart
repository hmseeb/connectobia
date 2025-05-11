import 'package:flutter/foundation.dart';
import 'package:pocketbase/pocketbase.dart';

import 'shared_prefs.dart';

/// Singleton class to manage the PocketBase instance
///
/// This class is used to create a single instance of the PocketBase class
/// that can be used throughout the application.
///
/// {@category Database}
class PocketBaseSingleton {
  static PocketBase? _pocketBase;
  static bool _isInitializing = false;
  static Object? _lastError;
  static String? _lastAuthToken;

  static Future<PocketBase> get instance async {
    if (_pocketBase == null) {
      // If we're already trying to initialize, wait until it's done
      if (_isInitializing) {
        // Wait a bit and check again
        await Future.delayed(Duration(milliseconds: 100));
        return instance;
      }

      _isInitializing = true;
      _lastError = null;

      try {
        final prefs = await SharedPrefs.instance;

        final store = AsyncAuthStore(
          save: (String data) async {
            debugPrint('Saving auth data');
            // Check if the token has changed
            if (data != _lastAuthToken) {
              debugPrint(
                  'Auth token changed, unsubscribing all realtime connections');
              if (_pocketBase != null) {
                await unsubscribeAll();
              }
              _lastAuthToken = data;
            }
            await prefs.setString('pb_auth', data);
          },
          initial: prefs.getString('pb_auth'),
        );

        _pocketBase =
            PocketBase('https://connectobia.pockethost.io', authStore: store);

        // Initialize _lastAuthToken
        _lastAuthToken = store.token;

        // Listen for auth token changes from external sources
        _pocketBase!.authStore.onChange.listen((AuthStoreEvent event) {
          if (event.token != _lastAuthToken) {
            debugPrint(
                'Auth token changed externally, unsubscribing all realtime connections');
            unsubscribeAll();
            _lastAuthToken = event.token;
          }
        });

        // Test the connection to ensure it's working
        try {
          await _pocketBase!.health.check();
          debugPrint(
              'PocketBase initialized and connection tested successfully');
        } catch (e) {
          debugPrint('PocketBase connection test failed: $e');
          // We still continue as the connection might work later
        }
      } catch (e) {
        _lastError = e;
        debugPrint('Error initializing PocketBase: $e');
        // Create a fallback instance without trying to load from storage
        _pocketBase = PocketBase('https://connectobia.pockethost.io');
      } finally {
        _isInitializing = false;
      }
    }

    if (_pocketBase == null) {
      throw Exception('Failed to initialize PocketBase: $_lastError');
    }

    return _pocketBase!;
  }

  /// Clear the authentication state and reset the singleton
  static Future<void> reset() async {
    if (_pocketBase != null) {
      await unsubscribeAll();
      _pocketBase!.authStore.clear();
      _pocketBase = null;
      _lastAuthToken = null;
      debugPrint('PocketBase singleton reset');
    }
  }

  /// Unsubscribe from all realtime connections
  static Future<void> unsubscribeAll() async {
    if (_pocketBase != null) {
      try {
        debugPrint('Unsubscribing from all realtime connections');
        await _pocketBase!.realtime.unsubscribe();

        // Also unsubscribe from specific collections we know about
        _pocketBase!.collection('messages').unsubscribe();
        _pocketBase!.collection('chats').unsubscribe();
        _pocketBase!.collection('notifications').unsubscribe();

        debugPrint('Successfully unsubscribed from all realtime connections');
      } catch (e) {
        debugPrint('Error unsubscribing from realtime connections: $e');
      }
    }
  }
}
