// Account type is a singleton class that contains the account types of the users.

import 'package:flutter/material.dart';

class CollectionNameSingleton {
  static String? _collectionName;

  static String get instance {
    if (_collectionName == null) {
      assert(false, 'User not defined');
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
    debugPrint('User is $newCollectionName');
    _collectionName = newCollectionName;
  }
}
