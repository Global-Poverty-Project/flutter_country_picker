import 'package:flutter/material.dart';

import 'country.dart';
import 'country_list_theme_data.dart';
import 'country_localizations.dart';
import 'country_service.dart';
import 'res/country_codes.dart';
import 'utils.dart';

typedef CustomFlagBuilder = Widget Function(Country country);

/// Builds the search field in place of the default [TextField].
///
/// Bind [controller] to the field and call [onChanged] with every edit, so
/// the list keeps the package's search (localized names, aliases,
/// diacritics).
typedef CountrySearchBuilder = Widget Function(
  BuildContext context,
  TextEditingController controller,
  ValueChanged<String> onChanged,
);

/// Builds a country row in place of the default one.
///
/// [selected] is true for the row of [CountryListView.initialCountryCode].
/// [onSelect] runs the default tap: it sets [Country.nameLocalized], calls
/// [CountryListView.onSelect] and pops the route.
typedef CountryItemBuilder = Widget Function(
  BuildContext context,
  Country country,
  bool selected,
  VoidCallback onSelect,
);

class CountryListView extends StatefulWidget {
  /// Called when a country is select.
  ///
  /// The country picker passes the new value to the callback.
  final ValueChanged<Country> onSelect;

  /// An optional [showPhoneCode] argument can be used to show phone code.
  final bool showPhoneCode;

  /// An optional [exclude] argument can be used to exclude(remove) one ore more
  /// country from the countries list. It takes a list of country code(iso2).
  /// Note: Can't provide both [exclude] and [countryFilter]
  final List<String>? exclude;

  /// An optional [countryFilter] argument can be used to filter the
  /// list of countries. It takes a list of country code(iso2).
  /// Note: Can't provide both [countryFilter] and [exclude]
  final List<String>? countryFilter;

  /// An optional [favorite] argument can be used to show countries
  /// at the top of the list. It takes a list of country code(iso2).
  final List<String>? favorite;

  /// An optional argument for customizing the
  /// country list bottom sheet.
  final CountryListThemeData? countryListTheme;

  /// An optional argument for initially expanding virtual keyboard
  final bool searchAutofocus;

  /// An optional argument for showing "World Wide" option at the beginning of the list
  final bool showWorldWide;

  /// An optional argument for hiding the search bar
  final bool showSearch;

  /// Custom builder function for flag widget
  final CustomFlagBuilder? customFlagBuilder;

  /// An optional argument to allow partial name search
  final bool allowPartialNameSearch;

  /// Builds the search field in place of the default one. It takes the place
  /// of the default [TextField] only, so [showSearch] still hides it.
  final CountrySearchBuilder? searchBuilder;

  /// Builds each country row in place of the default one.
  final CountryItemBuilder? itemBuilder;

  /// Builds the widget shown in place of the list when no country matches.
  final WidgetBuilder? emptyBuilder;

  /// Builds the widget between two country rows. [index] is the row above it.
  final IndexedWidgetBuilder? separatorBuilder;

  /// The padding of the list.
  final EdgeInsetsGeometry? listPadding;

  /// The country code (iso2) the list opens on, centered, and that
  /// [itemBuilder] receives as selected.
  final String? initialCountryCode;

  const CountryListView({
    Key? key,
    required this.onSelect,
    this.exclude,
    this.favorite,
    this.countryFilter,
    this.showPhoneCode = false,
    this.countryListTheme,
    this.searchAutofocus = false,
    this.showWorldWide = false,
    this.showSearch = true,
    this.allowPartialNameSearch = true,
    this.customFlagBuilder,
    this.searchBuilder,
    this.itemBuilder,
    this.emptyBuilder,
    this.separatorBuilder,
    this.listPadding,
    this.initialCountryCode,
  })  : assert(
          exclude == null || countryFilter == null,
          'Cannot provide both exclude and countryFilter',
        ),
        super(key: key);

  @override
  State<CountryListView> createState() => _CountryListViewState();
}

class _CountryListViewState extends State<CountryListView> {
  final CountryService _countryService = CountryService();

  late List<Country> _countryList;
  late List<Country> _filteredList;
  List<Country>? _favoriteList;
  late TextEditingController _searchController;
  late bool _searchAutofocus;
  bool _isSearching = false;
  ScrollController? _scrollController;
  final GlobalKey _initialRowKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();

    _countryList = _countryService.getAll();

    _countryList =
        countryCodes.map((country) => Country.from(json: country)).toList();

    //Remove duplicates country if not use phone code
    if (!widget.showPhoneCode) {
      final ids = _countryList.map((e) => e.countryCode).toSet();
      _countryList.retainWhere((country) => ids.remove(country.countryCode));
    }

    if (widget.favorite != null) {
      _favoriteList = _countryService.findCountriesByCode(widget.favorite!);
    }

