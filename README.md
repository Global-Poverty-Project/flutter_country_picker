# Country picker

[![pub package](https://img.shields.io/pub/v/country_picker.svg)](https://pub.dev/packages/country_picker)

A flutter package to select a country from a list of countries. 

<img height="600" alt="n1" src="https://raw.githubusercontent.com/Daniel-Ioannou/flutter_country_picker/master/assets/ReadMe%20Screenshot.png">

## Getting Started

 Add the package to your pubspec.yaml:

 ```yaml
 country_picker: ^2.0.27
 ```
 
 In your dart file, import the library:

 ```Dart
 import 'package:country_picker/country_picker.dart';
 ``` 
  Show country picker using `showCountryPicker`:
```Dart
showCountryPicker(
  context: context,
  showPhoneCode: true, // optional. Shows phone code before the country name.
  onSelect: (Country country) {
    print('Select country: ${country.displayName}');
  },
);
```

### For localization: 
Add the `CountryLocalizations.delegate` in the list of your app delegates.
```Dart
MaterialApp(
      supportedLocales: [
        const Locale('en'),
        const Locale('el'),
        const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'), // Generic Simplified Chinese 'zh_Hans'
        const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'), // Generic traditional Chinese 'zh_Hant'
      ],
      localizationsDelegates: [
        CountryLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: HomePage(),
 );
```

### Parameters:
* `onSelect`: Called when a country is selected. The country picker passes the new value to the callback (required)
* `onClosed`: Called when CountryPicker is dismissed, whether a country is selected or not (optional).
* `showPhoneCode`: Can be used to show phone code before the country name.
* `searchAutofocus` Can be used to initially expand virtual keyboard
* `showSearch` Can be used to show/hide the search bar.
* `showWorldWide` An optional argument for showing "World Wide" option at the beginning of the list
* `favorite` Can be used to show the favorite countries at the top of the list (optional).
* `moveAlongWithKeyboard` Can be used  to move bottomSheet along with keyboard when textfield is focused (optional).
* `countryListTheme`: Can be used to customize the country list's bottom sheet and widgets that lie within it. (optional). 
  ```Dart
  showCountryPicker(
    context: context,
    countryListTheme: CountryListThemeData(
      flagSize: 25,
      backgroundColor: Colors.white,
      textStyle: TextStyle(fontSize: 16, color: Colors.blueGrey),
      bottomSheetHeight: 500, // Optional. Country list modal height
      //Optional. Sets the border radius for the bottomsheet.
        borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20.0),
        topRight: Radius.circular(20.0),
      ),
      //Optional. Styles the search field.
      inputDecoration: InputDecoration(
        labelText: 'Search',
        hintText: 'Start typing to search',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderSide: BorderSide(
            color: const Color(0xFF8C98A8).withOpacity(0.2),
          ),
        ),
      ),
    ),
    onSelect: (Country country) => print('Select country: ${country.displayName}'),
  );
  ```
* `exclude`: Can be used to exclude(remove) one or more country from the countries list (optional). 
  ```Dart
  showCountryPicker(
    context: context,
    exclude: <String>['KN', 'MF'], //It takes a list of country code(iso2).
    onSelect: (Country country) => print('Select country: ${country.displayName}'),
  );
  ```
* `countryFilter`: Can be used to filter the countries list (optional). 
  - It takes a list of country code(iso2). 
  - Can't provide both exclude and countryFilter


### Custom builders
`CountryListView` is exported, so an app can host the list in its own bottom sheet or page and draw it with its own widgets, while the package keeps the search (localized names, aliases, diacritics), favorites and filtering. Every builder is optional; without them the list renders as in `showCountryPicker`.

* `searchBuilder`: builds the search field. Bind the given `controller` and call `onChanged` on every edit.
* `itemBuilder`: builds a row. `selected` is true for `initialCountryCode`; `onSelect` runs the default tap (calls `onSelect` and pops the route).
* `emptyBuilder`: shown in place of the list when no country matches.
* `separatorBuilder`: the widget between two rows.
* `listPadding`: the padding of the list.
* `initialCountryCode`: the country (iso2) the list opens on, centered.

`matchPhoneCode` (on `CountryListView` and `showCountryPicker`, default `false`) makes a search of digits, with or without a leading "+", also find the countries whose phone code starts with them: "44" or "+44" finds the United Kingdom.

```Dart
showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  builder: (context) => SizedBox(
    height: 600,
    child: CountryListView(
      onSelect: (country) => print(country.name),
      initialCountryCode: 'GB',
      matchPhoneCode: true,
      searchBuilder: (context, controller, onChanged) => TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: const InputDecoration(hintText: 'Search'),
      ),
      itemBuilder: (context, country, selected, onSelect) => ListTile(
        leading: Text(country.flagEmoji),
        title: Text(country.name),
        trailing: selected ? const Icon(Icons.check) : null,
        onTap: onSelect,
      ),
      separatorBuilder: (context, index) => const Divider(height: 1),
      emptyBuilder: (context) => const Center(child: Text('No results')),
    ),
  ),
);
```

## Contributions
Contributions of any kind are more than welcome! Feel free to fork and improve country_code_picker in any way you want, make a pull request, or open an issue.
