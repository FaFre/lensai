/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

import 'package:pigeon/pigeon.dart';

/// Translation options that map to the Gecko Translations Options.
///
/// @property downloadModel If the necessary models should be downloaded on request. If false, then
/// the translation will not complete and throw an exception if the models are not already available.
class TranslationOptions {
  final bool downloadModel;

  TranslationOptions({this.downloadModel = true});
}

/// A language supported by the translation engine.
class TranslationLanguage {
  final String code;
  final String localizedDisplayName;

  TranslationLanguage({required this.code, required this.localizedDisplayName});
}

/// Detected languages for a page.
class TranslationDetectedLanguages {
  final String? documentLangTag;
  final bool? supportedDocumentLang;
  final String? userPreferredLangTag;

  TranslationDetectedLanguages({
    this.documentLangTag,
    this.supportedDocumentLang,
    this.userPreferredLangTag,
  });
}

/// A from/to language pair for translation.
class TranslationPair {
  final String fromLanguage;
  final String toLanguage;

  TranslationPair({required this.fromLanguage, required this.toLanguage});
}

/// Browser-level translation engine state (global).
class TranslationEngineStateData {
  final bool? isEngineSupported;
  final List<TranslationLanguage?>? fromLanguages;
  final List<TranslationLanguage?>? toLanguages;

  TranslationEngineStateData({
    this.isEngineSupported,
    this.fromLanguages,
    this.toLanguages,
  });
}

/// Per-tab translation state.
class TabTranslationStateData {
  final String tabId;
  final bool isTranslated;
  final bool isTranslateProcessing;
  final bool isOfferTranslate;
  final bool isExpectedTranslate;
  final String? detectedLanguageCode;
  final String? userPreferredLanguageCode;
  final String? requestedFromLanguage;
  final String? requestedToLanguage;
  final String? translationErrorName;
  final bool? displayError;

  TabTranslationStateData({
    required this.tabId,
    required this.isTranslated,
    required this.isTranslateProcessing,
    required this.isOfferTranslate,
    required this.isExpectedTranslate,
    this.detectedLanguageCode,
    this.userPreferredLanguageCode,
    this.requestedFromLanguage,
    this.requestedToLanguage,
    this.translationErrorName,
    this.displayError,
  });
}

/// Value type that represents the state of reader mode/view.
class ReaderState {
  /// Whether or not the current page can be transformed to
  /// be displayed in a reader view.
  final bool readerable;

  /// Whether or not reader view is active.
  final bool active;

  /// Whether or not a readerable check is required for the
  /// current page.
  final bool checkRequired;

  /// Whether or not a new connection to the reader view
  /// content script is required.
  final bool connectRequired;

  /// The base URL of the reader view extension page.
  final String? baseUrl;

  /// The URL of the page currently displayed in reader view.
  final String? activeUrl;

  /// The vertical scroll position of the page currently
  /// displayed in reader view.
  final int? scrollY;

  const ReaderState({
    this.readerable = false,
    this.active = false,
    this.checkRequired = false,
    this.connectRequired = false,
    this.baseUrl,
    this.activeUrl,
    this.scrollY,
  });
}

/// Parameters for adding a new tab.
class AddTabParams {
  final String url;
  final bool startLoading;
  final String? parentId;
  final LoadUrlFlagsValue flags;
  final String? contextId;
  final SourceValue source;
  final bool private;
  final HistoryMetadataKey? historyMetadata;
  final Map<String, String>? additionalHeaders;

  const AddTabParams({
    required this.url,
    required this.startLoading,
    this.parentId,
    required this.flags,
    this.contextId,
    required this.source,
    required this.private,
    this.historyMetadata,
    this.additionalHeaders,
  });
}

/// Details about the last playing media in this tab.
class LastMediaAccessState {
  /// [TabContentState.url] when media started playing.
  /// This is not the URL of the media but of the page when media started.
  /// Defaults to "" (an empty String) if media hasn't started playing.
  /// This value is only updated when media starts playing.
  /// Can be used as a backup to [mediaSessionActive] for knowing the user is still on the same website
  /// on which media was playing before media started playing in another tab.
  final String lastMediaUrl;

  /// The last time media started playing in the current web document.
  /// Defaults to [0] if media hasn't started playing.
  /// This value is only updated when media starts playing.
  final int lastMediaAccess;

  /// Whether or not the last accessed media is still active.
  /// Can be used as a backup to [lastMediaUrl] on websites which allow media to continue playing
  /// even when the users accesses another page (with another URL) in that same HTML document.
  final bool mediaSessionActive;

  const LastMediaAccessState({
    this.lastMediaUrl = "",
    this.lastMediaAccess = 0,
    this.mediaSessionActive = false,
  });
}

/// Represents a set of history metadata values that uniquely identify a record. Note that
/// when recording observations, the same set of values may or may not cause a new record to be
/// created, depending on the de-bouncing logic of the underlying storage i.e. recording history
/// metadata observations with the exact same values may be combined into a single record.
class HistoryMetadataKey {
  /// A url of the page.
  final String url;

  /// An optional search term if this record was
  /// created as part of a search by the user.
  final String? searchTerm;

  /// An optional url of the parent/referrer if
  /// this record was created in response to a user opening
  /// a page in a new tab.
  final String? referrerUrl;

  const HistoryMetadataKey({
    required this.url,
    this.searchTerm,
    this.referrerUrl,
  });
}

class PackageCategoryValue {
  final int value;

  const PackageCategoryValue(this.value);
}

/// Describes an external package.
class ExternalPackage {
  /// An Android package id.
  final String packageId;

  /// A [PackageCategory] as defined by the application.
  final PackageCategoryValue category;

  const ExternalPackage(this.packageId, this.category);
}

class LoadUrlFlagsValue {
  final int value;

  const LoadUrlFlagsValue(this.value);
}

class SourceValue {
  final int id;
  final ExternalPackage? caller;

  const SourceValue(this.id, this.caller);
}

/// A tab that is no longer open and in the list of tabs, but that can be restored (recovered) at
/// any time if it's combined with an [EngineSessionState] to form a [RecoverableTab].
///
/// The values of this data class are usually filled with the values of a [TabSessionState] when
/// getting closed.
class TabState {
  /// Unique ID identifying this tab.
  final String id;

  /// The last URL of this tab.
  final String url;

  /// The unique ID of the parent tab if this tab was opened from another tab (e.g. via
  /// the context menu).
  final String? parentId;

  /// The last title of this tab (or an empty String).
  final String title;

  /// The last used search terms, or an empty string if no
  /// search was executed for this session.
  final String searchTerm;

  /// The context ID ("container") this tab used (or null).
  final String? contextId;

  /// The last [ReaderState] of the tab.
  final ReaderState readerState;

  /// The last time this tab was selected.
  final int lastAccess;

  /// Timestamp of the tab's creation.
  final int createdAt;

  /// Details about the last time was playing in this tab.
  final LastMediaAccessState lastMediaAccessState;

  /// If tab was private.
  final bool private;

  /// The last [HistoryMetadataKey] of the tab.
  final HistoryMetadataKey? historyMetadata;

  /// The last [IconSource] of the tab.
  final SourceValue source;

  /// The index the tab should be restored at.
  final int index;

  /// Whether the tab has form data.
  final bool hasFormData;

  TabState({
    required this.id,
    required this.url,
    this.parentId,
    this.title = "",
    this.searchTerm = "",
    this.contextId,
    this.readerState = const ReaderState(),
    this.lastAccess = 0,
    this.createdAt = 0,
    this.lastMediaAccessState = const LastMediaAccessState(),
    this.private = false,
    this.historyMetadata,
    required this.source, //= Internal.none,
    this.index = -1,
    this.hasFormData = false,
  });
}

/// A recoverable version of [TabState].
class RecoverableTab {
  /// The [EngineSessionState] needed for restoring the previous state of this tab.
  final String? engineSessionStateJson;

  /// A [TabState] instance containing basic tab state.
  final TabState state;

  const RecoverableTab({this.engineSessionStateJson, required this.state});
}

/// Indicates what location the tabs should be restored at
enum RestoreLocation {
  /// Restore tabs at the beginning of the tab list
  beginning,

  /// Restore tabs at the end of the tab list
  end,

  /// Restore tabs at a specific index in the tab list
  atIndex,
}

/// An icon resource type.
enum IconType {
  favicon,
  appleTouchIcon,
  fluidIcon,
  imageSrc,
  openGraph,
  twitter,
  microsoftTile,
  manifestIcon,
}

/// Supported sizes.
///
/// We are trying to limit the supported sizes in order to optimize our caching strategy.
enum IconSize { defaultSize, launcher, launcherAdaptive }

/// A request to load an [Icon].
class IconRequest {
  final String url;
  final IconSize size;
  final List<Resource?> resources;
  final int? color;
  final bool isPrivate;
  final bool waitOnNetworkLoad;

  IconRequest({
    required this.url,
    this.size = IconSize.defaultSize,
    this.resources = const [],
    this.color,
    this.isPrivate = false,
    this.waitOnNetworkLoad = true,
  });
}

class ResourceSize {
  final int height;
  final int width;

  const ResourceSize({required this.height, required this.width});
}

/// An icon resource that can be loaded.
class Resource {
  final String url;
  final IconType type;
  final List<ResourceSize?> sizes;
  final String? mimeType;
  final bool maskable;

  Resource({
    required this.url,
    required this.type,
    this.sizes = const [],
    this.mimeType,
    this.maskable = false,
  });
}

/// An [Icon] returned by [BrowserIcons] after processing an [IconRequest]
class IconResult {
  /// The loaded icon as an [Uint8List].
  final Uint8List image;

  /// The dominant color of the icon. Will be null if no color could be extracted.
  final int? color;

  /// The source of the icon.
  final IconSource source;

  /// True if the icon represents as full-bleed icon that can be cropped to other shapes.
  final bool maskable;

  IconResult({
    required this.image,
    this.color,
    required this.source,
    this.maskable = false,
  });
}

/// The source of an [Icon].
enum IconSource {
  /// This icon was generated.
  generator,

  /// This icon was downloaded.
  download,

  /// This icon was inlined in the document.
  inline,

  /// This icon was loaded from an in-memory cache.
  memory,

  /// This icon was loaded from a disk cache.
  disk,
}

enum CookieSameSiteStatus { noRestriction, lax, strict, unspecified }

class CookiePartitionKey {
  final String topLevelSite;

  CookiePartitionKey(this.topLevelSite);
}

class Cookie {
  final String domain;
  final int? expirationDate;
  final String firstPartyDomain;
  final bool hostOnly;
  final bool httpOnly;
  final String name;
  final CookiePartitionKey? partitionKey;
  final String path;
  final bool secure;
  final bool session;
  final CookieSameSiteStatus sameSite;
  final String storeId;
  final String value;

  Cookie(
    this.domain,
    this.expirationDate,
    this.firstPartyDomain,
    this.hostOnly,
    this.httpOnly,
    this.name,
    this.partitionKey,
    this.path,
    this.secure,
    this.session,
    this.sameSite,
    this.storeId,
    this.value,
  );
}

enum VisitType {
  /// The user followed a link and got a new toplevel window.
  link,

  /// The user typed the page's URL in the URL bar or selected it from
  /// URL bar autocomplete results, clicked on it from a history query
  /// (from the History sidebar, History menu, or history query in the
  /// personal toolbar or Places organizer.
  typed,

  /// The user followed a bookmark to get to the page.
  bookmark,

  /// Some inner content is loaded. This is true of all images on a
  /// page, and the contents of the iframe. It is also true of any
  /// content in a frame if the user did not explicitly follow a link
  /// to get there.
  embed,

  /// Set when the transition was a permanent redirect.
  redirectPermanent,

  /// Set when the transition was a temporary redirect.
  redirectTemporary,

  /// Set when the transition is a download.
  download,

  /// The user followed a link and got a visit in a frame.
  framedLink,

  /// The user reloaded a page.
  reload,
}

class VisitInfo {
  final String url;
  final String? title;
  final int visitTime;
  final VisitType visitType;
  final String? previewImageUrl;
  final bool isRemote;

  final String? contentId;

  VisitInfo(
    this.url,
    this.title,
    this.visitTime,
    this.visitType,
    this.previewImageUrl,
    this.isRemote,
    this.contentId,
  );
}

class HistoryHighlightWeights {
  final double viewTime;
  final double frequency;

  HistoryHighlightWeights(this.viewTime, this.frequency);
}

class HistoryHighlight {
  final double score;
  final int placeId;
  final String url;
  final String? title;
  final String? previewImageUrl;

  HistoryHighlight(
    this.score,
    this.placeId,
    this.url,
    this.title,
    this.previewImageUrl,
  );
}

class TopFrecentSiteInfo {
  final String url;
  final String? title;

  TopFrecentSiteInfo(this.url, this.title);
}

enum FrecencyThresholdOption { none, skipOneTimePages }

/// Document type associated with a [HistoryMetadata] record.
enum DocumentType { regular, media }

