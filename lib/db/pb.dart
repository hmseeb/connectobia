import 'package:pocketbase/pocketbase.dart';

import 'shared_prefs.dart';

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
          PocketBase('https://connectobi.pockethost.io', authStore: store);
    }
    return _pocketBase!;
  }
}
