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

  static Future<PocketBase> get instance async {
    if (_pocketBase == null) {
      final prefs = await SharedPrefs.instance;

      final store = AsyncAuthStore(
        save: (String data) async => prefs.setString('pb_auth', data),
        initial: prefs.getString('pb_auth'),
      );

      _pocketBase =
          PocketBase('https://connectobia.pockethost.io', authStore: store);

      debugPrint('PocketBase initialized');
    }
    return _pocketBase!;
  }
}
