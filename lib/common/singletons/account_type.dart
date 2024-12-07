// Account type is a singleton class that contains the account types of the users.

import 'package:flutter/material.dart';

class CollectionNameSingleton {
  static String? _collectionName;

  static String get instance {
    if (_collectionName == null) {
      // FIXME: This is a temporary fix.
      assert(false, 'User not logged in');
      // final pb = await PocketBaseSingleton.instance;
      // final id = pb.authStore.record!.id;
      // CollectionModel collectionModel = await pb.collections.getOne(id);
      // _collectionName = collectionModel.name;
      // debugPrint('User account type initialized');
    }
    return _collectionName!;
  }

  // Setter to manually set the collection name
  static set instance(String? newCollectionName) {
    debugPrint('User account type initialized');
    _collectionName = newCollectionName;
  }
}
