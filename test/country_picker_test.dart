import 'package:country_picker/country_picker.dart';
import 'package:country_picker/src/res/strings/ar.dart';
import 'package:country_picker/src/res/strings/bg.dart';
import 'package:country_picker/src/res/strings/ca.dart';
import 'package:country_picker/src/res/strings/cn.dart';
import 'package:country_picker/src/res/strings/cs.dart';
import 'package:country_picker/src/res/strings/da.dart';
import 'package:country_picker/src/res/strings/de.dart';
import 'package:country_picker/src/res/strings/en.dart';
import 'package:country_picker/src/res/strings/es.dart';
import 'package:country_picker/src/res/strings/et.dart';
import 'package:country_picker/src/res/strings/fa.dart';
import 'package:country_picker/src/res/strings/fr.dart';
import 'package:country_picker/src/res/strings/gr.dart';
import 'package:country_picker/src/res/strings/he.dart';
import 'package:country_picker/src/res/strings/hr.dart';
import 'package:country_picker/src/res/strings/ht.dart';
import 'package:country_picker/src/res/strings/id.dart';
import 'package:country_picker/src/res/strings/it.dart';
import 'package:country_picker/src/res/strings/ja.dart';
import 'package:country_picker/src/res/strings/ko.dart';
import 'package:country_picker/src/res/strings/ku.dart';
import 'package:country_picker/src/res/strings/lt.dart';
import 'package:country_picker/src/res/strings/lv.dart';
import 'package:country_picker/src/res/strings/nb.dart';
import 'package:country_picker/src/res/strings/nl.dart';
import 'package:country_picker/src/res/strings/nn.dart';
import 'package:country_picker/src/res/strings/np.dart';
import 'package:country_picker/src/res/strings/pl.dart';
import 'package:country_picker/src/res/strings/pt.dart';
import 'package:country_picker/src/res/strings/ro.dart';
import 'package:country_picker/src/res/strings/ru.dart';
import 'package:country_picker/src/res/strings/sk.dart';
import 'package:country_picker/src/res/strings/tr.dart';
import 'package:country_picker/src/res/strings/tw.dart';
import 'package:country_picker/src/res/strings/uk.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Türkiye', () {
    final english = CountryLocalizations(const Locale('en'));
    final turkiye = CountryParser.parseCountryCode('TR');

    test('uses its official name in English', () {
      expect(turkiye.name, 'Türkiye');
      expect(turkiye.displayName, 'Türkiye (TR) [+90]');
      expect(turkiye.displayNameNoCountryCode, 'Türkiye (TR)');
      expect(english.countryName(countryCode: 'TR'), 'Türkiye');
    });

    test('uses its official name in Hindi and Nepali', () {
      for (final languageCode in ['hi', 'ne']) {
        expect(
          CountryLocalizations(Locale(languageCode))
              .countryName(countryCode: 'TR'),
          'तुर्किये',
        );
      }
    });

    test('is found when searching by its current or former name', () {
      expect(turkiye.startsWith('turkiye', english), isTrue);
      expect(turkiye.startsWith('Türk', english), isTrue);
      expect(turkiye.startsWith('turkey', english), isTrue);
    });

    test('former name only matches Türkiye', () {
      final matches = CountryService()
          .getAll()
          .where((country) => country.startsWith('turkey', english))
          .map((country) => country.countryCode);

      expect(matches, ['TR']);
    });
  });

  test('no locale maps two country codes to the same name', () {
    final locales = <String, Map<String, String>>{
      'ar': ar, 'bg': bg, 'ca': ca, 'cn': cn, 'cs': cs, 'da': da, 'de': de,
      'en': en, 'es': es, 'et': et, 'fa': fa, 'fr': fr, 'gr': gr, 'he': he,
      'hr': hr, 'ht': ht, 'id': id, 'it': it, 'ja': ja, 'ko': ko, 'ku': ku,
      'lt': lt, 'lv': lv, 'nb': nb, 'nl': nl, 'nn': nn, 'np': np, 'pl': pl,
      'pt': pt, 'ro': ro, 'ru': ru, 'sk': sk, 'tr': tr, 'tw': tw, 'uk': uk,
    };

    locales.forEach((locale, names) {
      final codesByName = <String, List<String>>{};
      names.forEach((code, name) {
        if (code.length == 2) codesByName.putIfAbsent(name, () => []).add(code);
      });
      codesByName.removeWhere((_, codes) => codes.length < 2);

      expect(codesByName, isEmpty, reason: 'locale "$locale"');
    });
  });
}