/// Per-URL metadata maintained by Places. The unique identity of a record is
/// [HistoryMetadataKey] (url + searchTerm + referrerUrl); we surface only the
/// most recent record per URL via `getLatestHistoryMetadataForUrl`.
class HistoryMetadata {
  final HistoryMetadataKey key;
  final String? title;

  /// Unix milliseconds.
  final int createdAt;

  /// Unix milliseconds.
  final int updatedAt;

  /// Total view time in milliseconds.
  final int totalViewTime;

  final DocumentType documentType;
  final String? previewImageUrl;

  HistoryMetadata(
    this.key,
    this.title,
    this.createdAt,
    this.updatedAt,
    this.totalViewTime,
    this.documentType,
    this.previewImageUrl,
  );
}

/// Frecency-ranked autocomplete suggestion. Backs `getSuggestions`.
class HistorySuggestion {
  final String url;
  final String? title;

  /// Larger is more relevant. Unbounded; only meaningful relative to other
  /// suggestions returned in the same call.
  final int score;

  HistorySuggestion(this.url, this.title, this.score);
}

/// Optional metadata observation for a URL. `null` fields are not written.
class PageObservation {
  final String? title;
  final String? previewImageUrl;

  PageObservation({this.title, this.previewImageUrl});
}

class HistoryItem {
  final String url;
  final String title;

  HistoryItem(this.url, this.title);
}

class HistoryState {
  final List<HistoryItem?> items;
  final int currentIndex;

  final bool canGoBack;
  final bool canGoForward;

  HistoryState(
    this.items,
    this.currentIndex,
    this.canGoBack,
    this.canGoForward,
  );
}

class ReaderableState {
  /// Whether or not the current page can be transformed to
  /// be displayed in a reader view.
  final bool readerable;

  /// Whether or not reader view is active.
  final bool active;

  ReaderableState(this.readerable, this.active);
}

class SecurityInfoState {
  final bool secure;
  final String host;
  final String issuer;

  SecurityInfoState(this.secure, this.host, this.issuer);
}

class TabContentState {
  final String id;
  final String? parentId;
  final String? contextId;

  final String url;
  final String title;

  final int progress;

  final bool isPrivate;
  final bool isFullScreen;
  final bool isLoading;
  final bool showToolbarAsExpanded;

  TabContentState(
    this.id,
    this.parentId,
    this.contextId,
    this.url,
    this.title,
    this.progress,
    this.isPrivate,
    this.isFullScreen,
    this.isLoading,
    this.showToolbarAsExpanded,
  );
}

class FindResultState {
  final int activeMatchOrdinal;
  final int numberOfMatches;
  final bool isDoneCounting;

  FindResultState(
    this.activeMatchOrdinal,
    this.numberOfMatches,
    this.isDoneCounting,
  );
}

enum SelectionPattern { phone, email }

class CustomSelectionAction {
  final String id;
  final String title;
  final SelectionPattern? pattern;

  CustomSelectionAction(this.id, this.title, this.pattern);
}

enum WebExtensionActionType { browser, page }

class WebExtensionData {
  final String extensionId;
  final String? title;
  final bool? enabled;
  final String? badgeText;
  final int? badgeTextColor;
  final int? badgeBackgroundColor;

  WebExtensionData(
    this.extensionId,
    this.title,
    this.enabled,
    this.badgeText,
    this.badgeTextColor,
    this.badgeBackgroundColor,
  );
}

enum AddonDisabledReason {
  unsupported,
  blocklisted,
  userRequested,
  notCorrectlySigned,
  incompatible,
  softBlocked,
}

enum AddonIncognito { spanning, split, notAllowed }

enum AddonUpdateStatus {
  notInstalled,
  successfullyUpdated,
  noUpdateAvailable,
  error,
}

class AddonInfo {
  final String id;
  final String displayName;
  final String? summary;
  final String description;
  final String downloadUrl;
  final String version;
  final String? installedVersion;
  final List<String> translatedPermissions;
  final List<String> translatedRequiredDataCollectionPermissions;
  final String? authorName;
  final String? authorUrl;
  final String homepageUrl;
  final String detailUrl;
  final String ratingUrl;
  final double? ratingAverage;
  final int? ratingReviews;
  final String createdAt;
  final String updatedAt;
  final Uint8List? icon;
  final bool isInstalled;
  final bool isEnabled;
  final bool isSupported;
  final bool isAllowedInPrivateBrowsing;
  final bool isAutoUpdateEnabled;
  final bool isLocalFileInstalled;
  final String? optionsPageUrl;
  final bool openOptionsPageInTab;
  final AddonDisabledReason? disabledReason;
  final AddonIncognito incognito;

  const AddonInfo({
    required this.id,
    required this.displayName,
    this.summary,
    required this.description,
    required this.downloadUrl,
    required this.version,
    this.installedVersion,
    required this.translatedPermissions,
    required this.translatedRequiredDataCollectionPermissions,
    this.authorName,
    this.authorUrl,
    required this.homepageUrl,
    required this.detailUrl,
    required this.ratingUrl,
    this.ratingAverage,
    this.ratingReviews,
    required this.createdAt,
    required this.updatedAt,
    this.icon,
    required this.isInstalled,
    required this.isEnabled,
    required this.isSupported,
    required this.isAllowedInPrivateBrowsing,
    required this.isAutoUpdateEnabled,
    required this.isLocalFileInstalled,
    this.optionsPageUrl,
    required this.openOptionsPageInTab,
    this.disabledReason,
    this.incognito = AddonIncognito.spanning,
  });
}

enum AddonStoreApp { android, firefox }

enum AddonStorePromoted { none, recommended, line }

class AddonListingPreview {
  final String imageUrl;
  final String? thumbnailUrl;
  final String? caption;

  const AddonListingPreview({
    required this.imageUrl,
    this.thumbnailUrl,
    this.caption,
  });
}

class AddonListing {
  final String id;
  final String name;
  final String? summary;
  final String? description;
  final String? iconUrl;
  final String latestVersion;
  final String downloadUrl;
  final double? ratingAverage;
  final int? ratingReviews;
  final String? authorName;
  final String? authorUrl;
  final String? homepageUrl;
  final String detailUrl;
  final String? ratingUrl;
  final int? averageDailyUsers;
  final AddonStorePromoted promoted;
  final List<AddonListingPreview> previews;
  final List<String> permissions;
  final List<String> hostPermissions;
  final List<String> optionalPermissions;
  final List<String> dataCollectionPermissions;
  final int? fileSize;
  final String? lastUpdated;
  final String? licenseName;
  final String? licenseUrl;
  final String? supportUrl;
  final String? supportEmail;
  final List<String> categories;
  final bool hasPrivacyPolicy;
  final String? slug;

  const AddonListing({
    required this.id,
    required this.name,
    this.summary,
    this.description,
    this.iconUrl,
    required this.latestVersion,
    required this.downloadUrl,
    this.ratingAverage,
    this.ratingReviews,
    this.authorName,
    this.authorUrl,
    this.homepageUrl,
    required this.detailUrl,
    this.ratingUrl,
    this.averageDailyUsers,
    this.promoted = AddonStorePromoted.none,
    this.previews = const [],
    this.permissions = const [],
    this.hostPermissions = const [],
    this.optionalPermissions = const [],
    this.dataCollectionPermissions = const [],
    this.fileSize,
    this.lastUpdated,
    this.licenseName,
    this.licenseUrl,
    this.supportUrl,
    this.supportEmail,
    this.categories = const [],
    this.hasPrivacyPolicy = false,
    this.slug,
  });
}

class AddonStoreInfo {
  final String latestVersion;
  final String latestXpiUrl;
  final double? ratingAverage;
  final int? ratingReviews;
  final String? summary;
  final String? description;
  final String? homepageUrl;
  final String? detailUrl;
  final String? ratingUrl;
  final String? authorName;
  final String? authorUrl;

  const AddonStoreInfo({
    required this.latestVersion,
    required this.latestXpiUrl,
    this.ratingAverage,
    this.ratingReviews,
    this.summary,
    this.description,
    this.homepageUrl,
    this.detailUrl,
    this.ratingUrl,
    this.authorName,
    this.authorUrl,
  });
}

class AddonUpdateAttemptInfo {
  final String addonId;
  final int dateMillisecondsSinceEpoch;
  final AddonUpdateStatus? status;
  final String? message;

  const AddonUpdateAttemptInfo({
    required this.addonId,
    required this.dateMillisecondsSinceEpoch,
    this.status,
    this.message,
  });
}

enum GeckoSuggestionType { session, clipboard, history }

class GeckoSuggestion {
  final String id;
  final GeckoSuggestionType type;
  final int score;
  final String? title;
  final String? description;
  final String? editSuggestion;
  final Uint8List? icon;

  GeckoSuggestion(
    this.id,
    this.type,
    this.score,
    this.title,
    this.description,
    this.editSuggestion,
    this.icon,
  );
}

class TabContent {
  final String tabId;
  final String? fullContentMarkdown;
  final String? fullContentPlain;
  final bool isProbablyReaderable;
  final String? extractedContentMarkdown;
  final String? extractedContentPlain;

  TabContent(
    this.tabId,
    this.fullContentMarkdown,
    this.fullContentPlain,
    this.isProbablyReaderable,
    this.extractedContentMarkdown,
    this.extractedContentPlain,
  );
}

enum TrackingProtectionPolicy { none, recommended, strict, custom }

enum HttpsOnlyMode { disabled, privateOnly, enabled }

enum QueryParameterStripping { disabled, privateOnly, enabled }

enum BounceTrackingProtectionMode {
  /// Fully disabled.
  disabled,

  /// Fully enabled.
  enabled,

  /// Disabled, but collects user interaction data. Use this mode as the
  /// "disabled" state when the feature can be toggled on and off, e.g. via
  /// preferences.
  enabledStandby,

  /// Feature enabled, but tracker purging is only simulated. Used for
  /// testing and telemetry collection.
  enabledDryRun,
}

enum ColorScheme { system, light, dark }

// Dead since AC/Gecko 155 removed cookie banner handling (bug 2058143). Nothing
// reads these any more; drop them (and the `cookieBannerHandling*` fields of
// GeckoEngineSettings below)
enum CookieBannerHandlingMode { disabled, rejectAll, rejectOrAcceptAll }

/// App links behavior mode - controls how external app links are handled
enum AppLinksMode {
  /// Always open links in their native apps without prompting
  always,

  /// Prompt user before opening in app (with "Always open" checkbox)
  ask,

  /// Never open links in external apps, always use browser
  never,
}

/// Cookie blocking policy for Custom tracking protection mode.
/// Note: These only apply when blockCookies is true.
enum CustomCookiePolicy {
  /// Total Cookie Protection - Dynamic First-Party Isolation (dFPI)
  /// Most private option, isolates cookies per site
  totalProtection,

  /// Block cross-site and social media tracker cookies
  /// Allows most cookies but blocks tracking cookies
  crossSiteTrackers,

  /// Block cookies from sites you haven't visited
  /// Balances privacy with functionality
  unvisited,

  /// Block all third-party cookies
  /// Only allows first-party cookies
  thirdParty,

  /// Block all cookies (may break many sites)
  allCookies,
}

/// Scope for applying tracking protection features
enum TrackingScope {
  /// Apply to all browsing (normal + private)
  all,

  /// Apply only to private browsing tabs
  privateOnly,
}

class ContentBlocking {
  QueryParameterStripping queryParameterStripping;
  String queryParameterStrippingAllowList;
  String queryParameterStrippingStripList;
  BounceTrackingProtectionMode bounceTrackingProtectionMode;

  ContentBlocking(
    this.queryParameterStripping,
    this.queryParameterStrippingAllowList,
    this.queryParameterStrippingStripList,
    this.bounceTrackingProtectionMode,
  );
}

enum DohSettingsMode { geckoDefault, increased, max, off }

class DohSettings {
  final DohSettingsMode dohSettingsMode;
  final String dohProviderUrl;
  final String dohDefaultProviderUrl;
  final List<String> dohExceptionsList;

  DohSettings(
    this.dohSettingsMode,
    this.dohProviderUrl,
    this.dohDefaultProviderUrl,
    this.dohExceptionsList,
  );
}

class GeckoEngineSettings {
  final bool? javascriptEnabled;
  final TrackingProtectionPolicy? trackingProtectionPolicy;
  final HttpsOnlyMode? httpsOnlyMode;
  final bool? globalPrivacyControlEnabled;
  final ColorScheme? preferredColorScheme;
  final CookieBannerHandlingMode? cookieBannerHandlingMode;
  final CookieBannerHandlingMode? cookieBannerHandlingModePrivateBrowsing;
  final bool? cookieBannerHandlingGlobalRules;
  final bool? cookieBannerHandlingGlobalRulesSubFrames;
  final String? userAgent;
  final ContentBlocking? contentBlocking;
  final bool? enterpriseRootsEnabled;
  final DohSettings? dohSettings;
  final String? fingerprintingProtectionOverrides;
  final List<String>? locales;

