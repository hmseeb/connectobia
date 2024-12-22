// Account type is a singleton class that contains the account types of the users.

import 'package:flutter/material.dart';

/// Singleton class that contains the account types of the current user.
///
class CollectionNameSingleton {
  static String? _collectionName;

  static String get instance {
    if (_collectionName == null) {
      assert(false, 'User not defined');
    }
    return _collectionName!;
  }

  /// Setter to manually set the collection name
  static set instance(String? newCollectionName) {
    debugPrint('User is $newCollectionName');
    _collectionName = newCollectionName;
  }
}
