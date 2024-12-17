/// This file contains the list of industries that are available for selection in the app.
///
/// The list is used in the sign-up process to allow users to select the industry they belong to.
///
/// {@category Constants}
library;

class IndustryFormatter {
  static String keyToValue(String industry) {
    return industry.split('_').map((word) {
      if (word.toLowerCase() == 'and') {
        return word;
      }
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }
}

class IndustryList {
  static const industries = {
    'fashion': 'Fashion',
    'beauty_and_cosmetics': 'Beauty and Cosmetics',
    'fitness': 'Fitness',
    'travel': 'Travel',
    'food': 'Food',
    'lifestyle': 'Lifestyle',
    'tech': 'Tech',
    'parenting': 'Parenting',
    'finance': 'Finance',
    'health_and_wellness': 'Health and Wellness',
    'home_and_garden': 'Home and Garden',
    'pets': 'Pets',
  };
}
