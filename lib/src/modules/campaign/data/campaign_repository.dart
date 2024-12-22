import 'package:connectobia/src/shared/domain/models/campaign.dart';

class CampaignRepository {
  static Future<List<Campaign>> getCampaigns() async {
    await Future.delayed(const Duration(seconds: 1));

    return [
      Campaign(
        collectionId: '1',
        collectionName: 'campaigns',
        id: '1',
        title: 'Luxury Spa Retreat in Bali',
        description:
            'Unwind and rejuvenate at a luxury spa retreat in the heart of Bali.',
        rating: 4.7,
        distance: '5.7 km',
        price: '\$24',
        created: DateTime.now(),
        updated: DateTime.now(),
      ),
      Campaign(
        collectionId: '2',
        collectionName: 'campaigns',
        id: '2',
        title: 'Cultural Tour in Rome',
        description:
            'Discover the rich history of Rome through a unique cultural tour.',
        rating: 4.8,
        distance: '10 km',
        price: '\$30',
        created: DateTime.now(),
        updated: DateTime.now(),
      ),
    ];
  }
}
