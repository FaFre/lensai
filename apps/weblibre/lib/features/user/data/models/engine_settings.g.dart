// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'engine_settings.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CustomDohProviderCWProxy {
  CustomDohProvider url(String url);

  CustomDohProvider name(String? name);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `CustomDohProvider(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// CustomDohProvider(...).copyWith(id: 12, name: "My name")
  /// ```
  CustomDohProvider call({String url, String? name});
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfCustomDohProvider.copyWith(...)` or call `instanceOfCustomDohProvider.copyWith.fieldName(value)` for a single field.
class _$CustomDohProviderCWProxyImpl implements _$CustomDohProviderCWProxy {
  const _$CustomDohProviderCWProxyImpl(this._value);

  final CustomDohProvider _value;

  @override
  CustomDohProvider url(String url) => call(url: url);

  @override
  CustomDohProvider name(String? name) => call(name: name);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `CustomDohProvider(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// CustomDohProvider(...).copyWith(id: 12, name: "My name")
  /// ```
  @override
  CustomDohProvider call({
    Object? url = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
  }) {
    return CustomDohProvider(
      url: url == const $CopyWithPlaceholder() || url == null
          ? _value.url
          // ignore: cast_nullable_to_non_nullable
          : url as String,
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String?,
    );
  }
}

extension $CustomDohProviderCopyWith on CustomDohProvider {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfCustomDohProvider.copyWith(...)` or `instanceOfCustomDohProvider.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CustomDohProviderCWProxy get copyWith =>
      _$CustomDohProviderCWProxyImpl(this);
}

abstract class _$EngineSettingsCWProxy {
  EngineSettings javascriptEnabled(bool? javascriptEnabled);

  EngineSettings trackingProtectionPolicy(
    TrackingProtectionPolicy? trackingProtectionPolicy,
  );

  EngineSettings httpsOnlyMode(HttpsOnlyMode? httpsOnlyMode);

  EngineSettings globalPrivacyControlEnabled(bool? globalPrivacyControlEnabled);

  EngineSettings preferredColorScheme(ColorScheme? preferredColorScheme);

  EngineSettings userAgent(String? userAgent);

  EngineSettings enterpriseRootsEnabled(bool? enterpriseRootsEnabled);

  EngineSettings queryParameterStripping(
    QueryParameterStripping queryParameterStripping,
  );

  EngineSettings bounceTrackingProtectionMode(
    BounceTrackingProtectionMode bounceTrackingProtectionMode,
  );

  EngineSettings addonCollection(AddonCollection? addonCollection);

  EngineSettings ublockFilterListSettings(
    UBlockFilterListSettings ublockFilterListSettings,
  );

  EngineSettings dohSettingsMode(DohSettingsMode dohSettingsMode);

  EngineSettings dohProviderUrl(String dohProviderUrl);

  EngineSettings dohDefaultProviderUrl(String dohDefaultProviderUrl);

  EngineSettings dohExceptionsList(List<String> dohExceptionsList);

  EngineSettings customDohProviders(List<CustomDohProvider> customDohProviders);

  EngineSettings fingerprintingProtectionOverrides(
    String? fingerprintingProtectionOverrides,
  );

  EngineSettings enablePdfJs(bool enablePdfJs);

  EngineSettings safeBrowsingMalwareEnabled(bool safeBrowsingMalwareEnabled);

  EngineSettings safeBrowsingPhishingEnabled(bool safeBrowsingPhishingEnabled);

  EngineSettings locales(List<String>? locales);

  EngineSettings useContentBlockingDatabase(bool? useContentBlockingDatabase);

  EngineSettings blockCookies(bool? blockCookies);

  EngineSettings customCookiePolicy(CustomCookiePolicy? customCookiePolicy);

  EngineSettings blockTrackingContent(bool? blockTrackingContent);

  EngineSettings trackingContentScope(TrackingScope? trackingContentScope);

  EngineSettings blockCryptominers(bool? blockCryptominers);

  EngineSettings blockFingerprinters(bool? blockFingerprinters);

  EngineSettings blockRedirectTrackers(bool? blockRedirectTrackers);

  EngineSettings blockSuspectedFingerprinters(
    bool? blockSuspectedFingerprinters,
  );

  EngineSettings suspectedFingerprintersScope(
    TrackingScope? suspectedFingerprintersScope,
  );

  EngineSettings allowListBaseline(bool? allowListBaseline);

  EngineSettings allowListConvenience(bool? allowListConvenience);

  EngineSettings blockAdsAnalyticsSocialTrackers(
    bool? blockAdsAnalyticsSocialTrackers,
  );

  EngineSettings webFontsEnabled(bool? webFontsEnabled);

  EngineSettings automaticFontSizeAdjustment(bool? automaticFontSizeAdjustment);

  EngineSettings fontSizeFactor(double? fontSizeFactor);

  EngineSettings fontInflationEnabled(bool? fontInflationEnabled);

  EngineSettings displayDensityOverride(double? displayDensityOverride);

  EngineSettings screenWidthOverride(int? screenWidthOverride);

  EngineSettings screenHeightOverride(int? screenHeightOverride);

  EngineSettings inputAutoZoomEnabled(bool? inputAutoZoomEnabled);

  EngineSettings forceUserScalableContent(bool? forceUserScalableContent);

  EngineSettings fissionEnabled(bool? fissionEnabled);

  EngineSettings isolatedProcessEnabled(bool? isolatedProcessEnabled);

  EngineSettings appZygoteProcessEnabled(bool? appZygoteProcessEnabled);

  EngineSettings extensionsWebAPIEnabled(bool? extensionsWebAPIEnabled);

  EngineSettings lnaBlocking(bool? lnaBlocking);

  EngineSettings lnaBlockTrackers(bool? lnaBlockTrackers);