  /// Use GeckoView's content-blocking database for tracking protection.
  /// This is applied when the engine is created and requires app restart.
  final bool? useContentBlockingDatabase;

  // Custom Tracking Protection Settings
  /// Master toggle for cookie blocking in Custom mode
  final bool? blockCookies;

  /// Cookie policy selection (only applies when blockCookies is true)
  final CustomCookiePolicy? customCookiePolicy;

  /// Block tracking scripts and content
  final bool? blockTrackingContent;

  /// Scope for tracking content blocking
  final TrackingScope? trackingContentScope;

  /// Block cryptomining scripts
  final bool? blockCryptominers;

  /// Block known fingerprinters (FINGERPRINTING tracking category)
  final bool? blockFingerprinters;

  /// Block redirect trackers via cookie purging
  final bool? blockRedirectTrackers;

  /// Block suspected fingerprinters (separate from FINGERPRINTING category)
  /// Controls GeckoView's fingerprintingProtection settings
  final bool? blockSuspectedFingerprinters;

  /// Scope for suspected fingerprinters blocking
  final TrackingScope? suspectedFingerprintersScope;

  /// Allow baseline tracking protection exceptions (prevents major site breakage)
  final bool? allowListBaseline;

  /// Allow convenience tracking protection exceptions (fixes minor issues)
  final bool? allowListConvenience;

  /// Block advertising, analytics, social, and Mozilla social trackers
  final bool? blockAdsAnalyticsSocialTrackers;

  // Web Content Settings
  final bool? webFontsEnabled;
  final bool? automaticFontSizeAdjustment;
  final double? fontSizeFactor;
  final bool? fontInflationEnabled;
  final double? displayDensityOverride;
  final int? screenWidthOverride;
  final int? screenHeightOverride;
  final bool? inputAutoZoomEnabled;

  /// Forces pinch-to-zoom to work even on websites that set
  /// `user-scalable=no` (or a restrictive `maximum-scale`) on the viewport.
  final bool? forceUserScalableContent;

  // Process Isolation Settings (require app restart)
  final bool? fissionEnabled;
  final bool? isolatedProcessEnabled;
  final bool? appZygoteProcessEnabled;
  final bool? extensionsWebAPIEnabled;

  // Local Network Access (LNA) Settings
  final bool? lnaBlocking;
  final bool? lnaBlockTrackers;
  final bool? lnaEnabled;

  GeckoEngineSettings(
    this.javascriptEnabled,
    this.trackingProtectionPolicy,
    this.httpsOnlyMode,
    this.globalPrivacyControlEnabled,
    this.preferredColorScheme,
    this.cookieBannerHandlingMode,
    this.cookieBannerHandlingModePrivateBrowsing,
    this.cookieBannerHandlingGlobalRules,
    this.cookieBannerHandlingGlobalRulesSubFrames,
    this.userAgent,
    this.contentBlocking,
    this.enterpriseRootsEnabled,
    this.dohSettings,
    this.fingerprintingProtectionOverrides,
    this.locales,
    this.useContentBlockingDatabase,
    this.blockCookies,
    this.customCookiePolicy,
    this.blockTrackingContent,
    this.trackingContentScope,
    this.blockCryptominers,
    this.blockFingerprinters,
    this.blockRedirectTrackers,
    this.blockSuspectedFingerprinters,
    this.suspectedFingerprintersScope,
    this.allowListBaseline,
    this.allowListConvenience,
    this.blockAdsAnalyticsSocialTrackers,
    this.webFontsEnabled,
    this.automaticFontSizeAdjustment,
    this.fontSizeFactor,
    this.fontInflationEnabled,
    this.displayDensityOverride,
    this.screenWidthOverride,
    this.screenHeightOverride,
    this.inputAutoZoomEnabled,
    this.forceUserScalableContent,
    this.fissionEnabled,
    this.isolatedProcessEnabled,
    this.appZygoteProcessEnabled,
    this.extensionsWebAPIEnabled,
    this.lnaBlocking,
    this.lnaBlockTrackers,
    this.lnaEnabled,
  );
}

class AutocompleteResult {
  final String input;
  final String text;
  final String url;
  final String source;
  final int totalItems;

  AutocompleteResult(
    this.input,
    this.text,
    this.url,
    this.source,
    this.totalItems,
  );
}

/// Represents all the different supported types of data that can be found from long clicking
/// an element.
sealed class HitResult {}

/// Default type if we're unable to match the type to anything. It may or may not have a src.
class UnknownHitResult extends HitResult {
  final String src;
  final String? linkText;

  UnknownHitResult(this.src, {this.linkText});
}

/// If the HTML element was of type 'HTMLImageElement'.
class ImageHitResult extends HitResult {
  final String src;
  final String? title;

  ImageHitResult(this.src, {this.title});
}

/// If the HTML element was of type 'HTMLVideoElement'.
class VideoHitResult extends HitResult {
  final String src;
  final String? title;

  VideoHitResult(this.src, {this.title});
}

/// If the HTML element was of type 'HTMLAudioElement'.
class AudioHitResult extends HitResult {
  final String src;
  final String? title;

  AudioHitResult(this.src, {this.title});
}

/// If the HTML element was of type 'HTMLImageElement' and contained a URI.
class ImageSrcHitResult extends HitResult {
  final String src;
  final String uri;

  ImageSrcHitResult(this.src, this.uri);
}

/// The type used if the URI is prepended with 'tel:'.
class PhoneHitResult extends HitResult {
  final String src;

  PhoneHitResult(this.src);
}

/// The type used if the URI is prepended with 'mailto:'.
class EmailHitResult extends HitResult {
  final String src;

  EmailHitResult(this.src);
}

/// The type used if the URI is prepended with 'geo:'.
class GeoHitResult extends HitResult {
  final String src;

  GeoHitResult(this.src);
}

/// Status that represents every state that a download can be in.
enum DownloadStatus {
  /// Indicates that the download is in the first state after creation but not yet [DOWNLOADING].
  initiated,

  /// Indicates that an [INITIATED] download is now actively being downloaded.
  downloading,

  /// Indicates that the download that has been [DOWNLOADING] has been paused.
  paused,

  /// Indicates that the download that has been [DOWNLOADING] has been cancelled.
  cancelled,

  /// Indicates that the download that has been [DOWNLOADING] has moved to failed because
  /// something unexpected has happened.
  failed,

  /// Indicates that the [DOWNLOADING] download has been completed.
  completed,
}

class DownloadState {
  final String url;
  final String? fileName;
  final String? contentType;
  final int? contentLength;
  final int? currentBytesCopied;
  final DownloadStatus? status;
  final String? userAgent;
  final String? destinationDirectory;
  final String? directoryPath;
  final String? referrerUrl;
  final bool? skipConfirmation;
  final bool? openInApp;
  final String? id;
  final String? sessionId;
  final bool? private;
  final int? createdTime;
  //final Response? response;
  final int? notificationId;

  DownloadState(
    this.url,
    this.fileName,
    this.contentType,
    this.contentLength,
    this.currentBytesCopied,
    this.status,
    this.userAgent,
    this.destinationDirectory,
    this.directoryPath,
    this.referrerUrl,
    this.skipConfirmation,
    this.openInApp,
    this.id,
    this.sessionId,
    this.private,
    this.createdTime,
    this.notificationId,
  );
}

class ShareInternetResourceState {
  final String url;
  final String? contentType;
  final bool private;
  // final Response? response ;
  final String? referrerUrl;

  ShareInternetResourceState(
    this.url,
    this.contentType,
    this.private,
    this.referrerUrl,
  );
}

enum LogLevel { debug, info, warn, error }

class AddonCollection {
  final String serverURL;
  final String collectionUser;
  final String collectionName;

  AddonCollection({
    required this.serverURL,
    required this.collectionUser,
    required this.collectionName,
  });
}

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/pigeons/gecko.g.dart',
    dartOptions: DartOptions(),
    kotlinOut:
        'android/src/main/kotlin/eu/weblibre/flutter_mozilla_components/pigeons/Gecko.g.kt',
    kotlinOptions: KotlinOptions(
      package: 'eu.weblibre.flutter_mozilla_components.pigeons',
    ),
    dartPackageName: 'flutter_mozilla_components',
  ),
)
@HostApi()
abstract class GeckoBrowserApi {
  String getGeckoVersion();
  // [startupUBlockFilterListsPref] is the JSON-encoded value to write to the
  // managed-storage pref read by uBlock Origin at extension startup. The pref
  // must be written before the extension registers, so it is plumbed through
  // initialize rather than set later.
  // If [clearStartupUBlockFilterListsPref] is true, the pref is cleared and
  // [startupUBlockFilterListsPref] is ignored. If both are unset/false, the
  // pref is left untouched.
  void initialize(
    String profileFolder,
    LogLevel logLevel,
    ContentBlocking contentBlocking,
    AddonCollection? addonCollection,
    String? fxaServerOverride,
    String? syncTokenServerOverride,
    GeckoEngineSettings? startupSettings,
    String? startupUBlockFilterListsPref,
    bool clearStartupUBlockFilterListsPref,
  );
  bool showNativeFragment();
  void onTrimMemory(int level);
  void openInCustomTab({
    required String url,
    required bool private,
    required String? contextId,
  });
  bool isDefaultBrowser();
  void requestDefaultBrowser();
  void shutdown();
}

enum SyncEngineValue { history, bookmarks, tabs }

class SyncEngineStatus {
  final SyncEngineValue engine;
  final bool enabled;

  SyncEngineStatus({required this.engine, required this.enabled});
}

class SyncAccountInfo {
  final bool authenticated;
  final bool syncing;
  final bool needsReauth;
  final String? email;
  final String? displayName;
  final int? lastSyncedAt;
  final List<SyncEngineStatus> engines;

  SyncAccountInfo({
    required this.authenticated,
    required this.syncing,
    required this.needsReauth,
    required this.email,
    required this.displayName,
    required this.lastSyncedAt,
    required this.engines,
  });
}

class SyncDevice {
  final String deviceId;
  final String displayName;
  final bool isCurrentDevice;
  final bool canSendTab;

  SyncDevice({
    required this.deviceId,
    required this.displayName,
    required this.isCurrentDevice,
    required this.canSendTab,
  });
}

class SyncIncomingTab {
  final String title;
  final String url;
  final String? fromDeviceId;
  final String? fromDeviceName;

  SyncIncomingTab({
    required this.title,
    required this.url,
    required this.fromDeviceId,
    required this.fromDeviceName,
  });
}

class SyncRemoteTab {
  final String title;
  final String url;
  final String? iconUrl;
  final int lastUsed;
  final bool inactive;

  SyncRemoteTab({
    required this.title,
    required this.url,
    required this.iconUrl,
    required this.lastUsed,
    required this.inactive,
  });
}

class SyncDeviceTabs {
  final String deviceId;
  final String deviceName;
  final List<SyncRemoteTab> tabs;

  SyncDeviceTabs({
    required this.deviceId,
    required this.deviceName,
    required this.tabs,
  });
}

@HostApi()
abstract class GeckoSyncApi {
  @async
  SyncAccountInfo getAccountInfo();

  @async
  void beginAuthentication();

  @async
  void beginPairingAuthentication(String pairingUrl);

  @async
  void logout();

  @async
  void syncNow();

  @async
  void setEngineEnabled(SyncEngineValue engine, bool enabled);

  @async
  List<SyncDeviceTabs> getSyncedTabs();

  @async
  List<SyncDevice> getDevices();

  @async
  bool sendTabToDevice(String deviceId, String title, String url, bool private);

  @async
  void refreshDevices();

  @async
  void pollDeviceCommands();

  @async
  List<SyncIncomingTab> drainIncomingTabs();

  @async
  String? getDeviceName();

  @async
  bool setDeviceName(String newName);
}

@HostApi()
abstract class GeckoEngineSettingsApi {
  void setDefaultSettings(GeckoEngineSettings settings);
  void updateRuntimeSettings(GeckoEngineSettings settings);
  void setScreenshotProtectionEnabled(bool enabled);

  /// Lifts the secure-window restriction that private tabs apply by default,
  /// allowing system screenshots and screen recording of private tabs.
  /// [setScreenshotProtectionEnabled] still wins when both are enabled.
  void setAllowPrivateTabScreenshots(bool allow);
  void setPullToRefreshEnabled(bool enabled);

  /// Sets whether to use external download managers for downloads.
  /// When enabled, downloads are forwarded to third-party apps like ADM, 1DM, AB DM.
  void setUseExternalDownloadManager(bool enabled);

  bool getUseExternalDownloadManager();

  /// Sets the browser-wide default desktop mode (BrowserState.desktopMode).
  /// Newly opened tabs inherit this default; a per-tab requestDesktopSite
  /// still overrides it for that tab.
  ///
  /// When [applyToExistingTabs] is true, the new value is also applied to all
  /// currently open tabs (loaded tabs are reloaded, suspended tabs are updated
  /// in place). This should only be requested for an explicit user toggle, not
  /// during startup/replication restore, to avoid clobbering per-tab overrides.
  void setGlobalDesktopMode(bool enable, bool applyToExistingTabs);