    if (widget.exclude != null) {
      _countryList.removeWhere(
        (element) => widget.exclude!.contains(element.countryCode),
      );
    }

    if (widget.countryFilter != null) {
      _countryList.removeWhere(
        (element) => !widget.countryFilter!.contains(element.countryCode),
      );
    }

    _filteredList = <Country>[];
    if (widget.showWorldWide) {
      _filteredList.add(Country.worldWide);
    }
    _filteredList.addAll(_countryList);

    _searchAutofocus = widget.searchAutofocus;

    if (widget.initialCountryCode != null) {
      _scrollController = ScrollController();
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _scrollToInitialCountry());
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController?.dispose();
    super.dispose();
  }

  /// The list builds its rows lazily, so a row far down does not exist yet:
  /// jump to its estimated offset first, then center it once it is built.
  void _scrollToInitialCountry([int attempt = 0]) {
    final controller = _scrollController;
    if (!mounted || controller == null || !controller.hasClients) return;

    final rowContext = _initialRowKey.currentContext;
    if (rowContext != null) {
      Scrollable.ensureVisible(rowContext, alignment: 0.5);
      return;
    }

    final index = _filteredList
        .indexWhere((c) => c.countryCode == widget.initialCountryCode);
    if (index < 0 || attempt >= 3) return;

    final position = controller.position;
    final rowCount = _filteredList.length + (_favoriteList?.length ?? 0);
    final contentExtent = position.maxScrollExtent + position.viewportDimension;
    final rowIndex = index + (_favoriteList?.length ?? 0);
    controller.jumpTo(
      (contentExtent * rowIndex / rowCount).clamp(
        position.minScrollExtent,
        position.maxScrollExtent,
      ),
    );
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _scrollToInitialCountry(attempt + 1));
  }

  void _onSearchChanged(String value) {
    _filterSearchResults(value, widget.allowPartialNameSearch);
    _checkSearchText(value);
  }

  void _selectCountry(Country country) {
    country.nameLocalized = CountryLocalizations.of(context)
        ?.countryName(countryCode: country.countryCode)
        ?.replaceAll(RegExp(r"\s+"), " ");
    widget.onSelect(country);
    Navigator.pop(context);
  }

  void _checkSearchText(String searchText) {
    if (searchText.isNotEmpty) {
      setState(() {
        _isSearching = true;
      });
    } else {
      setState(() {
        _isSearching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String searchLabel =
        CountryLocalizations.of(context)?.countryName(countryCode: 'search') ??
            'Search';

    return Column(
      children: <Widget>[
        const SizedBox(height: 12),
        if (widget.showSearch && widget.searchBuilder != null)
          widget.searchBuilder!(context, _searchController, _onSearchChanged)
        else if (widget.showSearch)
          TextField(
            autofocus: _searchAutofocus,
            controller: _searchController,
            style:
                widget.countryListTheme?.searchTextStyle ?? _defaultTextStyle,
            decoration: widget.countryListTheme?.inputDecoration ??
                InputDecoration(
                  labelText: searchLabel,
                  hintText: searchLabel,
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: const Color(0xFF8C98A8).withValues(alpha: 0.2),
                    ),
                  ),
                ),
            onChanged: _onSearchChanged,
          ),
        Expanded(
          child: widget.emptyBuilder != null && _showsNoCountry
              ? widget.emptyBuilder!(context)
              : ListView(
                  controller: _scrollController,
                  padding: widget.listPadding,
                  children: [
                    if (_favoriteList != null && !_isSearching) ...[
                      ..._rows(_favoriteList!),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.0),
                        child: Divider(thickness: 1),
                      ),
                    ],
                    ..._rows(_filteredList, keyInitialCountry: true),
                  ],
                ),
        ),
      ],
    );
  }

  bool get _showsNoCountry =>
      _filteredList.isEmpty && (_favoriteList == null || _isSearching);

  Iterable<Widget> _rows(
    List<Country> countries, {
    bool keyInitialCountry = false,
  }) sync* {
    final separatorBuilder = widget.separatorBuilder;
    for (var i = 0; i < countries.length; i++) {
      if (separatorBuilder != null && i > 0) {
        yield separatorBuilder(context, i - 1);
      }
      final country = countries[i];
      final row = widget.itemBuilder == null
          ? _listRow(country)
          : widget.itemBuilder!(
              context,
              country,
              country.countryCode == widget.initialCountryCode,
              () => _selectCountry(country),
            );
      yield keyInitialCountry &&
              country.countryCode == widget.initialCountryCode
          ? KeyedSubtree(key: _initialRowKey, child: row)
          : row;
    }
  }

  Widget _listRow(Country country) {
    final TextStyle _textStyle =
        widget.countryListTheme?.textStyle ?? _defaultTextStyle;

    final bool isRtl = Directionality.of(context) == TextDirection.rtl;

    return Material(
      // Add Material Widget with transparent color
      // so the ripple effect of InkWell will show on tap
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _selectCountry(country),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: Row(
            children: <Widget>[
              Row(
                children: [
                  const SizedBox(width: 20),
                  if (widget.customFlagBuilder == null)
                    _flagWidget(country)
                  else
                    widget.customFlagBuilder!(country),
                  if (widget.showPhoneCode && !country.iswWorldWide) ...[
                    const SizedBox(width: 15),
                    SizedBox(
                      width: 45,
                      child: Text(
                        '${isRtl ? '' : '+'}${country.phoneCode}${isRtl ? '+' : ''}',
                        style: _textStyle,
                      ),
                    ),
                    const SizedBox(width: 5),
                  ] else
                    const SizedBox(width: 15),
                ],
              ),
              Expanded(
                child: Text(
                  CountryLocalizations.of(context)
                          ?.countryName(countryCode: country.countryCode)
                          ?.replaceAll(RegExp(r"\s+"), " ") ??
                      country.name,
                  style: _textStyle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _flagWidget(Country country) {
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;
    return SizedBox(
      // the conditional 50 prevents irregularities caused by the flags in RTL mode
      width: isRtl ? 50 : null,
      child: _emojiText(country),
    );
  }

  Widget _emojiText(Country country) => Text(
        country.iswWorldWide
            ? '\uD83C\uDF0D'
            : Utils.countryCodeToEmoji(country.countryCode),
        style: TextStyle(
          fontSize: widget.countryListTheme?.flagSize ?? 25,
          fontFamilyFallback: widget.countryListTheme?.emojiFontFamilyFallback,
        ),
      );

  void _filterSearchResults(String query, bool allowPartialNameSearch) {
    List<Country> _searchResult = <Country>[];

    final CountryLocalizations? localizations =
        CountryLocalizations.of(context);
    final lowerQuery = query.toLowerCase();

    if (query.isEmpty) {
      _searchResult.addAll(_countryList);
    } else {
      _searchResult = _countryList
            .where(
              (c) => _countryMatchesQuery(
                  c, lowerQuery, localizations, countryCodes, allowPartialNameSearch),
            )
            .toList();
    }

    setState(() => _filteredList = _searchResult);
  }

  bool _countryMatchesQuery(
    Country country,
    String query,
    CountryLocalizations? localizations,
    List<Map<String, dynamic>> countryCodes, [
    bool allowPartialNameSearch = true,
  ]) {
    final lowerQuery = query.toLowerCase();
    final normalizedQuery = Utils.normalizeText(lowerQuery);

    if (allowPartialNameSearch) {
      final localizedName =
          localizations?.countryName(countryCode: country.countryCode) ?? '';
      final normalizedLocalizedName = Utils.normalizeText(localizedName.toLowerCase());
      
      // Check both original and normalized versions
      if (localizedName.toLowerCase().contains(lowerQuery)) return true;
      if (normalizedLocalizedName.contains(normalizedQuery)) return true;
    } else {
      // Ignore short random characters
      if (lowerQuery.trim().isEmpty) return false;

      // Get localized name
      final localizedName =
          localizations?.countryName(countryCode: country.countryCode) ?? '';
      final name = localizedName.toLowerCase();
      final normalizedName = Utils.normalizeText(name);

      // Match full name exactly (both original and normalized)
      if (name == lowerQuery) return true;
      if (normalizedName == normalizedQuery) return true;
    }

    // Match against countryCodes info
    final match = countryCodes.firstWhere(
      (item) =>
          item['iso2_cc']?.toString().toLowerCase() ==
          country.countryCode.toLowerCase(),
      orElse: () => {},
    );

    final officialName = (match['name'] ?? '').toString().toLowerCase();
    final normalizedOfficialName = Utils.normalizeText(officialName);
    final iso2 = (match['iso2_cc'] ?? '').toString().toLowerCase();
    final aliases = (match['iso_aliases'] ?? []) as List<dynamic>;

    // Match official full name (both original and normalized)
    if (officialName == lowerQuery) return true;
    if (normalizedOfficialName == normalizedQuery) return true;

    // Match words from official name (both original and normalized)
    if (officialName.split(RegExp(r'\s+')).contains(lowerQuery)) return true;
    if (normalizedOfficialName.split(RegExp(r'\s+')).contains(normalizedQuery)) return true;

    // Match ISO code or known alias exactly
    if (iso2 == lowerQuery) return true;
    if (aliases.any((alias) => alias.toString().toLowerCase() == lowerQuery)) {
      return true;
    }

    return false;
  }

  TextStyle get _defaultTextStyle => const TextStyle(fontSize: 16);
}
