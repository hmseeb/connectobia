import 'package:intl/intl.dart';

int calculateAge(String birthDate) {
  // Define the date format
  DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");

  // Parse the birth date string into a DateTime object
  DateTime birthDateTime = dateFormat.parse(birthDate);

  // Get the current date and time
  DateTime currentDate = DateTime.now();

  // Calculate the age
  int age = currentDate.year - birthDateTime.year;

  // Adjust the age if the birthday hasn't occurred yet this year
  if (currentDate.month < birthDateTime.month ||
      (currentDate.month == birthDateTime.month &&
          currentDate.day < birthDateTime.day)) {
    age--;
  }

  return age;
}