  /// Sets whether the reader view dark color scheme should be rendered as pure
  /// black (AMOLED). Mirrors WebLibre's "pure black" theme setting into
  /// Mozilla's reader view extension. Persisted in SharedPreferences so a
  /// cold-started reader view resolves the right value before Flutter runs.
  void setReaderViewPureBlack(bool enabled);

  /// Snapshot of which sessions must NOT write to Mozilla Places (hard
  /// exclude-from-history / "incognito container"). Every engine session runs a
  /// tab-scoped history delegate that consults this snapshot, so the decision is
  /// made per tab rather than guessed from the visited URL.
  ///
  /// [excludedTabIds] are the tabs whose container has exclude-from-history on.
  /// [knownTabIds] is every tab WebLibre has a row for: a tab outside this set is
  /// one Dart hasn't seen yet (e.g. a `window.open` child), for which native
  /// falls back to inheriting the opener's exclusion. [excludedContextIds] are
  /// the Gecko contextual identities of excluded containers, used as a
  /// fallback before the first snapshot arrives (cold start / headless path).
  void setHistoryExclusions(
    List<String> excludedTabIds,
    List<String> knownTabIds,
    List<String> excludedContextIds,
  );
}

@HostApi()
abstract class GeckoSessionApi {
  void loadUrl({
    required String? tabId, //If null = current tab
    required String url,
    required LoadUrlFlagsValue flags, //== LoadUrlFlagsBuilder.NONE,
    required Map<String, String>? additionalHeaders,
  });

  void loadData({
    required String? tabId, //If null = current tab
    required String data,
    required String mimeType,
    required String encoding,
  });

  void reload({
    required String? tabId, //If null = current tab
    required LoadUrlFlagsValue flags, //== LoadUrlFlagsBuilder.NONE,
  });

  void stopLoading({
    required String? tabId, //If null = current tab
  });

  void goBack({
    required String? tabId, //If null = current tab
    required bool userInteraction,
  });

  void goForward({
    required String? tabId, //If null = current tab
    required bool userInteraction,
  });

  void goToHistoryIndex({
    required int index,
    required String? tabId, //If null = current tab
  });

  void requestDesktopSite({
    required String? tabId, //If null = current tab
    required bool enable,
  });

  void exitFullscreen({
    required String? tabId, //If null = current tab
  });

  void saveToPdf({
    required String? tabId, //If null = current tab
  });

  void printContent({
    required String? tabId, //If null = current tab
  });

  void translate({
    required String? tabId, //If null = current tab
    required String fromLanguage,
    required String toLanguage,
    required TranslationOptions? options,
  });

  void translateRestore({
    required String? tabId, //If null = current tab
  });

  void crashRecovery({required List<String>? tabIds});

  void purgeHistory();

  void updateLastAccess({
    required String? tabId, //If null = current tab
    required int? lastAccess, //If null datetime.now
  });

  @async
  Uint8List? requestScreenshot(bool sendBack);

  void dispatchKeyEvent({required int keyCode});
}

@HostApi()
abstract class GeckoTabsApi {
  void syncEvents({
    required bool onSelectedTabChange,
    required bool onTabListChange,
    required bool onRestoreComplete,
    required bool onTabContentStateChange,
    required bool onIconChange,
    required bool onSecurityInfoStateChange,
    required bool onReaderableStateChange,
    required bool onHistoryStateChange,
    required bool onFindResults,
    required bool onThumbnailChange,
    required bool onBrowserExtensionsChange,
    required bool onPageExtensionsChange,
    required bool onBrowserExtensionIcons,
    required bool onPageExtensionIcons,
    required bool onTranslationStateChange,
  });

  void selectTab({required String tabId});

  void removeTab({required String tabId});

  String addTab({
    required String url,
    required bool selectTab,
    required bool startLoading,
    required String? parentId,
    required LoadUrlFlagsValue flags,
    required String? contextId,
    //engineSession: EngineSession? = null,
    required SourceValue source, //Internal.NewTab
    //searchTerms: String = "",
    required bool private,
    required HistoryMetadataKey? historyMetadata,
    //isSearch: Boolean = false,
    //searchEngineName: String? = null,
    required Map<String, String>? additionalHeaders,

    /// Whether the container this tab is being created in is excluded from
    /// history. Applied before the tab starts loading, so the first visit can't
    /// outrun the exclusion snapshot Dart pushes once the tab is persisted.
    required bool excludeFromHistory,
  });

  List<String> addMultipleTabs({
    required List<AddTabParams> tabs,
    required String? selectTabId,

    /// Whether the container these tabs are being created in is excluded from
    /// history. One value for the batch: they all land in the same container.
    /// See `addTab`.
    required bool excludeFromHistory,
  });

  void removeAllTabs({required bool recoverable});

  void removeTabs({required List<String> ids});

  void removeNormalTabs();

  void removePrivateTabs();

  void undo();

  //restoreTabs invokes splitted
  void restoreTabsByList({
    required List<RecoverableTab> tabs,
    required String? selectTabId,
    required RestoreLocation restoreLocation,
  });
  //The calls with engin storage for restore are not supported at the moment

  //selectOrAddTab invokes splitted
  /// Selects an already existing tab with the matching [HistoryMetadataKey] or otherwise
  /// creates a new tab with the given [url].
  String selectOrAddTabByHistory({
    required String url,
    required HistoryMetadataKey historyMetadata,
  });

  /// Selects an already existing tab displaying [url] or otherwise creates a new tab.
  String selectOrAddTabByUrl({
    required String url,
    required bool private,
    required SourceValue source, // = Internal.newTab,
    required LoadUrlFlagsValue flags,
    required bool ignoreFragment,
  });

  String duplicateTab({
    required String? selectTabId,
    required bool selectNewTab,
    required String? newContextId,

    /// Whether the container the duplicate is being created in is excluded from
    /// history. Cannot be inherited from the source tab: a duplicate can be sent
    /// to a different container than the one it was copied from. See `addTab`.
    required bool excludeFromHistory,
  });

  void moveTabs({
    required List<String> tabIds,
    required String targetTabId,
    required bool placeAfter,
  });

  String migratePrivateTabUseCase({
    required String tabId,
    required String? alternativeUrl,
  });
}

@HostApi()
abstract class GeckoFindApi {
  void findAll(String? tabId, String text);
  void findNext(String? tabId, bool forward);
  void clearMatches(String? tabId);
}

@HostApi()
abstract class GeckoIconsApi {
  @async
  IconResult loadIcon(IconRequest request);
}

class GeckoPref {
  final String name;
  final Object? value;
  final Object? defaultValue;
  final Object? userValue;
  final bool hasUserChangedValue;

  GeckoPref(
    this.name,
    this.value,
    this.defaultValue,
    this.userValue,
    this.hasUserChangedValue,
  );
}

@HostApi()
abstract class GeckoPrefApi {
  @async
  Map<String, GeckoPref> getPrefs(List<String> preferenceFilter);
  @async
  Map<String, GeckoPref> applyPrefs(Map<String, Object> prefs);
  @async
  void resetPrefs(List<String> preferenceNames);

  void startObserveChanges();
  void stopObserveChanges();
  @async
  void registerPrefForObservation(String name);
  @async
  void unregisterPrefForObservation(String name);
}

/// Type of ML model operation
enum MlProgressType { downloading, loadingFromCache, runningInference }

/// Status of the ML operation
enum MlProgressStatus { initiate, sizeEstimate, inProgress, done }

/// Progress information for ML model operations
class MlProgressData {
  /// The type of ML model being loaded
  final String modelType;

  /// Percentage of completion (0-100)
  final double progress;

  /// Type of operation (download, cache load, or inference)
  final MlProgressType type;

  /// Current status of the operation
  final MlProgressStatus status;

  /// Total bytes loaded so far
  final int totalLoaded;

  /// Bytes loaded in current update
  final int currentLoaded;

  /// Total size estimate
  final int total;

  /// Units of measurement (e.g., "bytes")
  final String units;

  /// Whether the operation completed successfully
  final bool ok;

  /// Unique identifier for this operation
  final String? id;

  const MlProgressData({
    required this.modelType,
    required this.progress,
    required this.type,
    required this.status,
    required this.totalLoaded,
    required this.currentLoaded,
    required this.total,
    required this.units,
    required this.ok,
    this.id,
  });
}

@HostApi()
abstract class GeckoMlApi {
  @async
  String predictDocumentTopic(List<String> documents);
  @async
  List generateDocumentEmbeddings(List<String> documents);
  @async
  void clearMlCache();
}

@HostApi()
abstract class GeckoBrowserExtensionApi {
  @async
  List<Object> getMarkdown(List<String> htmlList);
}

class GeckoProxySettings {
  final String id;
  final String title;
  final String type;
  final String host;
  final int port;
  final String? username;
  final String? password;
  final bool proxyDNS;
  final bool doNotProxyLocal;

  const GeckoProxySettings({
    required this.id,
    required this.title,
    required this.type,
    required this.host,
    required this.port,
    this.username,
    this.password,
    this.proxyDNS = true,
    this.doNotProxyLocal = true,
  });
}

/// The complete container routing state, as owned by the app.
///
/// The proxy extension's store is memory-only: it dies with the background
/// script and starts empty, and an empty store routes every request directly.
/// Incremental mutation messages can therefore never establish routing safely —
/// they are unacknowledged, and a store that lost them looks identical to one
/// that was deliberately configured for direct connections. A snapshot replaces
/// the extension's whole state at once and is acknowledged, so both sides can
/// agree on what is installed.
class GeckoProxyRoutingSnapshot {
  /// Monotonic counter identifying this snapshot. Echoed back on acknowledgement.
  final int generation;

  /// Every proxy endpoint currently available, keyed by [GeckoProxySettings.id].
  final List<GeckoProxySettings> proxies;

  /// Cookie-store context to the proxy ids it routes through. An empty list is
  /// an explicit direct connection, which is distinct from having no entry.
  final Map<String, List<String>> relations;

  /// Scope ids for explicitly-direct contexts, used to decide which direct
  /// contexts count as equivalent for site-assignment purposes.
  final Map<String, String> directScopes;

  /// Assigned site origin to the context it belongs to.
  final Map<String, String> siteAssignments;

  /// Strict-mode enforcement map. Keys are Gecko cookie-store contexts to
  /// enforce (a strict container's base context plus its isolated tabs'
  /// isolation contexts); each value contains the container base contexts that
  /// site assignments are keyed on. Tabs in these contexts may only load
  /// origins assigned to one of the mapped base contexts (exact match, no proxy
  /// equivalence); any other top-level navigation is cancelled and reported
  /// back with `strict = true`.
  final Map<String, List<String>> strictContexts;

  /// Ids named by [relations] but absent from [proxies] whose endpoint is still
  /// expected to appear — proxy backends the app is bringing up right now
  /// (autostart, or a start the user just asked for).
  ///
  /// Routing is published before its endpoints on purpose, so a slow Tor
  /// bootstrap costs the containers that use Tor their connectivity rather than
  /// costing the whole browser its routing. The extension blocks a relation
  /// with no live endpoint; this tells it the difference between "blocked
  /// because the backend is not running" and "blocked because it has not
  /// finished starting", so the second one can be waited out instead of turned
  /// into an error page.
  ///
  /// Per id, not per snapshot: a container routed through a sing-box profile
  /// nobody is starting must fail immediately even while Tor happens to be
  /// bootstrapping for some other container.
  final List<String> awaitingProxyIds;

  const GeckoProxyRoutingSnapshot({
    required this.generation,
    required this.proxies,
    required this.relations,
    required this.directScopes,
    required this.siteAssignments,
    required this.strictContexts,
    required this.awaitingProxyIds,
  });
}

/// A launch that cannot be served until a proxy it needs is running.
///
/// Custom Tab and PWA launches are decided natively, before — and often
/// without — the app half existing. When the container a launch belongs to
/// routes through a proxy that is not running, the launch is blocked and
/// nothing in the launch path can change that: sing-box and Tor both live in
/// the Flutter isolate. So the need is recorded natively and handed to the app
/// half, which is the half that can act on it.
class GeckoRoutingDemand {
  /// The cookie-store context the waiting launch's traffic is keyed on.
  final String contextId;

  /// Encoded proxy connection ids that context routes through and that have no
  /// live endpoint — everything that has to come up for the launch to load.
  final List<String> proxyIds;

  const GeckoRoutingDemand({required this.contextId, required this.proxyIds});
}

/// What the extension is currently known to have installed.
class GeckoProxyRoutingStatus {
  /// Whether the extension has acknowledged the most recently pushed snapshot.
  /// While false, the extension blocks every request rather than connecting
  /// directly, so this is the signal for "routing is safe to use".
  final bool ready;

