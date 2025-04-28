import 'package:flutter/foundation.dart';

import '../../../services/storage/pb.dart';
import '../../../shared/data/repositories/error_repo.dart';
import '../../../shared/data/repositories/notification_repository.dart';
import '../../../shared/domain/models/funds.dart';

class FundsRepository {
  static const String _collectionName = 'funds';

  /// Add funds to a user's account
  static Future<Funds> addFunds(String userId, double amount) async {
    try {
      if (amount <= 0) {
        throw Exception('Amount must be greater than zero');
      }

      final pb = await PocketBaseSingleton.instance;

      // Fetch current funds record
      final resultList = await pb.collection(_collectionName).getList(
            page: 1,
            perPage: 1,
            filter: 'user = "$userId"',
          );

      Funds funds;
      if (resultList.items.isEmpty) {
        // Create new funds record if none exists
        final record = await pb.collection(_collectionName).create(body: {
          'user': userId,
          'balance': amount,
          'locked': 0,
        });

        funds = Funds.fromRecord(record);
      } else {
        // Update existing record
        final existing = Funds.fromRecord(resultList.items.first);
        final newBalance = existing.balance + amount;

        final record = await pb.collection(_collectionName).update(
          existing.id,
          body: {
            'balance': newBalance,
          },
        );

        funds = Funds.fromRecord(record);
      }

      // Send a payment notification
      try {
        await NotificationRepository.createPaymentNotification(
          userId: userId,
          title: 'Funds Added',
          body:
              'Your account has been credited with \$${amount.toStringAsFixed(2)}. New balance: \$${funds.balance.toStringAsFixed(2)}',
          redirectUrl: '/wallet',
        );
      } catch (e) {
        debugPrint('Error creating funds notification: $e');
      }

      return funds;
    } catch (e) {
      debugPrint('Error in addFunds: $e');
      ErrorRepository errorRepo = ErrorRepository();
      throw errorRepo.handleError(e);
    }
  }

  /// Get funds for a user, creating a new record if none exists
  static Future<Funds> getFundsForUser(String userId) async {
    try {
      final pb = await PocketBaseSingleton.instance;

      try {
        // Try to fetch existing funds
        final resultList = await pb.collection(_collectionName).getList(
              page: 1,
              perPage: 1,
              filter: 'user = "$userId"',
            );

        if (resultList.items.isNotEmpty) {
          return Funds.fromRecord(resultList.items.first);
        }

        // If no funds found, create a new record
        final record = await pb.collection(_collectionName).create(body: {
          'user': userId,
          'balance': 0,
          'locked': 0,
        });

        return Funds.fromRecord(record);
      } catch (e) {
        debugPrint('Error fetching funds: $e');
        rethrow;
      }
    } catch (e) {
      debugPrint('Error in getFundsForUser: $e');
      ErrorRepository errorRepo = ErrorRepository();
      throw errorRepo.handleError(e);
    }
  }

  /// Lock funds for a campaign
  static Future<bool> lockFunds(String userId, double amount) async {
    try {
      if (amount <= 0) {
        throw Exception('Amount must be greater than zero');
      }

      final pb = await PocketBaseSingleton.instance;

      // Fetch current funds record
      final resultList = await pb.collection(_collectionName).getList(
            page: 1,
            perPage: 1,
            filter: 'user = "$userId"',
          );

      if (resultList.items.isEmpty) {
        throw Exception('No funds record found for user');
      }

      final existing = Funds.fromRecord(resultList.items.first);

      // Check if sufficient balance is available
      if (existing.availableBalance < amount) {
        return false;
      }

      // Update locked funds
      final newLocked = existing.locked + amount;
      await pb.collection(_collectionName).update(
        existing.id,
        body: {
          'locked': newLocked,
        },
      );

      // Send a payment notification
      try {
        await NotificationRepository.createPaymentNotification(
          userId: userId,
          title: 'Funds Locked',
          body:
              'Your account has locked \$${amount.toStringAsFixed(2)} for a campaign. Available balance: \$${(existing.balance - newLocked).toStringAsFixed(2)}',
          redirectUrl: '/wallet',
        );
      } catch (e) {
        debugPrint('Error creating funds lock notification: $e');
      }

      return true;
    } catch (e) {
      debugPrint('Error in lockFunds: $e');
      ErrorRepository errorRepo = ErrorRepository();
      throw errorRepo.handleError(e);
    }
  }

  /// Release locked funds
  static Future<bool> releaseFunds(String userId, double amount) async {
    try {
      if (amount <= 0) {
        throw Exception('Amount must be greater than zero');
      }

      final pb = await PocketBaseSingleton.instance;

      // Fetch current funds record
      final resultList = await pb.collection(_collectionName).getList(
            page: 1,
            perPage: 1,
            filter: 'user = "$userId"',
          );

      if (resultList.items.isEmpty) {
        throw Exception('No funds record found for user');
      }

      final existing = Funds.fromRecord(resultList.items.first);

      // Ensure we don't release more than what's locked
      final releaseAmount = amount > existing.locked ? existing.locked : amount;
      final newLocked = existing.locked - releaseAmount;

      await pb.collection(_collectionName).update(
        existing.id,
        body: {
          'locked': newLocked,
        },
      );

      // Send a payment notification
      try {
        await NotificationRepository.createPaymentNotification(
          userId: userId,
          title: 'Funds Released',
          body:
              'Your locked funds of \$${releaseAmount.toStringAsFixed(2)} have been released. Available balance: \$${(existing.balance - newLocked).toStringAsFixed(2)}',
          redirectUrl: '/wallet',
        );
      } catch (e) {
        debugPrint('Error creating funds release notification: $e');
      }

      return true;
    } catch (e) {
      debugPrint('Error in releaseFunds: $e');
      ErrorRepository errorRepo = ErrorRepository();
      throw errorRepo.handleError(e);
    }
  }

  /// Transfer funds (reduce balance) for completed contracts
  static Future<bool> transferFunds(String userId, double amount) async {
    try {
      if (amount <= 0) {
        throw Exception('Amount must be greater than zero');
      }

      final pb = await PocketBaseSingleton.instance;

      // Fetch current funds record
      final resultList = await pb.collection(_collectionName).getList(
            page: 1,
            perPage: 1,
            filter: 'user = "$userId"',
          );

      if (resultList.items.isEmpty) {
        throw Exception('No funds record found for user');
      }

      final existing = Funds.fromRecord(resultList.items.first);

      // Ensure we have sufficient locked funds
      if (existing.locked < amount) {
        return false;
      }

      // Update balance and locked amounts
      final newBalance = existing.balance - amount;
      final newLocked = existing.locked - amount;

      await pb.collection(_collectionName).update(
        existing.id,
        body: {
          'balance': newBalance,
          'locked': newLocked,
        },
      );

      // Send a payment notification
      try {
        await NotificationRepository.createPaymentNotification(
          userId: userId,
          title: 'Payment Sent',
          body:
              'You have sent a payment of \$${amount.toStringAsFixed(2)}. New balance: \$${newBalance.toStringAsFixed(2)}',
          redirectUrl: '/wallet',
        );
      } catch (e) {
        debugPrint('Error creating payment sent notification: $e');
      }

      return true;
    } catch (e) {
      debugPrint('Error in transferFunds: $e');
      ErrorRepository errorRepo = ErrorRepository();
      throw errorRepo.handleError(e);
    }
  }
}
