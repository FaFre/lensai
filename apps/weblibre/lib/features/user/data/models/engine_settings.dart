/*
 * Copyright (c) 2024-2026 Fabian Freund.
 *
 * This file is part of WebLibre
 * (see https://weblibre.eu).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
import 'dart:convert';

import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:fast_equatable/fast_equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:nullability/nullability.dart';
import 'package:weblibre/features/user/data/models/ublock_filter_list_settings.dart';
import 'package:weblibre/features/user/domain/entities/fingerprint_overrides.dart';

part 'engine_settings.g.dart';

enum BuiltInDohProviders {
  quad9('Quad9', 'https://dns.quad9.net/dns-query'),
  mullvad('Mullvad', 'https://dns.mullvad.net/dns-query'),
  adguard('AdGuard', 'https://dns.adguard-dns.com/dns-query'),
  ffmuc('Freifunk München', 'https://doh.ffmuc.net/dns-query');

  final String name;
  final String url;

  static bool isBuiltin(String url) =>
      BuiltInDohProviders.values.any((provider) => provider.url == url);

  const BuiltInDohProviders(this.name, this.url);
}

const kMaxCustomDohProviders = 16;

/// A user-added DoH resolver. Rendered next to [BuiltInDohProviders] so that
/// selecting one is a plain radio tap instead of a free-text field that has to
/// be committed through the keyboard.
@CopyWith()
@JsonSerializable(includeIfNull: true)
class CustomDohProvider with FastEquatable {
  final String url;

  @JsonKey(includeIfNull: false)
  final String? name;

  CustomDohProvider({required this.url, this.name});

  /// Falls back to the host so an unnamed resolver still reads as a label.
  String get displayName {
    final trimmed = name?.trim();
    if (trimmed != null && trimmed.isNotEmpty) {
      return trimmed;
    }

    final host = Uri.tryParse(url)?.host;

    return (host != null && host.isNotEmpty) ? host : url;
  }

  factory CustomDohProvider.fromJson(Map<String, dynamic> json) =>
      _$CustomDohProviderFromJson(json);

  Map<String, dynamic> toJson() => _$CustomDohProviderToJson(this);

  /// Adopts a resolver that only exists as the selected [dohProviderUrl] into
  /// the saved list. Before saved resolvers existed, a custom resolver lived
  /// nowhere else — without this it would disappear the moment the user picked
  /// a built-in provider instead.
  ///
  /// Runs on every deserialization, so the adopted entry is part of the model
  /// before anything can read it, and reaches the database with the next
  /// settings write. Covered end to end by `engine_settings_doh_test.dart`.
  static List<CustomDohProvider> adoptSelected(
    List<CustomDohProvider> providers,
    String dohProviderUrl,
  ) {
    if (BuiltInDohProviders.isBuiltin(dohProviderUrl) ||
        providers.any((provider) => provider.url == dohProviderUrl)) {
      return providers;
    }

    return [...providers, CustomDohProvider(url: dohProviderUrl)];
  }

  @override
  List<Object?> get hashParameters => [url, name];
}

@CopyWith()
@JsonSerializable(includeIfNull: true, constructor: 'withDefaults')
class EngineSettings extends GeckoEngineSettings with FastEquatable {
  @override
  bool get javascriptEnabled => super.javascriptEnabled!;
  @override
  TrackingProtectionPolicy get trackingProtectionPolicy =>
      super.trackingProtectionPolicy!;
  @override
  HttpsOnlyMode get httpsOnlyMode => super.httpsOnlyMode!;
  @override
  ColorScheme get preferredColorScheme => super.preferredColorScheme!;
  @override
  bool get globalPrivacyControlEnabled => super.globalPrivacyControlEnabled!;
  @override
  bool get enterpriseRootsEnabled => super.enterpriseRootsEnabled!;

  @override
  List<String> get locales => super.locales!;

  @override
  bool get useContentBlockingDatabase => super.useContentBlockingDatabase!;

  // Custom Tracking Protection overrides
  @override
  bool get blockCookies => super.blockCookies!;
  @override
  CustomCookiePolicy get customCookiePolicy => super.customCookiePolicy!;
  @override
  bool get blockTrackingContent => super.blockTrackingContent!;
  @override
  TrackingScope get trackingContentScope => super.trackingContentScope!;
  @override
  bool get blockCryptominers => super.blockCryptominers!;
  @override
  bool get blockFingerprinters => super.blockFingerprinters!;
  @override
  bool get blockRedirectTrackers => super.blockRedirectTrackers!;
  @override
  bool get blockSuspectedFingerprinters => super.blockSuspectedFingerprinters!;
  @override
  TrackingScope get suspectedFingerprintersScope =>
      super.suspectedFingerprintersScope!;
  @override
  bool get allowListBaseline => super.allowListBaseline!;
  @override
  bool get allowListConvenience => super.allowListConvenience!;
  @override
  bool get blockAdsAnalyticsSocialTrackers =>
      super.blockAdsAnalyticsSocialTrackers!;

  // Web Content Settings
  @override
  bool get webFontsEnabled => super.webFontsEnabled!;
  @override
  bool get automaticFontSizeAdjustment => super.automaticFontSizeAdjustment!;
  @override
  double get fontSizeFactor => super.fontSizeFactor!;
  @override
  bool get fontInflationEnabled => super.fontInflationEnabled!;
  @override
  bool get inputAutoZoomEnabled => super.inputAutoZoomEnabled!;
  @override
  bool get forceUserScalableContent => super.forceUserScalableContent!;

  // Process Isolation Settings (require app restart)
  @override
  bool get fissionEnabled => super.fissionEnabled!;
  @override
  bool get isolatedProcessEnabled => super.isolatedProcessEnabled!;
  @override
  bool get appZygoteProcessEnabled => super.appZygoteProcessEnabled!;
  @override
  bool get extensionsWebAPIEnabled => super.extensionsWebAPIEnabled!;

  final QueryParameterStripping queryParameterStripping;

  final BounceTrackingProtectionMode bounceTrackingProtectionMode;

  @JsonKey(fromJson: _addonCollectionFromJson, toJson: _addonCollectionToJson)
  final AddonCollection? addonCollection;

  @JsonKey(
    fromJson: _ublockFilterListSettingsFromJson,
    toJson: _ublockFilterListSettingsToJson,
  )
  final UBlockFilterListSettings ublockFilterListSettings;

  final DohSettingsMode dohSettingsMode;
  final String dohProviderUrl;
  final String dohDefaultProviderUrl;
  final List<String> dohExceptionsList;

  final List<CustomDohProvider> customDohProviders;

  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  DohSettings get dohSettings => DohSettings(
    dohSettingsMode: dohSettingsMode,
    dohProviderUrl: dohProviderUrl,
    dohDefaultProviderUrl: dohDefaultProviderUrl,
    dohExceptionsList: dohExceptionsList,
  );

  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  ContentBlocking get contentBlocking => ContentBlocking(
    queryParameterStripping: queryParameterStripping,
    queryParameterStrippingAllowList: '',
    queryParameterStrippingStripList:
        '__hsfp __hssc __hstc __s _bhlid _branch_match_id _branch_referrer _gl _hsenc _kx _openstat at_recipient_id at_recipient_list bbeml bsft_clkid bsft_uid dclid et_rid fb_action_ids fb_comment_id fbclid gbraid gclid guce_referrer guce_referrer_sig hsCtaTracking igshid irclickid mc_eid mkt_tok ml_subscriber ml_subscriber_hash msclkid mtm_cid oft_c oft_ck oft_d oft_id oft_ids oft_k oft_lk oft_sk oly_anon_id oly_enc_id pk_cid rb_clickid s_cid sc_customer sc_eh sc_uid sms_click sms_source sms_uph srsltid ss_email_id syclid ttclid twclid unicorn_click_id vero_conv vero_id vgo_ee wbraid wickedid yclid ymclid ysclid',
    bounceTrackingProtectionMode: bounceTrackingProtectionMode,
  );

  final bool enablePdfJs;

  final bool safeBrowsingMalwareEnabled;

  final bool safeBrowsingPhishingEnabled;

  EngineSettings({
    required super.javascriptEnabled,
    required super.trackingProtectionPolicy,
    required super.httpsOnlyMode,
    required super.globalPrivacyControlEnabled,
    required super.preferredColorScheme,
    required super.userAgent,
    required super.enterpriseRootsEnabled,
    required this.queryParameterStripping,
    required this.bounceTrackingProtectionMode,
    required this.addonCollection,
    required this.ublockFilterListSettings,
    required this.dohSettingsMode,
    required this.dohProviderUrl,
    required this.dohDefaultProviderUrl,
    required this.dohExceptionsList,
    required this.customDohProviders,
    required super.fingerprintingProtectionOverrides,
    required this.enablePdfJs,
    required this.safeBrowsingMalwareEnabled,
    required this.safeBrowsingPhishingEnabled,
    required super.locales,
    required super.useContentBlockingDatabase,
    required super.blockCookies,
    required super.customCookiePolicy,
    required super.blockTrackingContent,
    required super.trackingContentScope,
    required super.blockCryptominers,
    required super.blockFingerprinters,
    required super.blockRedirectTrackers,
    required super.blockSuspectedFingerprinters,
    required super.suspectedFingerprintersScope,
    required super.allowListBaseline,
    required super.allowListConvenience,
    required super.blockAdsAnalyticsSocialTrackers,
    required super.webFontsEnabled,
    required super.automaticFontSizeAdjustment,
    required super.fontSizeFactor,
    required super.fontInflationEnabled,
    required super.displayDensityOverride,
    required super.screenWidthOverride,
    required super.screenHeightOverride,
    required super.inputAutoZoomEnabled,
    required super.forceUserScalableContent,
    required super.fissionEnabled,
    required super.isolatedProcessEnabled,
    required super.appZygoteProcessEnabled,
    required super.extensionsWebAPIEnabled,
    required super.lnaBlocking,
    required super.lnaBlockTrackers,
    required super.lnaEnabled,
  });

  EngineSettings.withDefaults({
    bool? javascriptEnabled,
    TrackingProtectionPolicy? trackingProtectionPolicy,
    HttpsOnlyMode? httpsOnlyMode,
    bool? globalPrivacyControlEnabled,
    ColorScheme? preferredColorScheme,
    QueryParameterStripping? queryParameterStripping,
    BounceTrackingProtectionMode? bounceTrackingProtectionMode,
    super.userAgent,
    bool? enterpriseRootsEnabled,
    this.addonCollection,
    UBlockFilterListSettings? ublockFilterListSettings,
    DohSettingsMode? dohSettingsMode,
    String? dohProviderUrl,
    String? dohDefaultProviderUrl,
    List<String>? dohExceptionsList,
    List<CustomDohProvider>? customDohProviders,
    String? fingerprintingProtectionOverrides,
    bool? enablePdfJs,
    bool? safeBrowsingMalwareEnabled,
    bool? safeBrowsingPhishingEnabled,
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
    super.displayDensityOverride,
    super.screenWidthOverride,
    super.screenHeightOverride,
    bool? inputAutoZoomEnabled,
    bool? forceUserScalableContent,
    bool? fissionEnabled,
    bool? isolatedProcessEnabled,
    bool? appZygoteProcessEnabled,
    bool? extensionsWebAPIEnabled,
    super.lnaBlocking,
    bool? lnaBlockTrackers,
    bool? lnaEnabled,
  }) : ublockFilterListSettings =
           ublockFilterListSettings ?? UBlockFilterListSettings(),
       queryParameterStripping =
           queryParameterStripping ?? QueryParameterStripping.enabled,
       bounceTrackingProtectionMode =
           bounceTrackingProtectionMode ?? BounceTrackingProtectionMode.enabled,
       dohSettingsMode = dohSettingsMode ?? DohSettingsMode.increased,
       dohProviderUrl = dohProviderUrl ?? BuiltInDohProviders.quad9.url,
       dohDefaultProviderUrl =
           dohDefaultProviderUrl ?? BuiltInDohProviders.quad9.url,
       dohExceptionsList = dohExceptionsList ?? [],
       customDohProviders = CustomDohProvider.adoptSelected(
         customDohProviders ?? [],
         dohProviderUrl ?? BuiltInDohProviders.quad9.url,
       ),
       enablePdfJs = enablePdfJs ?? true,
       safeBrowsingMalwareEnabled = safeBrowsingMalwareEnabled ?? true,
       safeBrowsingPhishingEnabled = safeBrowsingPhishingEnabled ?? true,
       super(
         javascriptEnabled: javascriptEnabled ?? true,
         trackingProtectionPolicy:
             trackingProtectionPolicy ?? TrackingProtectionPolicy.strict,
         httpsOnlyMode: httpsOnlyMode ?? HttpsOnlyMode.enabled,
         globalPrivacyControlEnabled: globalPrivacyControlEnabled ?? true,
         preferredColorScheme: preferredColorScheme ?? ColorScheme.system,
         enterpriseRootsEnabled: enterpriseRootsEnabled ?? false,
         fingerprintingProtectionOverrides:
             fingerprintingProtectionOverrides ??
             FingerprintOverrides.defaults().toString(),
         locales:
             locales ??
             WidgetsBinding.instance.platformDispatcher.locales
                 .map((x) => x.toLanguageTag())
                 .toList(),
         useContentBlockingDatabase: useContentBlockingDatabase ?? true,
         blockCookies: blockCookies ?? true,
         customCookiePolicy:
             customCookiePolicy ?? CustomCookiePolicy.totalProtection,
         blockTrackingContent: blockTrackingContent ?? true,
         trackingContentScope: trackingContentScope ?? TrackingScope.all,
         blockCryptominers: blockCryptominers ?? true,
         blockFingerprinters: blockFingerprinters ?? true,
         blockRedirectTrackers: blockRedirectTrackers ?? true,
         blockSuspectedFingerprinters: blockSuspectedFingerprinters ?? true,
         suspectedFingerprintersScope:
             suspectedFingerprintersScope ?? TrackingScope.all,
         allowListBaseline: allowListBaseline ?? true,
         allowListConvenience: allowListConvenience ?? false,
         blockAdsAnalyticsSocialTrackers:
             blockAdsAnalyticsSocialTrackers ?? true,
         webFontsEnabled: webFontsEnabled ?? true,
         automaticFontSizeAdjustment: automaticFontSizeAdjustment ?? true,
         fontSizeFactor: fontSizeFactor ?? 1.0,
         fontInflationEnabled: fontInflationEnabled ?? false,
         inputAutoZoomEnabled: inputAutoZoomEnabled ?? true,
         forceUserScalableContent: forceUserScalableContent ?? false,
         fissionEnabled: fissionEnabled ?? true,
         isolatedProcessEnabled: isolatedProcessEnabled ?? false,
         appZygoteProcessEnabled: appZygoteProcessEnabled ?? false,
         extensionsWebAPIEnabled: extensionsWebAPIEnabled ?? true,
         lnaBlockTrackers: lnaBlockTrackers ?? true,
         lnaEnabled: lnaEnabled ?? true,
       );

  static AddonCollection? _addonCollectionFromJson(String? json) =>
      json.mapNotNull(
        (collection) => AddonCollection.decode(jsonDecode(collection) as List),
      );

  static String? _addonCollectionToJson(AddonCollection? collection) =>
      collection.mapNotNull((collection) => jsonEncode(collection.encode()));

  static UBlockFilterListSettings _ublockFilterListSettingsFromJson(
    String? json,
  ) =>
      json.mapNotNull(
        (encoded) => UBlockFilterListSettings.fromJson(
          jsonDecode(encoded) as Map<String, dynamic>,
        ),
      ) ??
      UBlockFilterListSettings();

  static String _ublockFilterListSettingsToJson(
    UBlockFilterListSettings settings,
  ) => jsonEncode(settings.toJson());

  factory EngineSettings.fromJson(Map<String, dynamic> json) =>
      _$EngineSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$EngineSettingsToJson(this);

  @override
  List<Object?> get hashParameters => [
    javascriptEnabled,
    trackingProtectionPolicy,
    httpsOnlyMode,
    globalPrivacyControlEnabled,
    preferredColorScheme,
    userAgent,
    enterpriseRootsEnabled,
    queryParameterStripping,
    bounceTrackingProtectionMode,
    addonCollection,
    ublockFilterListSettings,
    dohSettingsMode,
    dohProviderUrl,
    dohDefaultProviderUrl,
    dohExceptionsList,
    customDohProviders,
    fingerprintingProtectionOverrides,
    enablePdfJs,
    safeBrowsingMalwareEnabled,
    safeBrowsingPhishingEnabled,
    locales,
    useContentBlockingDatabase,
    blockCookies,
    customCookiePolicy,
    blockTrackingContent,
    trackingContentScope,
    blockCryptominers,
    blockFingerprinters,
    blockRedirectTrackers,
    blockSuspectedFingerprinters,
    suspectedFingerprintersScope,
    allowListBaseline,
    allowListConvenience,
    blockAdsAnalyticsSocialTrackers,
    webFontsEnabled,
    automaticFontSizeAdjustment,
    fontSizeFactor,
    fontInflationEnabled,
    displayDensityOverride,
    screenWidthOverride,
    screenHeightOverride,
    inputAutoZoomEnabled,
    forceUserScalableContent,
    fissionEnabled,
    isolatedProcessEnabled,
    appZygoteProcessEnabled,
    extensionsWebAPIEnabled,
    lnaBlocking,
    lnaBlockTrackers,
    lnaEnabled,
  ];
}