  /// Generation the extension last acknowledged, or null if it never has.
  final int? acknowledgedGeneration;

  const GeckoProxyRoutingStatus({
    required this.ready,
    this.acknowledgedGeneration,
  });
}

@HostApi()
abstract class GeckoContainerProxyApi {
  /// Replaces the extension's entire routing state and waits for it to be
  /// acknowledged. Returns the generation the extension applied.
  ///
  /// The snapshot is cached natively and replayed whenever the extension's
  /// native port reconnects, so a background-script restart cannot leave the
  /// extension running with state the app believes it still has.
  @async
  int applySnapshot(GeckoProxyRoutingSnapshot snapshot);

  /// Liveness only: whether the extension's port answers. Says nothing about
  /// whether routing is configured — use [routingStatus] for that.
  @async
  bool healthcheck();

  /// Locally cached view of what the extension acknowledged. Does not talk to
  /// the extension, so it is safe to call on a hot path.
  GeckoProxyRoutingStatus routingStatus();

  /// The oldest launch waiting for a proxy to be started, or null when none is.
  /// Consumes it: a demand is answered by starting what it names.
  ///
  /// Answers immediately, including when there is nothing to answer with. That
  /// is what lets startup resolve "no launch is waiting" without holding every
  /// endpoint-less route open while it finds out.
  GeckoRoutingDemand? takeRoutingDemand();

  /// Completes when a launch registers a demand, consuming it as
  /// [takeRoutingDemand] does. Never completes on its own.
  ///
  /// A launch into a proxied container can arrive at any point in the life of
  /// the process, long after startup has settled what it brings up, and the
  /// window in which it can be served is the few seconds it spends waiting. A
  /// push would be lost whenever it arrived before the app half was listening —
  /// which is every cold start, the case this exists for — so the app half asks
  /// and native answers when there is something to say.
  @async
  GeckoRoutingDemand nextRoutingDemand();
}

@HostApi()
abstract class GeckoCookieApi {
  @async
  Cookie getCookie(
    String? firstPartyDomain,
    String name,
    CookiePartitionKey? partitionKey,
    String? storeId,
    String url,
  );

  @async
  List<Cookie> getAllCookies(
    String? domain,
    String? firstPartyDomain,
    String? name,
    CookiePartitionKey? partitionKey,
    String? storeId,
    String url,
  );

  @async
  void setCookie(
    String? domain,
    int? expirationDate,
    String? firstPartyDomain,
    bool? httpOnly,
    String? name,
    CookiePartitionKey? partitionKey,
    String? path,
    CookieSameSiteStatus? sameSite,
    bool? secure,
    String? storeId,
    String url,
    String? value,
  );

  @async
  void removeCookie(
    String? firstPartyDomain,
    String name,
    CookiePartitionKey? partitionKey,
    String? storeId,
    String url,
  );
}

class ContainerSiteAssignment {
  final String requestId;
  final String? tabId;
  final String? originUrl;
  final String url;
  final bool blocked;

  /// True when the navigation was cancelled because the tab's container is in
  /// strict mode and the target origin is not assigned to it (as opposed to an
  /// ordinary re-open-in-assigned-container block). Strict blocks have no
  /// destination container; the app just surfaces a message.
  final bool strict;

  ContainerSiteAssignment({
    required this.requestId,
    required this.tabId,
    required this.originUrl,
    required this.url,
    required this.blocked,
    required this.strict,
  });
}

class ProxyLoadError {
  final String? tabId;
  final String? contextId;
  final String? url;
  final String errorType;

  ProxyLoadError({
    required this.tabId,
    required this.contextId,
    required this.url,
    required this.errorType,
  });
}

@FlutterApi()
abstract class GeckoStateEvents {
  void onViewReadyStateChange(int sequence, bool state);
  void onEngineReadyStateChange(int sequence, bool state);
  void onIconUpdate(int sequence, String url, Uint8List bytes);

  void onTabAdded(int sequence, String tabId);

  void onTabListChange(int sequence, List<String> tabIds);
  void onSelectedTabChange(int sequence, String? id);

  /// Mirrors `BrowserState.restoreComplete`: false until the native session
  /// restore has dispatched all persisted tabs into the store.
  void onRestoreCompleteChange(int sequence, bool restoreComplete);

  void onTabContentStateChange(int sequence, TabContentState state);
  void onHistoryStateChange(int sequence, String id, HistoryState state);
  void onReaderableStateChange(int sequence, String id, ReaderableState state);
  void onSecurityInfoStateChange(
    int sequence,
    String id,
    SecurityInfoState state,
  );
  void onIconChange(int sequence, String id, Uint8List? bytes);
  void onThumbnailChange(int sequence, String id, Uint8List? bytes);

  void onFindResults(int sequence, String id, List<FindResultState> results);
  void onLongPress(int sequence, String id, HitResult hitResult);

  // void onScrollChange(int sequence, String tabId, int scrollY);
  void onPreferenceChange(int sequence, GeckoPref value);

  void onContainerSiteAssignment(int sequence, ContainerSiteAssignment details);

  void onProxyLoadError(int sequence, ProxyLoadError details);

  void onMlProgress(int sequence, MlProgressData progress);

  void onDownloadStopped(int sequence, DownloadState state);

  void onManifestUpdate(int sequence, String tabId, PwaManifest? manifest);

  void onTranslationEngineStateChange(
    int sequence,
    TranslationEngineStateData state,
  );
  void onTabTranslationStateChange(int sequence, TabTranslationStateData state);
}

@FlutterApi()
abstract class GeckoSyncStateEvents {
  void onAuthStateChanged(int sequence, SyncAccountInfo accountInfo);
  void onSyncStarted(int sequence);
  void onSyncCompleted(int sequence);
  void onSyncError(int sequence, String? errorMessage);
}

@FlutterApi()
abstract class GeckoLogging {
  void onLog(LogLevel level, String message);
}

@HostApi()
abstract class ReaderViewEvents {
  void onToggleReaderView(bool enable);
  void onAppearanceButtonTap();
}

@FlutterApi()
abstract class ReaderViewController {
  void appearanceButtonVisibility(int sequence, bool visible);
}

@HostApi()
abstract class GeckoSelectionActionController {
  void setActions(List<CustomSelectionAction> actions);
}

@FlutterApi()
abstract class GeckoSelectionActionEvents {
  void performSelectionAction(String id, String selectedText);
}

@HostApi()
abstract class GeckoAddonsApi {
  @async
  List<AddonInfo> getAddons(bool allowCache);

  @async
  AddonInfo? getAddonById(String addonId, bool allowCache);

  @async
  AddonStoreInfo? getAddonStoreInfo(String addonId);

  @async
  List<AddonListing> searchAddonListings(
    String query,
    AddonStoreApp app,
    int page,
    int pageSize,
  );

  @async
  List<AddonListing> getFeaturedAddonListings(AddonStoreApp app, int pageSize);

  void invokeAddonAction(String extensionId, WebExtensionActionType actionType);

  @async
  AddonInfo enableAddon(String addonId);

  @async
  AddonInfo disableAddon(String addonId);

  @async
  AddonInfo setAddonAllowedInPrivateBrowsing(String addonId, bool allowed);

  @async
  AddonInfo setAddonAutoUpdateEnabledForAddon(String addonId, bool enabled);

  @async
  void uninstallAddon(String addonId);

  @async
  AddonUpdateAttemptInfo? triggerAddonUpdate(String addonId);

  @async
  void triggerAllAddonUpdates();

  @async
  AddonUpdateAttemptInfo? getLastAddonUpdateAttempt(String addonId);

  @async
  void installAddon(String url);

  @async
  bool isAddonAutoUpdateEnabled();

  @async
  void setAddonAutoUpdateEnabled(bool enabled);
}

@FlutterApi()
abstract class GeckoAddonEvents {
  void onUpsertWebExtensionAction(
    int sequence,
    String extensionId,
    WebExtensionActionType actionType,
    WebExtensionData extensionData,
  );

  void onRemoveWebExtensionAction(
    int sequence,
    String extensionId,
    WebExtensionActionType actionType,
  );

  void onUpdateWebExtensionIcon(
    int sequence,
    String extensionId,
    WebExtensionActionType actionType,
    Uint8List icon,
  );

  void onWebExtensionPopupRequested(String extensionId, String extensionName);

  void onOpenAddonSettingsRequested(String addonId);
}

@HostApi()
abstract class GeckoSuggestionApi {
  @async
  AutocompleteResult? getAutocompleteSuggestion(String query);
  void querySuggestions(String text, List<GeckoSuggestionType> providers);
}

@FlutterApi()
abstract class GeckoSuggestionEvents {
  void onSuggestionResult(
    int sequence,
    GeckoSuggestionType suggestionType,
    List<GeckoSuggestion> suggestions,
  );
}

@FlutterApi()
abstract class GeckoTabContentEvents {
  void onContentUpdate(int sequence, TabContent content);
}

@HostApi()
abstract class GeckoDeleteBrowsingDataController {
  @async
  void deleteTabs();
  @async
  void deleteBrowsingHistory();
  @async
  void deleteCookiesAndSiteData();
  @async
  void deleteCachedFiles();
  @async
  void deleteSitePermissions();
  @async
  void deleteDownloads();

  @async
  void clearDataForSessionContext(String contextId);

  /// Clear browsing data for a specific host/domain
  @async
  void clearDataForHost(String host, List<ClearDataType> dataTypes);
}

/// Types of browsing data that can be cleared
enum ClearDataType {
  /// Authentication sessions
  authSessions,

  /// All site data (cookies, storage, etc.)
  /// WARNING: If this is set it already includes cookies and allCaches. Passing the additionally will lead to issues
  allSiteData,

  /// Cookies only
  onlyCookies,

  /// Cache only
  onlyCaches,
}

/// Native -> Dart history visit notifications. Fired from the tab-scoped history
/// delegate on each recorded Mozilla Places visit so WebLibre can persist the one
/// thing Places can't store: which container the visit belonged to. The visit
/// itself (title, visit type, exact time) stays owned by Places.
@FlutterApi()
abstract class GeckoHistoryEvents {
  /// [tabId] is the session that produced the visit — the engine session's own
  /// history delegate reports it, so it is exact rather than inferred. Dart maps
  /// the tab to its WebLibre container and writes the visit→container relation,
  /// keyed on ([url], [visitTime]) to join back to the Places visit. A tab
  /// WebLibre has no row for (custom tab, not yet synced) simply stays untagged.
  void onVisitRecorded(String url, int visitTime, String tabId);
}

@HostApi()
abstract class GeckoHistoryApi {
  @async
  List<VisitInfo> getDetailedVisits(
    int startMillis,
    int endMillis,
    List<VisitType> excludeTypes,
  );

  @async
  List<VisitInfo> getVisitsPaginated(
    int offset,
    int count,
    List<VisitType> excludeTypes,
  );

  @async
  void deleteVisit(String url, int timestamp);

  @async
  void deleteDownload(String id);

  @async
  void deleteVisitsBetween(int startMillis, int endMillis);

  @async
  List<HistoryHighlight> getHistoryHighlights(
    HistoryHighlightWeights weights,
    int limit,
  );

  @async
  List<TopFrecentSiteInfo> getTopFrecentSites(
    int limit,
    FrecencyThresholdOption frecencyThreshold,
  );

  /// Returns the most recent [HistoryMetadata] record for [url], or `null` if
  /// no metadata has been recorded for that URL.
  @async
  HistoryMetadata? getLatestHistoryMetadataForUrl(String url);

  /// Bulk variant of [getLatestHistoryMetadataForUrl]. Returns one entry per
  /// input URL aligned by index; entries are `null` for URLs Places has no
  /// metadata for. Used by the local search re-rank to collapse N IPC
  /// roundtrips into one.
  @async
  List<HistoryMetadata?> getLatestHistoryMetadataForUrls(List<String> urls);

  /// Bulk visited check: returns booleans aligned with [urls] indicating
  /// whether Places has any visit recorded for each URL.
  @async
  List<bool> getVisited(List<String> urls);

  /// Frecency-ranked autocomplete results. Mirrors Places' awesomebar input.
  @async
  List<HistorySuggestion> getSuggestions(String query, int limit);

  /// Places' built-in metadata text search (matches title / url / searchTerm).
  /// Useful as a comparison baseline against the local content FTS.
  @async
  List<HistoryMetadata> queryHistoryMetadata(String query, int limit);

  /// Records a title / preview-image observation for [url] without recording
  /// a visit. Intended for manual flows; the engine middleware records these
  /// automatically as the user browses.
  @async
  void recordObservation(String url, PageObservation observation);

  /// Records a view-time observation against the metadata record identified
  /// by [key]. View time is added to the existing total.
  @async
  void noteHistoryMetadataViewTime(HistoryMetadataKey key, int viewTimeMs);

  /// Records a document-type observation against the metadata record
  /// identified by [key].
  @async
  void noteHistoryMetadataDocumentType(
    HistoryMetadataKey key,
    DocumentType documentType,
  );

