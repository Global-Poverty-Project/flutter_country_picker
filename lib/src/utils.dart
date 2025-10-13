import 'package:diacritic/diacritic.dart';

class Utils {
  static String countryCodeToEmoji(String countryCode) {
    // 0x41 is Letter A
    // 0x1F1E6 is Regional Indicator Symbol Letter A
    // Example :
    // firstLetter U => 20 + 0x1F1E6
    // secondLetter S => 18 + 0x1F1E6
    // See: https://en.wikipedia.org/wiki/Regional_Indicator_Symbol
    final int firstLetter = countryCode.codeUnitAt(0) - 0x41 + 0x1F1E6;
    final int secondLetter = countryCode.codeUnitAt(1) - 0x41 + 0x1F1E6;
    return String.fromCharCode(firstLetter) + String.fromCharCode(secondLetter);
  }

  /// Normalizes text by converting special characters to their base forms.
  /// This allows searching for countries with special characters using regular characters.
  /// 
  /// Examples:
  /// - "Åland Islands" becomes "Aland Islands"
  /// - "São Tomé" becomes "Sao Tome"
  /// - "Côte d'Ivoire" becomes "Cote d'Ivoire"
  static String normalizeText(String text) {
    return removeDiacritics(text);
  }
}