  EngineSettings lnaEnabled(bool? lnaEnabled);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `EngineSettings(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// EngineSettings(...).copyWith(id: 12, name: "My name")
  /// ```
  EngineSettings call({
    bool? javascriptEnabled,
    TrackingProtectionPolicy? trackingProtectionPolicy,
    HttpsOnlyMode? httpsOnlyMode,
    bool? globalPrivacyControlEnabled,
    ColorScheme? preferredColorScheme,
    String? userAgent,
    bool? enterpriseRootsEnabled,
    QueryParameterStripping queryParameterStripping,
    BounceTrackingProtectionMode bounceTrackingProtectionMode,
    AddonCollection? addonCollection,
    UBlockFilterListSettings ublockFilterListSettings,
    DohSettingsMode dohSettingsMode,
    String dohProviderUrl,
    String dohDefaultProviderUrl,
    List<String> dohExceptionsList,
    List<CustomDohProvider> customDohProviders,
    String? fingerprintingProtectionOverrides,
    bool enablePdfJs,
    bool safeBrowsingMalwareEnabled,
    bool safeBrowsingPhishingEnabled,
    List<String>? locales,
    bool? useContentBlockingDatabase,
    bool? blockCookies,
    CustomCookiePolicy? customCookiePolicy,
    bool? blockTrackingContent,
    TrackingScope? trackingContentScope,
    bool? blockCryptominers,
    bool? blockFingerprinters,
    bool? blockRedirectTrackers,
    bool? blockSuspectedFingerprinters,
    TrackingScope? suspectedFingerprintersScope,
    bool? allowListBaseline,
    bool? allowListConvenience,
    bool? blockAdsAnalyticsSocialTrackers,
    bool? webFontsEnabled,
    bool? automaticFontSizeAdjustment,
    double? fontSizeFactor,
    bool? fontInflationEnabled,
    double? displayDensityOverride,
    int? screenWidthOverride,
    int? screenHeightOverride,
    bool? inputAutoZoomEnabled,
    bool? forceUserScalableContent,
    bool? fissionEnabled,
    bool? isolatedProcessEnabled,
    bool? appZygoteProcessEnabled,
    bool? extensionsWebAPIEnabled,
    bool? lnaBlocking,
    bool? lnaBlockTrackers,
    bool? lnaEnabled,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfEngineSettings.copyWith(...)` or call `instanceOfEngineSettings.copyWith.fieldName(value)` for a single field.
class _$EngineSettingsCWProxyImpl implements _$EngineSettingsCWProxy {
  const _$EngineSettingsCWProxyImpl(this._value);

  final EngineSettings _value;

  @override
  EngineSettings javascriptEnabled(bool? javascriptEnabled) =>
      call(javascriptEnabled: javascriptEnabled);

  @override
  EngineSettings trackingProtectionPolicy(
    TrackingProtectionPolicy? trackingProtectionPolicy,
  ) => call(trackingProtectionPolicy: trackingProtectionPolicy);

  @override
  EngineSettings httpsOnlyMode(HttpsOnlyMode? httpsOnlyMode) =>
      call(httpsOnlyMode: httpsOnlyMode);

  @override
  EngineSettings globalPrivacyControlEnabled(
    bool? globalPrivacyControlEnabled,
  ) => call(globalPrivacyControlEnabled: globalPrivacyControlEnabled);

  @override
  EngineSettings preferredColorScheme(ColorScheme? preferredColorScheme) =>
      call(preferredColorScheme: preferredColorScheme);

  @override
  EngineSettings userAgent(String? userAgent) => call(userAgent: userAgent);

  @override
  EngineSettings enterpriseRootsEnabled(bool? enterpriseRootsEnabled) =>
      call(enterpriseRootsEnabled: enterpriseRootsEnabled);

  @override
  EngineSettings queryParameterStripping(
    QueryParameterStripping queryParameterStripping,
  ) => call(queryParameterStripping: queryParameterStripping);

  @override
  EngineSettings bounceTrackingProtectionMode(
    BounceTrackingProtectionMode bounceTrackingProtectionMode,
  ) => call(bounceTrackingProtectionMode: bounceTrackingProtectionMode);

  @override
  EngineSettings addonCollection(AddonCollection? addonCollection) =>
      call(addonCollection: addonCollection);

  @override
  EngineSettings ublockFilterListSettings(
    UBlockFilterListSettings ublockFilterListSettings,
  ) => call(ublockFilterListSettings: ublockFilterListSettings);

  @override
  EngineSettings dohSettingsMode(DohSettingsMode dohSettingsMode) =>
      call(dohSettingsMode: dohSettingsMode);

  @override
  EngineSettings dohProviderUrl(String dohProviderUrl) =>
      call(dohProviderUrl: dohProviderUrl);

  @override
  EngineSettings dohDefaultProviderUrl(String dohDefaultProviderUrl) =>
      call(dohDefaultProviderUrl: dohDefaultProviderUrl);

  @override
  EngineSettings dohExceptionsList(List<String> dohExceptionsList) =>
      call(dohExceptionsList: dohExceptionsList);

  @override
  EngineSettings customDohProviders(
    List<CustomDohProvider> customDohProviders,
  ) => call(customDohProviders: customDohProviders);

  @override
  EngineSettings fingerprintingProtectionOverrides(
    String? fingerprintingProtectionOverrides,
  ) => call(
    fingerprintingProtectionOverrides: fingerprintingProtectionOverrides,
  );

  @override
  EngineSettings enablePdfJs(bool enablePdfJs) =>
      call(enablePdfJs: enablePdfJs);

  @override
  EngineSettings safeBrowsingMalwareEnabled(bool safeBrowsingMalwareEnabled) =>
      call(safeBrowsingMalwareEnabled: safeBrowsingMalwareEnabled);

  @override
  EngineSettings safeBrowsingPhishingEnabled(
    bool safeBrowsingPhishingEnabled,
  ) => call(safeBrowsingPhishingEnabled: safeBrowsingPhishingEnabled);

  @override
  EngineSettings locales(List<String>? locales) => call(locales: locales);

  @override
  EngineSettings useContentBlockingDatabase(bool? useContentBlockingDatabase) =>
      call(useContentBlockingDatabase: useContentBlockingDatabase);

  @override
  EngineSettings blockCookies(bool? blockCookies) =>
      call(blockCookies: blockCookies);

  @override
  EngineSettings customCookiePolicy(CustomCookiePolicy? customCookiePolicy) =>
      call(customCookiePolicy: customCookiePolicy);

  @override
  EngineSettings blockTrackingContent(bool? blockTrackingContent) =>
      call(blockTrackingContent: blockTrackingContent);

  @override
  EngineSettings trackingContentScope(TrackingScope? trackingContentScope) =>
      call(trackingContentScope: trackingContentScope);

  @override
  EngineSettings blockCryptominers(bool? blockCryptominers) =>
      call(blockCryptominers: blockCryptominers);

  @override
  EngineSettings blockFingerprinters(bool? blockFingerprinters) =>
      call(blockFingerprinters: blockFingerprinters);

  @override
  EngineSettings blockRedirectTrackers(bool? blockRedirectTrackers) =>
      call(blockRedirectTrackers: blockRedirectTrackers);

  @override
  EngineSettings blockSuspectedFingerprinters(
    bool? blockSuspectedFingerprinters,
  ) => call(blockSuspectedFingerprinters: blockSuspectedFingerprinters);

  @override
  EngineSettings suspectedFingerprintersScope(
    TrackingScope? suspectedFingerprintersScope,
  ) => call(suspectedFingerprintersScope: suspectedFingerprintersScope);

  @override
  EngineSettings allowListBaseline(bool? allowListBaseline) =>
      call(allowListBaseline: allowListBaseline);

  @override
  EngineSettings allowListConvenience(bool? allowListConvenience) =>
      call(allowListConvenience: allowListConvenience);

  @override
  EngineSettings blockAdsAnalyticsSocialTrackers(
    bool? blockAdsAnalyticsSocialTrackers,
  ) => call(blockAdsAnalyticsSocialTrackers: blockAdsAnalyticsSocialTrackers);

  @override
  EngineSettings webFontsEnabled(bool? webFontsEnabled) =>
      call(webFontsEnabled: webFontsEnabled);

  @override
  EngineSettings automaticFontSizeAdjustment(
    bool? automaticFontSizeAdjustment,
  ) => call(automaticFontSizeAdjustment: automaticFontSizeAdjustment);

  @override
  EngineSettings fontSizeFactor(double? fontSizeFactor) =>
      call(fontSizeFactor: fontSizeFactor);

  @override
  EngineSettings fontInflationEnabled(bool? fontInflationEnabled) =>
      call(fontInflationEnabled: fontInflationEnabled);

  @override
  EngineSettings displayDensityOverride(double? displayDensityOverride) =>
      call(displayDensityOverride: displayDensityOverride);

  @override
  EngineSettings screenWidthOverride(int? screenWidthOverride) =>
      call(screenWidthOverride: screenWidthOverride);

  @override
  EngineSettings screenHeightOverride(int? screenHeightOverride) =>
      call(screenHeightOverride: screenHeightOverride);

  @override
  EngineSettings inputAutoZoomEnabled(bool? inputAutoZoomEnabled) =>
      call(inputAutoZoomEnabled: inputAutoZoomEnabled);

  @override
  EngineSettings forceUserScalableContent(bool? forceUserScalableContent) =>
      call(forceUserScalableContent: forceUserScalableContent);

  @override
  EngineSettings fissionEnabled(bool? fissionEnabled) =>
      call(fissionEnabled: fissionEnabled);

  @override
  EngineSettings isolatedProcessEnabled(bool? isolatedProcessEnabled) =>
      call(isolatedProcessEnabled: isolatedProcessEnabled);

  @override
  EngineSettings appZygoteProcessEnabled(bool? appZygoteProcessEnabled) =>
      call(appZygoteProcessEnabled: appZygoteProcessEnabled);

  @override
  EngineSettings extensionsWebAPIEnabled(bool? extensionsWebAPIEnabled) =>
      call(extensionsWebAPIEnabled: extensionsWebAPIEnabled);

  @override
  EngineSettings lnaBlocking(bool? lnaBlocking) =>
      call(lnaBlocking: lnaBlocking);

  @override
  EngineSettings lnaBlockTrackers(bool? lnaBlockTrackers) =>
      call(lnaBlockTrackers: lnaBlockTrackers);

  @override
  EngineSettings lnaEnabled(bool? lnaEnabled) => call(lnaEnabled: lnaEnabled);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `EngineSettings(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// EngineSettings(...).copyWith(id: 12, name: "My name")
  /// ```
  @override
  EngineSettings call({
    Object? javascriptEnabled = const $CopyWithPlaceholder(),
    Object? trackingProtectionPolicy = const $CopyWithPlaceholder(),
    Object? httpsOnlyMode = const $CopyWithPlaceholder(),
    Object? globalPrivacyControlEnabled = const $CopyWithPlaceholder(),
    Object? preferredColorScheme = const $CopyWithPlaceholder(),
    Object? userAgent = const $CopyWithPlaceholder(),
    Object? enterpriseRootsEnabled = const $CopyWithPlaceholder(),
    Object? queryParameterStripping = const $CopyWithPlaceholder(),
    Object? bounceTrackingProtectionMode = const $CopyWithPlaceholder(),
    Object? addonCollection = const $CopyWithPlaceholder(),
    Object? ublockFilterListSettings = const $CopyWithPlaceholder(),
    Object? dohSettingsMode = const $CopyWithPlaceholder(),
    Object? dohProviderUrl = const $CopyWithPlaceholder(),
    Object? dohDefaultProviderUrl = const $CopyWithPlaceholder(),
    Object? dohExceptionsList = const $CopyWithPlaceholder(),
    Object? customDohProviders = const $CopyWithPlaceholder(),
    Object? fingerprintingProtectionOverrides = const $CopyWithPlaceholder(),
    Object? enablePdfJs = const $CopyWithPlaceholder(),
    Object? safeBrowsingMalwareEnabled = const $CopyWithPlaceholder(),
    Object? safeBrowsingPhishingEnabled = const $CopyWithPlaceholder(),
    Object? locales = const $CopyWithPlaceholder(),
    Object? useContentBlockingDatabase = const $CopyWithPlaceholder(),
    Object? blockCookies = const $CopyWithPlaceholder(),
    Object? customCookiePolicy = const $CopyWithPlaceholder(),
    Object? blockTrackingContent = const $CopyWithPlaceholder(),
    Object? trackingContentScope = const $CopyWithPlaceholder(),
    Object? blockCryptominers = const $CopyWithPlaceholder(),
    Object? blockFingerprinters = const $CopyWithPlaceholder(),
    Object? blockRedirectTrackers = const $CopyWithPlaceholder(),
    Object? blockSuspectedFingerprinters = const $CopyWithPlaceholder(),
    Object? suspectedFingerprintersScope = const $CopyWithPlaceholder(),
    Object? allowListBaseline = const $CopyWithPlaceholder(),
    Object? allowListConvenience = const $CopyWithPlaceholder(),
    Object? blockAdsAnalyticsSocialTrackers = const $CopyWithPlaceholder(),
    Object? webFontsEnabled = const $CopyWithPlaceholder(),
    Object? automaticFontSizeAdjustment = const $CopyWithPlaceholder(),
    Object? fontSizeFactor = const $CopyWithPlaceholder(),
    Object? fontInflationEnabled = const $CopyWithPlaceholder(),
    Object? displayDensityOverride = const $CopyWithPlaceholder(),
    Object? screenWidthOverride = const $CopyWithPlaceholder(),
    Object? screenHeightOverride = const $CopyWithPlaceholder(),
    Object? inputAutoZoomEnabled = const $CopyWithPlaceholder(),
    Object? forceUserScalableContent = const $CopyWithPlaceholder(),
    Object? fissionEnabled = const $CopyWithPlaceholder(),
    Object? isolatedProcessEnabled = const $CopyWithPlaceholder(),
    Object? appZygoteProcessEnabled = const $CopyWithPlaceholder(),
    Object? extensionsWebAPIEnabled = const $CopyWithPlaceholder(),
    Object? lnaBlocking = const $CopyWithPlaceholder(),
    Object? lnaBlockTrackers = const $CopyWithPlaceholder(),
    Object? lnaEnabled = const $CopyWithPlaceholder(),
  }) {
    return EngineSettings(
      javascriptEnabled: javascriptEnabled == const $CopyWithPlaceholder()
          ? _value.javascriptEnabled
          // ignore: cast_nullable_to_non_nullable
          : javascriptEnabled as bool?,
      trackingProtectionPolicy:
          trackingProtectionPolicy == const $CopyWithPlaceholder()
          ? _value.trackingProtectionPolicy
          // ignore: cast_nullable_to_non_nullable
          : trackingProtectionPolicy as TrackingProtectionPolicy?,
      httpsOnlyMode: httpsOnlyMode == const $CopyWithPlaceholder()
          ? _value.httpsOnlyMode
          // ignore: cast_nullable_to_non_nullable
          : httpsOnlyMode as HttpsOnlyMode?,
      globalPrivacyControlEnabled:
          globalPrivacyControlEnabled == const $CopyWithPlaceholder()
          ? _value.globalPrivacyControlEnabled
          // ignore: cast_nullable_to_non_nullable
          : globalPrivacyControlEnabled as bool?,
      preferredColorScheme: preferredColorScheme == const $CopyWithPlaceholder()
          ? _value.preferredColorScheme
          // ignore: cast_nullable_to_non_nullable
          : preferredColorScheme as ColorScheme?,
      userAgent: userAgent == const $CopyWithPlaceholder()
          ? _value.userAgent
          // ignore: cast_nullable_to_non_nullable
          : userAgent as String?,
      enterpriseRootsEnabled:
          enterpriseRootsEnabled == const $CopyWithPlaceholder()
          ? _value.enterpriseRootsEnabled
          // ignore: cast_nullable_to_non_nullable
          : enterpriseRootsEnabled as bool?,
      queryParameterStripping:
          queryParameterStripping == const $CopyWithPlaceholder() ||
              queryParameterStripping == null
          ? _value.queryParameterStripping
          // ignore: cast_nullable_to_non_nullable
          : queryParameterStripping as QueryParameterStripping,
      bounceTrackingProtectionMode:
          bounceTrackingProtectionMode == const $CopyWithPlaceholder() ||
              bounceTrackingProtectionMode == null
          ? _value.bounceTrackingProtectionMode
          // ignore: cast_nullable_to_non_nullable
          : bounceTrackingProtectionMode as BounceTrackingProtectionMode,
      addonCollection: addonCollection == const $CopyWithPlaceholder()
          ? _value.addonCollection
          // ignore: cast_nullable_to_non_nullable
          : addonCollection as AddonCollection?,
      ublockFilterListSettings:
          ublockFilterListSettings == const $CopyWithPlaceholder() ||
              ublockFilterListSettings == null
          ? _value.ublockFilterListSettings
          // ignore: cast_nullable_to_non_nullable
          : ublockFilterListSettings as UBlockFilterListSettings,
      dohSettingsMode:
          dohSettingsMode == const $CopyWithPlaceholder() ||
              dohSettingsMode == null
          ? _value.dohSettingsMode
          // ignore: cast_nullable_to_non_nullable
          : dohSettingsMode as DohSettingsMode,
      dohProviderUrl:
          dohProviderUrl == const $CopyWithPlaceholder() ||
              dohProviderUrl == null
          ? _value.dohProviderUrl
          // ignore: cast_nullable_to_non_nullable
          : dohProviderUrl as String,
      dohDefaultProviderUrl:
          dohDefaultProviderUrl == const $CopyWithPlaceholder() ||
              dohDefaultProviderUrl == null
          ? _value.dohDefaultProviderUrl
          // ignore: cast_nullable_to_non_nullable
          : dohDefaultProviderUrl as String,
      dohExceptionsList:
          dohExceptionsList == const $CopyWithPlaceholder() ||
              dohExceptionsList == null
          ? _value.dohExceptionsList
          // ignore: cast_nullable_to_non_nullable
          : dohExceptionsList as List<String>,
      customDohProviders:
          customDohProviders == const $CopyWithPlaceholder() ||
              customDohProviders == null
          ? _value.customDohProviders
          // ignore: cast_nullable_to_non_nullable
          : customDohProviders as List<CustomDohProvider>,
      fingerprintingProtectionOverrides:
          fingerprintingProtectionOverrides == const $CopyWithPlaceholder()
          ? _value.fingerprintingProtectionOverrides
          // ignore: cast_nullable_to_non_nullable
          : fingerprintingProtectionOverrides as String?,
      enablePdfJs:
          enablePdfJs == const $CopyWithPlaceholder() || enablePdfJs == null
          ? _value.enablePdfJs
          // ignore: cast_nullable_to_non_nullable
          : enablePdfJs as bool,
      safeBrowsingMalwareEnabled:
          safeBrowsingMalwareEnabled == const $CopyWithPlaceholder() ||
              safeBrowsingMalwareEnabled == null
          ? _value.safeBrowsingMalwareEnabled
          // ignore: cast_nullable_to_non_nullable
          : safeBrowsingMalwareEnabled as bool,
      safeBrowsingPhishingEnabled:
          safeBrowsingPhishingEnabled == const $CopyWithPlaceholder() ||
              safeBrowsingPhishingEnabled == null
          ? _value.safeBrowsingPhishingEnabled
          // ignore: cast_nullable_to_non_nullable
          : safeBrowsingPhishingEnabled as bool,
      locales: locales == const $CopyWithPlaceholder()
          ? _value.locales
          // ignore: cast_nullable_to_non_nullable
          : locales as List<String>?,
      useContentBlockingDatabase:
          useContentBlockingDatabase == const $CopyWithPlaceholder()
          ? _value.useContentBlockingDatabase
          // ignore: cast_nullable_to_non_nullable
          : useContentBlockingDatabase as bool?,
      blockCookies: blockCookies == const $CopyWithPlaceholder()
          ? _value.blockCookies
          // ignore: cast_nullable_to_non_nullable
          : blockCookies as bool?,
      customCookiePolicy: customCookiePolicy == const $CopyWithPlaceholder()
          ? _value.customCookiePolicy
          // ignore: cast_nullable_to_non_nullable
          : customCookiePolicy as CustomCookiePolicy?,
      blockTrackingContent: blockTrackingContent == const $CopyWithPlaceholder()
          ? _value.blockTrackingContent
          // ignore: cast_nullable_to_non_nullable
          : blockTrackingContent as bool?,
      trackingContentScope: trackingContentScope == const $CopyWithPlaceholder()
          ? _value.trackingContentScope
          // ignore: cast_nullable_to_non_nullable
          : trackingContentScope as TrackingScope?,
      blockCryptominers: blockCryptominers == const $CopyWithPlaceholder()
          ? _value.blockCryptominers
          // ignore: cast_nullable_to_non_nullable
          : blockCryptominers as bool?,
      blockFingerprinters: blockFingerprinters == const $CopyWithPlaceholder()
          ? _value.blockFingerprinters
          // ignore: cast_nullable_to_non_nullable
          : blockFingerprinters as bool?,
      blockRedirectTrackers:
          blockRedirectTrackers == const $CopyWithPlaceholder()
          ? _value.blockRedirectTrackers
          // ignore: cast_nullable_to_non_nullable
          : blockRedirectTrackers as bool?,
      blockSuspectedFingerprinters:
          blockSuspectedFingerprinters == const $CopyWithPlaceholder()
          ? _value.blockSuspectedFingerprinters
          // ignore: cast_nullable_to_non_nullable
          : blockSuspectedFingerprinters as bool?,
      suspectedFingerprintersScope:
          suspectedFingerprintersScope == const $CopyWithPlaceholder()
          ? _value.suspectedFingerprintersScope
          // ignore: cast_nullable_to_non_nullable
          : suspectedFingerprintersScope as TrackingScope?,
      allowListBaseline: allowListBaseline == const $CopyWithPlaceholder()
          ? _value.allowListBaseline
          // ignore: cast_nullable_to_non_nullable
          : allowListBaseline as bool?,
      allowListConvenience: allowListConvenience == const $CopyWithPlaceholder()
          ? _value.allowListConvenience
          // ignore: cast_nullable_to_non_nullable
          : allowListConvenience as bool?,
      blockAdsAnalyticsSocialTrackers:
          blockAdsAnalyticsSocialTrackers == const $CopyWithPlaceholder()
          ? _value.blockAdsAnalyticsSocialTrackers
          // ignore: cast_nullable_to_non_nullable
          : blockAdsAnalyticsSocialTrackers as bool?,
      webFontsEnabled: webFontsEnabled == const $CopyWithPlaceholder()
          ? _value.webFontsEnabled
          // ignore: cast_nullable_to_non_nullable
          : webFontsEnabled as bool?,
      automaticFontSizeAdjustment:
          automaticFontSizeAdjustment == const $CopyWithPlaceholder()
          ? _value.automaticFontSizeAdjustment
          // ignore: cast_nullable_to_non_nullable
          : automaticFontSizeAdjustment as bool?,
      fontSizeFactor: fontSizeFactor == const $CopyWithPlaceholder()
          ? _value.fontSizeFactor
          // ignore: cast_nullable_to_non_nullable
          : fontSizeFactor as double?,
      fontInflationEnabled: fontInflationEnabled == const $CopyWithPlaceholder()
          ? _value.fontInflationEnabled
          // ignore: cast_nullable_to_non_nullable
          : fontInflationEnabled as bool?,
      displayDensityOverride:
          displayDensityOverride == const $CopyWithPlaceholder()
          ? _value.displayDensityOverride
          // ignore: cast_nullable_to_non_nullable
          : displayDensityOverride as double?,
      screenWidthOverride: screenWidthOverride == const $CopyWithPlaceholder()
          ? _value.screenWidthOverride
          // ignore: cast_nullable_to_non_nullable
          : screenWidthOverride as int?,
      screenHeightOverride: screenHeightOverride == const $CopyWithPlaceholder()
          ? _value.screenHeightOverride
          // ignore: cast_nullable_to_non_nullable
          : screenHeightOverride as int?,
      inputAutoZoomEnabled: inputAutoZoomEnabled == const $CopyWithPlaceholder()
          ? _value.inputAutoZoomEnabled
          // ignore: cast_nullable_to_non_nullable
          : inputAutoZoomEnabled as bool?,
      forceUserScalableContent:
          forceUserScalableContent == const $CopyWithPlaceholder()
          ? _value.forceUserScalableContent
          // ignore: cast_nullable_to_non_nullable
          : forceUserScalableContent as bool?,
      fissionEnabled: fissionEnabled == const $CopyWithPlaceholder()
          ? _value.fissionEnabled
          // ignore: cast_nullable_to_non_nullable
          : fissionEnabled as bool?,
      isolatedProcessEnabled:
          isolatedProcessEnabled == const $CopyWithPlaceholder()
          ? _value.isolatedProcessEnabled
          // ignore: cast_nullable_to_non_nullable
          : isolatedProcessEnabled as bool?,
      appZygoteProcessEnabled:
          appZygoteProcessEnabled == const $CopyWithPlaceholder()
          ? _value.appZygoteProcessEnabled
          // ignore: cast_nullable_to_non_nullable
          : appZygoteProcessEnabled as bool?,
      extensionsWebAPIEnabled:
          extensionsWebAPIEnabled == const $CopyWithPlaceholder()
          ? _value.extensionsWebAPIEnabled
          // ignore: cast_nullable_to_non_nullable
          : extensionsWebAPIEnabled as bool?,
      lnaBlocking: lnaBlocking == const $CopyWithPlaceholder()
          ? _value.lnaBlocking
          // ignore: cast_nullable_to_non_nullable
          : lnaBlocking as bool?,
      lnaBlockTrackers: lnaBlockTrackers == const $CopyWithPlaceholder()
          ? _value.lnaBlockTrackers
          // ignore: cast_nullable_to_non_nullable
          : lnaBlockTrackers as bool?,
      lnaEnabled: lnaEnabled == const $CopyWithPlaceholder()
          ? _value.lnaEnabled
          // ignore: cast_nullable_to_non_nullable
          : lnaEnabled as bool?,
    );
  }
}

extension $EngineSettingsCopyWith on EngineSettings {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfEngineSettings.copyWith(...)` or `instanceOfEngineSettings.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$EngineSettingsCWProxy get copyWith => _$EngineSettingsCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CustomDohProvider _$CustomDohProviderFromJson(Map<String, dynamic> json) =>
    CustomDohProvider(
      url: json['url'] as String,
      name: json['name'] as String?,
    );

Map<String, dynamic> _$CustomDohProviderToJson(CustomDohProvider instance) =>
    <String, dynamic>{'url': instance.url, 'name': ?instance.name};

EngineSettings _$EngineSettingsFromJson(Map<String, dynamic> json) =>
    EngineSettings.withDefaults(
        javascriptEnabled: json['javascriptEnabled'] as bool?,
        trackingProtectionPolicy: $enumDecodeNullable(
          _$TrackingProtectionPolicyEnumMap,
          json['trackingProtectionPolicy'],
        ),
        httpsOnlyMode: $enumDecodeNullable(
          _$HttpsOnlyModeEnumMap,
          json['httpsOnlyMode'],
        ),
        globalPrivacyControlEnabled:
            json['globalPrivacyControlEnabled'] as bool?,
        preferredColorScheme: $enumDecodeNullable(
          _$ColorSchemeEnumMap,
          json['preferredColorScheme'],
        ),
        queryParameterStripping: $enumDecodeNullable(
          _$QueryParameterStrippingEnumMap,
          json['queryParameterStripping'],
        ),
        bounceTrackingProtectionMode: $enumDecodeNullable(
          _$BounceTrackingProtectionModeEnumMap,
          json['bounceTrackingProtectionMode'],
        ),
        userAgent: json['userAgent'] as String?,
        enterpriseRootsEnabled: json['enterpriseRootsEnabled'] as bool?,
        addonCollection: EngineSettings._addonCollectionFromJson(
          json['addonCollection'] as String?,
        ),
        ublockFilterListSettings:
            EngineSettings._ublockFilterListSettingsFromJson(
              json['ublockFilterListSettings'] as String?,
            ),
        dohSettingsMode: $enumDecodeNullable(
          _$DohSettingsModeEnumMap,
          json['dohSettingsMode'],
        ),
        dohProviderUrl: json['dohProviderUrl'] as String?,
        dohDefaultProviderUrl: json['dohDefaultProviderUrl'] as String?,
        dohExceptionsList: (json['dohExceptionsList'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList(),
        customDohProviders: (json['customDohProviders'] as List<dynamic>?)
            ?.map((e) => CustomDohProvider.fromJson(e as Map<String, dynamic>))
            .toList(),
        fingerprintingProtectionOverrides:
            json['fingerprintingProtectionOverrides'] as String?,
        enablePdfJs: json['enablePdfJs'] as bool?,
        safeBrowsingMalwareEnabled: json['safeBrowsingMalwareEnabled'] as bool?,
        safeBrowsingPhishingEnabled:
            json['safeBrowsingPhishingEnabled'] as bool?,
        locales: (json['locales'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList(),
        useContentBlockingDatabase: json['useContentBlockingDatabase'] as bool?,
        blockCookies: json['blockCookies'] as bool?,
        customCookiePolicy: $enumDecodeNullable(
          _$CustomCookiePolicyEnumMap,
          json['customCookiePolicy'],
        ),
        blockTrackingContent: json['blockTrackingContent'] as bool?,
        trackingContentScope: $enumDecodeNullable(
          _$TrackingScopeEnumMap,
          json['trackingContentScope'],
        ),
        blockCryptominers: json['blockCryptominers'] as bool?,
        blockFingerprinters: json['blockFingerprinters'] as bool?,
        blockRedirectTrackers: json['blockRedirectTrackers'] as bool?,
        blockSuspectedFingerprinters:
            json['blockSuspectedFingerprinters'] as bool?,
        suspectedFingerprintersScope: $enumDecodeNullable(
          _$TrackingScopeEnumMap,
          json['suspectedFingerprintersScope'],
        ),
        allowListBaseline: json['allowListBaseline'] as bool?,
        allowListConvenience: json['allowListConvenience'] as bool?,
        blockAdsAnalyticsSocialTrackers:
            json['blockAdsAnalyticsSocialTrackers'] as bool?,
        webFontsEnabled: json['webFontsEnabled'] as bool?,
        automaticFontSizeAdjustment:
            json['automaticFontSizeAdjustment'] as bool?,
        fontSizeFactor: (json['fontSizeFactor'] as num?)?.toDouble(),
        fontInflationEnabled: json['fontInflationEnabled'] as bool?,
        displayDensityOverride: (json['displayDensityOverride'] as num?)
            ?.toDouble(),
        screenWidthOverride: (json['screenWidthOverride'] as num?)?.toInt(),
        screenHeightOverride: (json['screenHeightOverride'] as num?)?.toInt(),
        inputAutoZoomEnabled: json['inputAutoZoomEnabled'] as bool?,
        forceUserScalableContent: json['forceUserScalableContent'] as bool?,
        fissionEnabled: json['fissionEnabled'] as bool?,
        isolatedProcessEnabled: json['isolatedProcessEnabled'] as bool?,
        appZygoteProcessEnabled: json['appZygoteProcessEnabled'] as bool?,
        extensionsWebAPIEnabled: json['extensionsWebAPIEnabled'] as bool?,
        lnaBlocking: json['lnaBlocking'] as bool?,
        lnaBlockTrackers: json['lnaBlockTrackers'] as bool?,
        lnaEnabled: json['lnaEnabled'] as bool?,
      )
      ..cookieBannerHandlingMode = $enumDecodeNullable(
        _$CookieBannerHandlingModeEnumMap,
        json['cookieBannerHandlingMode'],
      )
      ..cookieBannerHandlingModePrivateBrowsing = $enumDecodeNullable(
        _$CookieBannerHandlingModeEnumMap,
        json['cookieBannerHandlingModePrivateBrowsing'],
      )
      ..cookieBannerHandlingGlobalRules =
          json['cookieBannerHandlingGlobalRules'] as bool?
      ..cookieBannerHandlingGlobalRulesSubFrames =
          json['cookieBannerHandlingGlobalRulesSubFrames'] as bool?;

Map<String, dynamic> _$EngineSettingsToJson(
  EngineSettings instance,
) => <String, dynamic>{
  'cookieBannerHandlingMode':
      _$CookieBannerHandlingModeEnumMap[instance.cookieBannerHandlingMode],
  'cookieBannerHandlingModePrivateBrowsing':
      _$CookieBannerHandlingModeEnumMap[instance
          .cookieBannerHandlingModePrivateBrowsing],
  'cookieBannerHandlingGlobalRules': instance.cookieBannerHandlingGlobalRules,
  'cookieBannerHandlingGlobalRulesSubFrames':
      instance.cookieBannerHandlingGlobalRulesSubFrames,
  'userAgent': instance.userAgent,
  'fingerprintingProtectionOverrides':
      instance.fingerprintingProtectionOverrides,
  'displayDensityOverride': instance.displayDensityOverride,
  'screenWidthOverride': instance.screenWidthOverride,
  'screenHeightOverride': instance.screenHeightOverride,
  'lnaBlocking': instance.lnaBlocking,
  'lnaBlockTrackers': instance.lnaBlockTrackers,
  'lnaEnabled': instance.lnaEnabled,
  'javascriptEnabled': instance.javascriptEnabled,
  'trackingProtectionPolicy':
      _$TrackingProtectionPolicyEnumMap[instance.trackingProtectionPolicy]!,
  'httpsOnlyMode': _$HttpsOnlyModeEnumMap[instance.httpsOnlyMode]!,
  'preferredColorScheme': _$ColorSchemeEnumMap[instance.preferredColorScheme]!,
  'globalPrivacyControlEnabled': instance.globalPrivacyControlEnabled,
  'enterpriseRootsEnabled': instance.enterpriseRootsEnabled,
  'locales': instance.locales,
  'useContentBlockingDatabase': instance.useContentBlockingDatabase,
  'blockCookies': instance.blockCookies,
  'customCookiePolicy':
      _$CustomCookiePolicyEnumMap[instance.customCookiePolicy]!,
  'blockTrackingContent': instance.blockTrackingContent,
  'trackingContentScope':
      _$TrackingScopeEnumMap[instance.trackingContentScope]!,
  'blockCryptominers': instance.blockCryptominers,
  'blockFingerprinters': instance.blockFingerprinters,
  'blockRedirectTrackers': instance.blockRedirectTrackers,
  'blockSuspectedFingerprinters': instance.blockSuspectedFingerprinters,
  'suspectedFingerprintersScope':
      _$TrackingScopeEnumMap[instance.suspectedFingerprintersScope]!,
  'allowListBaseline': instance.allowListBaseline,
  'allowListConvenience': instance.allowListConvenience,
  'blockAdsAnalyticsSocialTrackers': instance.blockAdsAnalyticsSocialTrackers,
  'webFontsEnabled': instance.webFontsEnabled,
  'automaticFontSizeAdjustment': instance.automaticFontSizeAdjustment,
  'fontSizeFactor': instance.fontSizeFactor,
  'fontInflationEnabled': instance.fontInflationEnabled,
  'inputAutoZoomEnabled': instance.inputAutoZoomEnabled,
  'forceUserScalableContent': instance.forceUserScalableContent,
  'fissionEnabled': instance.fissionEnabled,
  'isolatedProcessEnabled': instance.isolatedProcessEnabled,
  'appZygoteProcessEnabled': instance.appZygoteProcessEnabled,
  'extensionsWebAPIEnabled': instance.extensionsWebAPIEnabled,
  'queryParameterStripping':
      _$QueryParameterStrippingEnumMap[instance.queryParameterStripping]!,
  'bounceTrackingProtectionMode':
      _$BounceTrackingProtectionModeEnumMap[instance
          .bounceTrackingProtectionMode]!,
  'addonCollection': EngineSettings._addonCollectionToJson(
    instance.addonCollection,
  ),
  'ublockFilterListSettings': EngineSettings._ublockFilterListSettingsToJson(
    instance.ublockFilterListSettings,
  ),
  'dohSettingsMode': _$DohSettingsModeEnumMap[instance.dohSettingsMode]!,
  'dohProviderUrl': instance.dohProviderUrl,
  'dohDefaultProviderUrl': instance.dohDefaultProviderUrl,
  'dohExceptionsList': instance.dohExceptionsList,
  'customDohProviders': instance.customDohProviders
      .map((e) => e.toJson())
      .toList(),
  'enablePdfJs': instance.enablePdfJs,
  'safeBrowsingMalwareEnabled': instance.safeBrowsingMalwareEnabled,
  'safeBrowsingPhishingEnabled': instance.safeBrowsingPhishingEnabled,
};

const _$TrackingProtectionPolicyEnumMap = {
  TrackingProtectionPolicy.none: 'none',
  TrackingProtectionPolicy.recommended: 'recommended',
  TrackingProtectionPolicy.strict: 'strict',
  TrackingProtectionPolicy.custom: 'custom',
};

const _$HttpsOnlyModeEnumMap = {
  HttpsOnlyMode.disabled: 'disabled',
  HttpsOnlyMode.privateOnly: 'privateOnly',
  HttpsOnlyMode.enabled: 'enabled',
};

const _$ColorSchemeEnumMap = {
  ColorScheme.system: 'system',
  ColorScheme.light: 'light',
  ColorScheme.dark: 'dark',
};

const _$QueryParameterStrippingEnumMap = {
  QueryParameterStripping.disabled: 'disabled',
  QueryParameterStripping.privateOnly: 'privateOnly',
  QueryParameterStripping.enabled: 'enabled',
};

const _$BounceTrackingProtectionModeEnumMap = {
  BounceTrackingProtectionMode.disabled: 'disabled',
  BounceTrackingProtectionMode.enabled: 'enabled',
  BounceTrackingProtectionMode.enabledStandby: 'enabledStandby',
  BounceTrackingProtectionMode.enabledDryRun: 'enabledDryRun',
};

const _$DohSettingsModeEnumMap = {
  DohSettingsMode.geckoDefault: 'geckoDefault',
  DohSettingsMode.increased: 'increased',
  DohSettingsMode.max: 'max',
  DohSettingsMode.off: 'off',
};

const _$CustomCookiePolicyEnumMap = {
  CustomCookiePolicy.totalProtection: 'totalProtection',
  CustomCookiePolicy.crossSiteTrackers: 'crossSiteTrackers',
  CustomCookiePolicy.unvisited: 'unvisited',
  CustomCookiePolicy.thirdParty: 'thirdParty',
  CustomCookiePolicy.allCookies: 'allCookies',
};

const _$TrackingScopeEnumMap = {
  TrackingScope.all: 'all',
  TrackingScope.privateOnly: 'privateOnly',
};

const _$CookieBannerHandlingModeEnumMap = {
  CookieBannerHandlingMode.disabled: 'disabled',
  CookieBannerHandlingMode.rejectAll: 'rejectAll',
  CookieBannerHandlingMode.rejectOrAcceptAll: 'rejectOrAcceptAll',
};