  /// Removes all visits for [url]. May propagate to remote devices via Sync.
  @async
  void deleteVisitsFor(String url);

  /// Removes all visits since [sinceMillis] (inclusive). May propagate to
  /// remote devices via Sync.
  @async
  void deleteVisitsSince(int sinceMillis);

  /// Removes all locally stored history. Sync will not remove remote history,
  /// but it will prevent deleted entries from returning.
  @async
  void deleteEverything();

  /// Prunes history metadata older than [olderThanMillis] (exclusive).
  @async
  void deleteHistoryMetadataOlderThan(int olderThanMillis);
}

@HostApi()
abstract class GeckoDownloadsApi {
  void requestDownload(String tabId, DownloadState state);
  void copyInternetResource(String tabId, ShareInternetResourceState state);
  void shareInternetResource(String tabId, ShareInternetResourceState state);
  bool openDownloadedFile(
    String fileName,
    String directoryPath,
    String? contentType,
  );
}

@FlutterApi()
abstract class BrowserExtensionEvents {
  void onFeedRequested(int sequence, String url);
}

class GeckoHeader {
  final String key;
  final String value;

  GeckoHeader({required this.key, required this.value});
}

enum GeckoFetchMethod { get, head, post, put, delete, connect, options, trace }

enum GeckoFetchRedircet { follow, manual }

enum GeckoFetchCookiePolicy { include, omit }

class GeckoFetchRequest {
  final String url;
  final GeckoFetchMethod method;
  final List<GeckoHeader> headers;
  final int? connectTimeoutMillis;
  final int? readTimeoutMillis;
  final String? body;
  final GeckoFetchRedircet redirect;
  final GeckoFetchCookiePolicy cookiePolicy;
  final bool useCaches;
  final bool private;
  final bool useOhttp;
  final String? referrerUrl;
  final bool conservative;

  GeckoFetchRequest({
    required this.url,
    required this.method,
    required this.headers,
    required this.connectTimeoutMillis,
    required this.readTimeoutMillis,
    required this.body,
    required this.redirect,
    required this.cookiePolicy,
    required this.useCaches,
    required this.private,
    required this.useOhttp,
    required this.referrerUrl,
    required this.conservative,
  });
}

class GeckoFetchResponse {
  final String url;
  final int status;
  final List<GeckoHeader> headers;
  final Uint8List body;

  GeckoFetchResponse({
    required this.url,
    required this.status,
    required this.headers,
    required this.body,
  });
}

@HostApi()
abstract class GeckoFetchApi {
  @async
  GeckoFetchResponse fetch(GeckoFetchRequest request);
}

enum BookmarkNodeType { item, folder, separator }

class BookmarkNode {
  final BookmarkNodeType type;
  final String guid;
  final String? parentGuid;
  final int? position;
  final String? title;
  final String? url;
  final int dateAdded;
  final int lastModified;
  final List<BookmarkNode>? children;

  BookmarkNode({
    required this.type,
    required this.guid,
    required this.parentGuid,
    required this.position,
    required this.title,
    required this.url,
    required this.dateAdded,
    required this.lastModified,
    required this.children,
  });
}

/// A node of a bookmark tree that is about to be bulk-inserted into storage.
///
/// Unlike [BookmarkNode] this carries no guids or parent links: the tree is
/// described purely by nesting, and storage assigns guids while inserting.
///
/// @property type Whether this node is an item, a folder or a separator.
/// @property title The title of the item or folder. Ignored for separators.
/// @property url The URL of the item. Must be non-null for items, ignored otherwise.
/// @property dateAdded Creation timestamp in milliseconds since epoch, or 0 if unknown.
/// @property lastModified Modification timestamp in milliseconds since epoch, or 0 if unknown.
/// @property children Child nodes of a folder, in insertion order. Empty for items and separators.
class BookmarkImportNode {
  final BookmarkNodeType type;
  final String? title;
  final String? url;
  final int dateAdded;
  final int lastModified;
  final List<BookmarkImportNode> children;

  BookmarkImportNode({
    required this.type,
    required this.title,
    required this.url,
    required this.dateAdded,
    required this.lastModified,
    required this.children,
  });
}

/// Outcome of a bulk bookmark tree insertion.
///
/// @property insertedItemCount The number of bookmark items (not folders or
/// separators) that were inserted.
/// @property failedNodeCount The number of top-level nodes that could not be
/// inserted. Their subtrees are missing entirely.
class BookmarkInsertTreeResult {
  final int insertedItemCount;
  final int failedNodeCount;

  BookmarkInsertTreeResult({
    required this.insertedItemCount,
    required this.failedNodeCount,
  });
}

/// Native -> Dart progress for a bulk bookmark insertion.
///
/// A large import is a single [GeckoBookmarksApi.insertTree] call that can run
/// for a long time, so it reports how far along it is rather than leaving the
/// app with nothing to show. Emission is throttled natively, so this fires
/// far less often than once per bookmark.
@FlutterApi()
abstract class GeckoBookmarksEvents {
  /// [insertedItemCount] is the running number of bookmark items written by the
  /// insertion currently in progress, counted from the start of that one call.
  /// Dart adds the offset of any earlier calls to get an overall figure.
  void onImportProgress(int insertedItemCount);
}

/// Class for making alterations to any bookmark node
class BookmarkInfo {
  final String? parentGuid;
  final int? position;
  final String? title;
  final String? url;

  BookmarkInfo({
    required this.parentGuid,
    required this.position,
    required this.title,
    required this.url,
  });
}

// =============================================================================
// Viewport & Dynamic Toolbar APIs
// =============================================================================

/// Controls GeckoView's viewport behavior for dynamic toolbar and keyboard handling.
///
/// This API allows Flutter to control how GeckoView adjusts its internal viewport
/// without resizing the platform view itself, avoiding visual flickering.
///
/// The dynamic toolbar system works by:
/// 1. Setting the maximum toolbar height via [setDynamicToolbarMaxHeight]
/// 2. Updating the vertical clipping as toolbar animates via [setVerticalClipping]
/// 3. GeckoView internally adjusts viewport and notifies the website
@HostApi()
abstract class GeckoViewportApi {
  /// Sets the maximum height that dynamic toolbars (top + bottom) can occupy.
  ///
  /// GeckoView will adjust its internal viewport calculations to account for
  /// this space. The website will receive proper viewport dimensions through
  /// standard web APIs (CSS viewport units, window.innerHeight).
  ///
  /// Call this once when toolbar dimensions are known, and again if they change.
  ///
  /// [heightPx] Combined height of top and bottom toolbars in pixels.
  void setDynamicToolbarMaxHeight(int heightPx);

  /// Sets the vertical clipping offset for the GeckoView content.
  ///
  /// Use this as the toolbar animates to clip content at the bottom.
  /// Negative values clip from the bottom (for bottom toolbar sliding up).
  /// Positive values clip from the top (for top toolbar sliding down).
  ///
  /// Call this during toolbar animation frames to smoothly adjust the visible area.
  ///
  /// [clippingPx] The clipping offset in pixels. Negative = bottom clip.
  void setVerticalClipping(int clippingPx);
}

/// Events from native side about viewport and input-related changes.
///
/// These events allow Flutter to react to native viewport changes,
/// particularly keyboard visibility which is detected natively.
@FlutterApi()
abstract class GeckoViewportEvents {
  /// Called when keyboard visibility changes.
  ///
  /// This is detected natively using WindowInsets API and provides
  /// accurate keyboard height information.
  ///
  /// [sequence] Event sequence number for ordering.
  /// [heightPx] Keyboard height in pixels (0 when hidden).
  /// [isVisible] Whether the keyboard is currently visible.
  /// [isAnimating] Whether the keyboard is currently animating.
  void onKeyboardVisibilityChanged(
    int sequence,
    int heightPx,
    bool isVisible,
    bool isAnimating,
  );

  /// Called when GeckoView scroll-handling eligibility changes.
  ///
  /// [sequence] Event sequence number for ordering.
  /// [isHandling] True when browser content can consume scrolling for
  /// dynamic toolbar behavior. False when content is not scrollable or
  /// the page consumed touch input.
  void onBrowserHandlingScrollChanged(int sequence, bool isHandling);
}

// =============================================================================
// Bookmarks API
// =============================================================================

@HostApi()
abstract class GeckoBookmarksApi {
  /// Produces a bookmarks tree for the given guid string.
  ///
  /// @param guid The bookmark guid to obtain.
  /// @param recursive Whether to recurse and obtain all levels of children.
  /// @return The populated root starting from the guid.
  @async
  BookmarkNode? getTree(String guid, bool recursive);

  /// Obtains the details of a bookmark without children, if one exists with that guid. Otherwise, null.
  ///
  /// @param guid The bookmark guid to obtain.
  /// @return The bookmark node or null if it does not exist.
  @async
  BookmarkNode? getBookmark(String guid);

  /// Produces a list of all bookmarks with the given URL.
  ///
  /// @param url The URL string.
  /// @return The list of bookmarks that match the URL
  @async
  List<BookmarkNode> getBookmarksWithUrl(String url);

  /// Produces a list of the most recently added bookmarks.
  ///
  /// @param limit The maximum number of entries to return.
  /// @param maxAge Optional parameter used to filter out entries older than this number of milliseconds.
  /// @param currentTime Optional parameter for current time. Defaults toSystem.currentTimeMillis()
  /// @return The list of bookmarks that have been recently added up to the limit number of items.
  @async
  List<BookmarkNode> getRecentBookmarks(
    int limit,
    int? maxAge,
    int currentTime,
  );

  /// Searches bookmarks with a query string.
  ///
  /// @param query The query string to search.
  /// @param limit The maximum number of entries to return.
  /// @return The list of matching bookmark nodes up to the limit number of items.
  @async
  List<BookmarkNode> searchBookmarks(String query, int limit);

  /// Adds a new bookmark item to a given node.
  ///
  /// Sync behavior: will add new bookmark item to remote devices.
  ///
  /// @param parentGuid The parent guid of the new node.
  /// @param url The URL of the bookmark item to add.
  /// @param title The title of the bookmark item to add.
  /// @param position The optional position to add the new node or null to append.
  /// @return The guid of the newly inserted bookmark item.
  @async
  String addItem(String parentGuid, String url, String title, int? position);

  /// Adds a new bookmark folder to a given node.
  ///
  /// Sync behavior: will add new separator to remote devices.
  ///
  /// @param parentGuid The parent guid of the new node.
  /// @param title The title of the bookmark folder to add.
  /// @param position The optional position to add the new node or null to append.
  /// @return The guid of the newly inserted bookmark item.
  @async
  String addFolder(String parentGuid, String title, int? position);

  /// Edits the properties of an existing bookmark item and/or moves an existing one underneath a new parent guid.
  ///
  /// Sync behavior: will alter bookmark item on remote devices.
  ///
  /// @param guid The guid of the item to update.
  /// @param info The info to change in the bookmark.
  @async
  void updateNode(String guid, BookmarkInfo info);

  /// Deletes a bookmark node and all of its children, if any.
  ///
  /// Sync behavior: will remove bookmark from remote devices.
  ///
  /// @return Whether the bookmark existed or not.
  @async
  bool deleteNode(String guid);

  /// Bulk-inserts [children] underneath [parentGuid], appending them after any
  /// nodes the parent already contains.
  ///
  /// Each top-level folder is handed to the storage layer as a single tree
  /// insertion, so importing a large bookmark file costs one platform channel
  /// call instead of one per node. Separators are preserved.
  ///
  /// Timestamps survive in full for everything nested inside a top-level
  /// folder. Loose top-level items and separators keep their [dateAdded], but
  /// their [lastModified] is set to the time of import: the only storage call
  /// that accepts timestamps creates a folder, so nodes landing directly in
  /// [parentGuid] have to be moved into place afterwards.
  ///
  /// Sync behavior: will add the inserted bookmarks to remote devices.
  ///
  /// Unlike [addItem] and [addFolder] this does *not* emit a
  /// `bookmarks.onCreated` extension event per node, since a large import would
  /// otherwise flood every installed WebExtension.
  ///
  /// @param parentGuid The guid of the existing folder to insert underneath.
  /// @param children The nodes to insert, in the order they should appear.
  /// @return The number of inserted bookmark items and failed top-level nodes.
  @async
  BookmarkInsertTreeResult insertTree(
    String parentGuid,
    List<BookmarkImportNode> children,
  );

  /// Counts the bookmark items contained in the trees rooted at [guids].
  ///
  /// Folders and separators are not counted, and a guid that does not exist
  /// contributes nothing. Lets the app report how much a destructive action
  /// affects without loading the subtrees into Dart.
  ///
  /// @param guids The guids of the folders to count within.
  /// @return The total number of bookmark items across all trees.
  @async
  int countBookmarksInTrees(List<String> guids);
}

// =============================================================================
// Site Permissions API
// =============================================================================

/// Permission status for a site permission
enum SitePermissionStatus {
  /// Permission has been granted
  allowed,

  /// Permission has been denied
  blocked,

  /// No decision has been made yet (ask to allow)
  noDecision,
}

/// Autoplay permission values (matches Fenix's 4 states)
enum AutoplayStatus {
  /// Allow all autoplay (audible and inaudible)
  allowed,

  /// Block all autoplay
  blocked,

  /// Block audible autoplay only (allow inaudible)
  blockAudible,

  /// Allow autoplay on WiFi only
  allowOnWifi,
}

/// Site permissions data structure
class SitePermissions {
  final String origin;
  final SitePermissionStatus? camera;
  final SitePermissionStatus? microphone;
  final SitePermissionStatus? location;
  final SitePermissionStatus? notification;
  final SitePermissionStatus? persistentStorage;
  final SitePermissionStatus? crossOriginStorageAccess;
  final SitePermissionStatus? mediaKeySystemAccess;
  final SitePermissionStatus? localDeviceAccess;
  final SitePermissionStatus? localNetworkAccess;
  final AutoplayStatus? autoplayAudible;
  final AutoplayStatus? autoplayInaudible;
  final int savedAt;

  SitePermissions({
    required this.origin,
    this.camera,
    this.microphone,
    this.location,
    this.notification,
    this.persistentStorage,
    this.crossOriginStorageAccess,
    this.mediaKeySystemAccess,
    this.localDeviceAccess,
    this.localNetworkAccess,
    this.autoplayAudible,
    this.autoplayInaudible,
    this.savedAt = 0,
  });
}

/// API for managing site permissions stored in GeckoView
@HostApi()
abstract class GeckoSitePermissionsApi {
  /// Get permissions for origin (single source of truth from GeckoView)
  @async
  SitePermissions? getSitePermissions(String origin, bool private);

  /// Save/update permissions (persisted by GeckoView)
  @async
  void setSitePermissions(SitePermissions permissions, bool private);

  /// Delete permissions for origin (removed from GeckoView storage)
  @async
  void deleteSitePermissions(String origin, bool private);
}

// =============================================================================
// Public Suffix List API
// =============================================================================

/// Native wrapper for Mozilla's Public Suffix List
@HostApi()
abstract class GeckoPublicSuffixListApi {
  /// Get base domain (eTLD+1) from host using Mozilla's Public Suffix List
  /// Returns the host unchanged if PSL lookup fails
  @async
  String getPublicSuffixPlusOne(String host);
}

/// Tracking protection exception for a site
///
/// This represents a site that has been added to the exceptions list,
/// meaning tracking protection is disabled for this specific site.
class TrackingProtectionException {
  final String url;

  TrackingProtectionException({required this.url});
}

/// API for managing per-site tracking protection exceptions
///
/// This API wraps Mozilla Android Components' TrackingProtectionUseCases
/// to allow Flutter code to add/remove/check tracking protection exceptions
/// on a per-site basis.
@HostApi()
abstract class GeckoTrackingProtectionApi {
  /// Check if a tab has a tracking protection exception
  ///
  /// Uses callback pattern to match Mozilla Android Components API.
  /// Returns true if the site is in the exceptions list (ETP disabled).
  @async
  bool containsException(String tabId);

  /// Add tracking protection exception for a tab (disable ETP for this site)
  ///
  /// This adds the current tab's URL to the exceptions list.
  /// ETP will be disabled for this site until the exception is removed.
  void addException(String tabId);

  /// Remove tracking protection exception for a tab (enable ETP for this site)
  ///
  /// This removes the current tab's URL from the exceptions list.
  /// ETP will be re-enabled for this site.
  void removeException(String tabId);

  /// Remove a specific exception by URL
  ///
  /// Alternative to removeException(tabId) for cases where you
  /// have a URL rather than a tabId.
  @async
  void removeExceptionByUrl(String url);

  /// Fetch all tracking protection exceptions
  ///
  /// Returns list of all sites that have exceptions (ETP disabled).
  @async
  List<TrackingProtectionException> fetchExceptions();

  /// Remove all tracking protection exceptions
  ///
  /// This re-enables ETP for all exception sites.
  @async
  void removeAllExceptions();
}

// =============================================================================
// App Links API
// =============================================================================

/// Resolved external-app target for a URL (see APP_LINKS_OWN_IMPLEMENTATION_PLAN.md §2.8).
class AppLinkTarget {
  /// The URL that was resolved.
  final String url;

  /// User-facing app label (control/bidi-sanitised), or null when unknown.
  final String? appName;

  /// Resolved package name, or null when ambiguous / unknown.
  final String? packageName;

  /// Pre-validated http(s) fallback URL, or null.
  final String? fallbackUrl;

  /// True when the only offer is a marketplace (install-app) intent.
  final bool isMarketplace;

  /// True when resolution is ambiguous (chooser / multiple handlers / no default).
  final bool isAmbiguous;

  /// True when the Gecko engine can load the URL scheme itself.
  final bool engineSupportsScheme;

  /// Canonical native-owned rule scope key ("host:youtube.com" | "pkg:...").
  final String scopeKey;

  const AppLinkTarget({
    required this.url,
    this.appName,
    this.packageName,
    this.fallbackUrl,
    required this.isMarketplace,
    required this.isAmbiguous,
    required this.engineSupportsScheme,
    required this.scopeKey,
  });
}

/// Target-side protection pattern replicated to native (§2.3/§2.8). Any target
/// assigned to an effectively-proxied or strict container is protected
/// independent of the source tab.
class ProtectedTargetPattern {
  final String scheme;
  final String hostOrSuffix;
  final bool includeSubdomains;

  /// Effective port for exact entries; null for wildcard entries (ignore port).
  final int? port;

  const ProtectedTargetPattern({
    required this.scheme,
    required this.hostOrSuffix,
    required this.includeSubdomains,
    this.port,
  });
}

enum NativeAppLinkRuleDecision { alwaysOpen, neverOpen }

/// A remembered per-scope rule replicated to native (§2.8). Distinct from the
/// Dart-persisted `PersistedAppLinkRule`; explicit mappers bridge the two.
class NativeAppLinkRule {
  final NativeAppLinkRuleDecision decision;
  final String scope;
  final String? packageName;

  const NativeAppLinkRule({
    required this.decision,
    required this.scope,
    this.packageName,
  });
}

/// A container's self-contained app-link policy override (§ container isolation).
/// Present only for containers with "isolated app link settings" enabled; when a
/// navigation's source contextId has an entry here, it fully *replaces* the
/// global mode + rules for that navigation (no layering with the global policy).
class NativeContextAppLinkPolicy {
  final AppLinksMode mode;

  /// The container's own remembered rules keyed by canonical scope.
  final Map<String, NativeAppLinkRule> rules;

  const NativeContextAppLinkPolicy({required this.mode, required this.rules});
}

/// Complete, last-write-wins policy snapshot pushed from the single Dart writer
/// to native (§2.8). Native persists it to the profile-scoped prefs record
/// before swapping the in-memory reference.
class AppLinkPolicySnapshot {
  final AppLinksMode globalMode;

  /// Remembered rules keyed by canonical scope.
  final Map<String, NativeAppLinkRule> rules;

  final bool marketplaceFallbackEnabled;

  /// Allows same-caller Custom Tab / ActionView authentication callbacks to
  /// return to their app even when the general app-link mode is `never`.
  final bool authExceptionsEnabled;

  /// Hold an engine-supported (http(s)) navigation while its prompt is up
  /// instead of letting the page load behind the banner (§2.2). Declining
  /// re-issues the load. Opt-in; native seeds it `false`.
  final bool blockWhilePrompting;

  /// Regular / no-contextId tabs are proxied via the `general` scope.
  final bool protectGeneralContext;

  /// contextIds that resolve to a proxy after inherit/bypass/alias.
  final List<String> protectedContextIds;

  /// strictMode containers, independent of routing.
  final List<String> strictContextIds;

  final List<ProtectedTargetPattern> protectedTargetPatterns;

  /// Per-container app-link policy overrides keyed by contextId. Only isolated
  /// containers appear here; a navigation whose source contextId is a key uses
  /// the entry's mode + rules in place of the global ones (replace semantics).
  final Map<String, NativeContextAppLinkPolicy> contextOverrides;

  const AppLinkPolicySnapshot({
    required this.globalMode,
    required this.rules,
    required this.marketplaceFallbackEnabled,
    required this.authExceptionsEnabled,
    required this.blockWhilePrompting,
    required this.protectGeneralContext,
    required this.protectedContextIds,
    required this.strictContextIds,
    required this.protectedTargetPatterns,
    required this.contextOverrides,
  });
}

/// Which surface owns a pending prompt (§2.6). Fixed at creation, never transfers.
enum AppLinkPromptOwner { flutterBrowser, nativeExternal }

/// A pending app-link prompt request held in the native `PendingAppLinkStore`
/// until resolved, invalidated, or expired (§2.6/§2.8). Holds only stable
/// identifiers and sanitised data — never engine/store references.
class AppLinkPromptRequest {
  /// Monotonic per-process id (Kotlin Long).
  final int requestId;
  final AppLinkPromptOwner owner;
  final String tabId;
  final String? contextId;
  final String? sourceUrl;
  final bool isPrivate;
  final bool isWallet;
  final bool isProtectedContext;
  final bool canRemember;

  /// false for the http(s) banner class (non-modal); true for the modal
  /// unsupported-scheme prompt.
  final bool isModal;
  final AppLinkTarget target;

  /// Milliseconds until the native store drops this request, measured at query
  /// time. The surface showing it must stop offering it by then: resolving an
  /// expired request is a no-op, so a prompt left on screen past this becomes a
  /// button that silently does nothing.
  final int expiresInMs;

  const AppLinkPromptRequest({
    required this.requestId,
    required this.owner,
    required this.tabId,
    this.contextId,
    this.sourceUrl,
    required this.isPrivate,
    required this.isWallet,
    required this.isProtectedContext,
    required this.canRemember,
    required this.isModal,
    required this.target,
    required this.expiresInMs,
  });
}

/// User decision on a pending prompt (§2.6).
enum AppLinkDecision { open, cancel, dismiss }

/// Result of resolving a pending prompt (§2.8).
class AppLinkResolutionResult {
  final bool launched;
  final bool loadedFallback;

  /// "stale" | "dead_session" | "launch_failed" | null.
  final String? failureReason;

  const AppLinkResolutionResult({
    required this.launched,
    required this.loadedFallback,
    this.failureReason,
  });
}

/// API for detecting and launching external applications that can handle URLs.
///
/// WebLibre-owned resolution/launch surface (replaces the Mozilla AC use-case
/// wrappers). Policy lives in Dart; this surface owns PackageManager resolution
/// and Intent launch.
@HostApi()
abstract class GeckoAppLinksApi {
  /// Push the complete policy snapshot to native (last-write-wins). Native
  /// persists it durably to the active profile's prefs record before acking.
  @async
  void setAppLinkPolicy(AppLinkPolicySnapshot snapshot);

  /// Non-consuming query of pending prompts for [owner] (§2.6). Surfaces call
  /// this on attach/resume/rotation and when the availability event fires, and
  /// render idempotently by requestId.
  @async
  List<AppLinkPromptRequest> getPendingAppLinkPrompts(AppLinkPromptOwner owner);

  /// Atomically resolve a pending prompt: validate it still exists and its tab
  /// is alive, consume it (double-resolve is a no-op), then perform side effects
  /// after releasing the store lock (§2.6).
  @async
  AppLinkResolutionResult resolvePendingAppLink(
    int requestId,
    AppLinkDecision decision,
  );

  /// Resolve [url] to an external-app target.
  ///
  /// Returns null when no external app is available, on any resolution error, or
  /// for always-denied schemes — callers cannot distinguish "nothing installed"
  /// from "resolution failed", matching the previous `hasExternalApp` contract.
  ///
  /// [includeHttpAppLinks] when true, an app resolving an engine-supported
  /// (http(s)) URL is surfaced (e.g. the YouTube app for a youtube.com link).
  @async
  AppLinkTarget? resolveAppLink(String url, bool includeHttpAppLinks);

  /// Re-resolve [url] and launch it in an external app.
  ///
  /// Re-resolves internally immediately before launch and returns false on
  /// no-app or ActivityNotFoundException/SecurityException; never throws across
  /// the channel for expected conditions.
  @async
  bool launchAppLink(String url);
}

/// Optimisation-only availability signal for pending app-link prompts (§2.8).
///
/// A Pigeon `@FlutterApi()` callback has no buffering or replay: an event
/// emitted while Flutter is detached is lost. The `PendingAppLinkStore` is the
/// source of truth; surfaces query on attach/resume and dedupe by requestId.
@FlutterApi()
abstract class GeckoAppLinkEvents {
  void onAppLinkPromptAvailable(int sequence, AppLinkPromptOwner owner);
}

// =============================================================================
// PWA API
// =============================================================================

/// Represents an icon from a PWA manifest.
class PwaIcon {
  final String src;
  final String? sizes;
  final String? type;

  const PwaIcon({required this.src, this.sizes, this.type});
}

/// Represents a file entry in share target params.
class ShareTargetFiles {
  final String name;
  final List<String?> accept;

  const ShareTargetFiles({required this.name, required this.accept});
}

/// Represents share target params.
class ShareTargetParams {
  final String? title;
  final String? text;
  final String? url;
  final List<ShareTargetFiles?> files;

  const ShareTargetParams({
    this.title,
    this.text,
    this.url,
    this.files = const [],
  });
}

/// Represents a share target for PWA.
class ShareTarget {
  final String action;
  final String? method;
  final String? encType;
  final ShareTargetParams? params;

  const ShareTarget({
    required this.action,
    this.method,
    this.encType,
    this.params,
  });
}

/// Represents an external application resource.
class ExternalApplicationResource {
  final String platform;
  final String? url;
  final String? id;
  final String? minVersion;

  const ExternalApplicationResource({
    required this.platform,
    this.url,
    this.id,
    this.minVersion,
  });
}

/// Represents a PWA web app manifest.
///
/// Mirrors Mozilla Android Components' WebAppManifest structure.
/// https://firefox-source-docs.mozilla.org/mobile/android/geckoview/api/mozilla.components.concept.engine.manifest.WebAppManifest.html
class PwaManifest {
  final String startUrl;
  final String? name;
  final String? shortName;
  final String? display;
  final String? themeColor;
  final String? backgroundColor;
  final String? scope;
  final String? description;
  final List<PwaIcon?> icons;
  final String? dir;
  final String? lang;
  final String? orientation;
  final List<ExternalApplicationResource?> relatedApplications;
  final bool preferRelatedApplications;
  final ShareTarget? shareTarget;

  /// The URL of the page when the manifest was detected.
  /// Used for HTTPS/installability checks.
  final String currentUrl;

  /// Storage context (container contextualIdentity or isolated `iso1_…` id)
  /// that this install was pinned with. Only populated by
  /// `getInstalledWebApps` — read from the pinned shortcut's intent extras,
  /// not from the manifest itself, because the same URL can have multiple
  /// installs that differ only in contextId.
  final String? contextId;

  /// User-chosen launcher label for this specific install (from the pinned
  /// shortcut's shortLabel). May differ from `name`/`shortName` because the
  /// underlying manifest is shared across install variants of the same URL.
  /// Only populated by `getInstalledWebApps`.
  final String? installLabel;

  const PwaManifest({
    required this.startUrl,
    required this.currentUrl,
    this.name,
    this.shortName,
    this.display,
    this.themeColor,
    this.backgroundColor,
    this.scope,
    this.description,
    this.icons = const [],
    this.dir,
    this.lang,
    this.orientation,
    this.relatedApplications = const [],
    this.preferRelatedApplications = false,
    this.shareTarget,
    this.contextId,
    this.installLabel,
  });
}

/// API for PWA (Progressive Web App) installation and management.
///
/// Wraps Mozilla Android Components' WebAppUseCases and ManifestStorage
/// to provide PWA install and query functionality to Flutter.
@HostApi()
abstract class GeckoPwaApi {
  /// Installs the current page as a PWA (adds to home screen).
  ///
  /// Creates an Android shortcut with profile and container metadata embedded
  /// in the intent extras. This ensures the PWA opens with the same profile
  /// and container context that was active during installation.
  ///
  /// The [tabId] identifies which tab to install from. If null, uses the selected tab.
  /// The [profileUuid] is the UUID of the current user profile.
  /// The [contextId] is the container's contextual identity (optional, null for default container).
  /// The [overrideAppName] customizes the installed app's displayed name and persists in the saved manifest.
  /// Returns true if installation was successful.
  @async
  bool installWebApp(
    String? tabId,
    String profileUuid,
    String? contextId,
    String? overrideAppName,
  );

  /// Returns a list of all installed PWA manifests.
  @async
  List<PwaManifest> getInstalledWebApps();

  /// Creates a basic bookmark shortcut on the home screen (no manifest required).
  ///
  /// Unlike [installWebApp], this creates a simple shortcut that opens
  /// in a regular browser tab rather than standalone PWA mode.
  /// Uses the page title and favicon for the shortcut.
  ///
  /// The [tabId] identifies which tab to create the shortcut for. If null, uses the selected tab.
  /// The [profileUuid] is the UUID of the current user profile.
  /// The [contextId] is the container's contextual identity (optional).
  /// The [overrideShortcutName] allows customizing the shortcut label.
  /// Returns true if the shortcut was created successfully.
  @async
  bool installBasicShortcut(
    String? tabId,
    String profileUuid,
    String? contextId,
    String? overrideShortcutName,
  );
}

/// Per-tab sandbox capture state shared with the native side. The Kotlin
/// [AppRequestInterceptor] consults an in-memory registry populated from
/// these entries to decide how to handle loads in sandbox tabs.
///
/// [redirectUrl] is precomputed by Dart and always points at a loopback URL
/// (loader or capture). Dart is responsible for keeping it current; Kotlin
/// never calls back into Dart to resolve it.
class SandboxCaptureEntry {
  final String tabId;
  final String captureId;
  final String sourceUrl;

  /// `http://127.0.0.1:<port>/loader?…` while pending/failed, or
  /// `http://127.0.0.1:<port>/captures/…?t=<token>` once ready.
  final String redirectUrl;

  /// `pending` | `ready` | `failed`.
  final String status;

  SandboxCaptureEntry({
    required this.tabId,
    required this.captureId,
    required this.sourceUrl,
    required this.redirectUrl,
    required this.status,
  });
}

/// Dart → Kotlin. Mutates the native [SandboxCaptureRegistry] that the
/// request interceptor consults on every load.
@HostApi()
abstract class SandboxCaptureApi {
  /// Replaces the entire registry with [entries]. Called at startup after
  /// Dart has brought up [CaptureServer] and reconciled local artifacts with
  /// the `capture_tab` rows.
  void resetAll(List<SandboxCaptureEntry> entries);

  /// Inserts or updates the registry entry for [entry.tabId].
  void mark(SandboxCaptureEntry entry);

  /// Removes the registry entry for [tabId].
  void unmark(String tabId);
}

/// Kotlin → Dart. Fire-and-forget notifications from the request
/// interceptor / BrowserStore middleware. All handlers are non-blocking;
/// the interceptor never waits for a Dart response.
@FlutterApi()
abstract class SandboxCaptureHostEvents {
  /// Emitted when a sandbox tab attempted to navigate to a non-loopback,
  /// non-source URL (e.g., user clicked a link or typed a new URL into the
  /// address bar). Dart should open a new sandbox tab and capture [targetUrl].
  void onSandboxLinkClick(int sequence, String parentTabId, String targetUrl);

  /// Emitted when GeckoView created a new tab (via `window.open`,
  /// `target="_blank"`, or a middle-click) whose parent is a sandbox tab.
  /// The native middleware has already rewritten the new tab's URL to
  /// `about:blank`; Dart should register it as sandbox and run the capture
  /// pipeline for [targetUrl].
  void onSandboxNewTab(
    int sequence,
    String parentTabId,
    String newTabId,
    String targetUrl,
  );
}

// =============================================================================
// Touch Gestures API
// =============================================================================

/// Configuration for native touch-gesture recognition.
///
/// Pushed from Dart whenever the user's gesture settings change. Native
/// recognition is purely observational: it assembles a canonical stroke key
/// (start-position prefix + finger-count prefix + dash-joined directions, e.g.
/// `R:2:D-L`) and only emits when that key matches an entry in
/// [activeGestureKeys]. Strokes that do not match are ignored, so normal
/// scrolling, tapping and pinch-zoom are never affected.
class GestureConfig {
  final bool enabled;

  /// Base stroke length in logical pixels, scaled at runtime by
  /// `min(viewWidth, viewHeight) / 320` to match the reference gesture add-on.
  final int strokeSize;

  /// Milliseconds of inactivity after which an in-progress gesture is
  /// discarded.
  final int timeoutMs;

  /// Maximum number of simultaneous pointers a gesture may use.
  final int maxFingers;

  /// Minimum milliseconds required between two consecutive direction changes
  /// within a single gesture. A new direction registered faster than this
  /// aborts the in-progress gesture, so accidental fast scribbles match
  /// nothing. `0` disables the check.
  final int minStrokeIntervalMs;

  /// Canonical keys that currently have an action bound, e.g. `D-R`,
  /// `R:2:D-L`. Native only emits [GeckoGestureEvents.onGestureRecognized]
  /// when an assembled stroke matches one of these.
  final List<String> activeGestureKeys;

  GestureConfig({
    this.enabled = false,
    this.strokeSize = 50,
    this.timeoutMs = 1500,
    this.maxFingers = 1,
    this.minStrokeIntervalMs = 0,
    this.activeGestureKeys = const [],
  });
}

/// Dart → Kotlin. Pushes the current gesture-recognition configuration.
@HostApi()
abstract class GeckoGestureApi {
  void setGestureConfig(GestureConfig config);
}

/// Kotlin → Dart. Emitted when an assembled touch stroke matches a configured
/// gesture key.
@FlutterApi()
abstract class GeckoGestureEvents {
  /// [sequence] Event sequence number for ordering.
  /// [gestureKey] Canonical key of the recognized gesture, e.g. `D-R`.
  void onGestureRecognized(int sequence, String gestureKey);

  /// Emitted while a stroke is being drawn, each time a new direction arrow is
  /// appended. Drives the live feedback overlay.
  ///
  /// [sequence] Event sequence number for ordering.
  /// [partialKey] Current partial canonical key including start/finger
  /// prefixes, e.g. `R:D`.
  void onGestureProgress(int sequence, String partialKey);

  /// Emitted when an in-progress stroke ends (release, cancel or idle timeout)
  /// so the live feedback overlay can be hidden.
  ///
  /// [sequence] Event sequence number for ordering.
  void onGestureReset(int sequence);
}

/// Lifecycle state of the selected UnifiedPush distributor.
enum PushDistributorStatus {
  /// No distributor app is installed on the device.
  noneAvailable,

  /// Distributors are installed but the user has not chosen one.
  notSelected,

  /// A distributor is chosen but has not acknowledged our registration yet.
  pending,

  /// A distributor is chosen and has acknowledged our registration.
  ready,

  /// A distributor was chosen previously but is no longer installed. Web push
  /// is dead in this state and there is no fallback transport.
  unavailable,
}

class PushDistributor {
  final String packageName;

  /// Human-readable app label, or null if the package is no longer installed.
  final String? label;

  PushDistributor({required this.packageName, required this.label});
}

class PushStatus {
  final PushDistributorStatus status;
  final PushDistributor? current;
  final List<PushDistributor> available;

  /// Most recent distributor registration failure, or null if none.
  ///
  /// Held natively rather than delivered as a one-shot event: registrations are
  /// attempted at startup and from background broadcasts, both of which can run
  /// long before any Dart listener exists.
  final String? lastError;

  PushStatus({
    required this.status,
    required this.current,
    required this.available,
    required this.lastError,
  });
}

class PushSubscription {
  /// Subscription identifier, which for web push is the site's origin.
  final String scope;

  /// Whether the distributor has handed back an endpoint for this scope.
  final bool hasEndpoint;

  PushSubscription({required this.scope, required this.hasEndpoint});
}

/// Dart → Kotlin. UnifiedPush distributor management and web push introspection.
@HostApi()
abstract class GeckoPushApi {
  @async
  PushStatus getPushStatus();

  /// Selects [packageName], which must be one of [PushStatus.available].
  ///
  /// The picker is built in Dart rather than delegated to the connector's own
  /// dialog, which would save the selection against a non-profile context.
  @async
  void setDistributor(String packageName);

  /// Forgets the current distributor. This is the off switch for web push.
  @async
  void removeDistributor();

  @async
  void renewRegistration();

  /// Pauses push transport for this profile ahead of a restart, taking the
  /// profile lock so an in-flight delivery cannot straddle the boundary. Site
  /// subscriptions and the chosen distributor are retained for restoration when
  /// this profile becomes active again.
  ///
  /// Writes no profile state: under the restart protocol the target lives in the
  /// durable restart request and is applied by the next process.
  @async
  void suspendPushForRestart();

  /// Subscriptions Gecko has created, read from the UnifiedPush store. Read-only:
  /// there is no app→Gecko channel to revoke a subscription, so removal has to go
  /// through the site's notification permission instead.
  @async
  List<PushSubscription> getSubscriptions();
}

/// Kotlin → Dart. Push registration lifecycle.
///
/// Registration failures reach Dart through [PushStatus.lastError] rather than a
/// dedicated event, so a failure raised before any Dart listener is attached is
/// still visible the first time the settings screen reads the status.
@FlutterApi()
abstract class GeckoPushEvents {
  /// [sequence] Event sequence number for ordering.
  void onPushStatusChanged(int sequence, PushStatus status);
}
