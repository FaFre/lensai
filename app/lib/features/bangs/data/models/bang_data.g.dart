// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bang_data.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$BangDataCWProxy {
  BangData websiteName(String websiteName);

  BangData domain(String domain);

  BangData trigger(String trigger);

  BangData urlTemplate(String urlTemplate);

  BangData category(String? category);

  BangData subCategory(String? subCategory);

  BangData format(Set<BangFormat>? format);

  BangData frequency(int? frequency);

  BangData lastUsed(DateTime? lastUsed);

  BangData icon(BrowserIcon? icon);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `BangData(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// BangData(...).copyWith(id: 12, name: "My name")
  /// ````
  BangData call({
    String? websiteName,
    String? domain,
    String? trigger,
    String? urlTemplate,
    String? category,
    String? subCategory,
    Set<BangFormat>? format,
    int? frequency,
    DateTime? lastUsed,
    BrowserIcon? icon,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfBangData.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfBangData.copyWith.fieldName(...)`
class _$BangDataCWProxyImpl implements _$BangDataCWProxy {
  const _$BangDataCWProxyImpl(this._value);

  final BangData _value;

  @override
  BangData websiteName(String websiteName) => this(websiteName: websiteName);

  @override
  BangData domain(String domain) => this(domain: domain);

  @override
  BangData trigger(String trigger) => this(trigger: trigger);

  @override
  BangData urlTemplate(String urlTemplate) => this(urlTemplate: urlTemplate);

  @override
  BangData category(String? category) => this(category: category);

  @override
  BangData subCategory(String? subCategory) => this(subCategory: subCategory);

  @override
  BangData format(Set<BangFormat>? format) => this(format: format);

  @override
  BangData frequency(int? frequency) => this(frequency: frequency);

  @override
  BangData lastUsed(DateTime? lastUsed) => this(lastUsed: lastUsed);

  @override
  BangData icon(BrowserIcon? icon) => this(icon: icon);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `BangData(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// BangData(...).copyWith(id: 12, name: "My name")
  /// ````
  BangData call({
    Object? websiteName = const $CopyWithPlaceholder(),
    Object? domain = const $CopyWithPlaceholder(),
    Object? trigger = const $CopyWithPlaceholder(),
    Object? urlTemplate = const $CopyWithPlaceholder(),
    Object? category = const $CopyWithPlaceholder(),
    Object? subCategory = const $CopyWithPlaceholder(),
    Object? format = const $CopyWithPlaceholder(),
    Object? frequency = const $CopyWithPlaceholder(),
    Object? lastUsed = const $CopyWithPlaceholder(),
    Object? icon = const $CopyWithPlaceholder(),
  }) {
    return BangData(
      websiteName:
          websiteName == const $CopyWithPlaceholder() || websiteName == null
              ? _value.websiteName
              // ignore: cast_nullable_to_non_nullable
              : websiteName as String,
      domain: domain == const $CopyWithPlaceholder() || domain == null
          ? _value.domain
          // ignore: cast_nullable_to_non_nullable
          : domain as String,
      trigger: trigger == const $CopyWithPlaceholder() || trigger == null
          ? _value.trigger
          // ignore: cast_nullable_to_non_nullable
          : trigger as String,
      urlTemplate:
          urlTemplate == const $CopyWithPlaceholder() || urlTemplate == null
              ? _value.urlTemplate
              // ignore: cast_nullable_to_non_nullable
              : urlTemplate as String,
      category: category == const $CopyWithPlaceholder()
          ? _value.category
          // ignore: cast_nullable_to_non_nullable
          : category as String?,
      subCategory: subCategory == const $CopyWithPlaceholder()
          ? _value.subCategory
          // ignore: cast_nullable_to_non_nullable
          : subCategory as String?,
      format: format == const $CopyWithPlaceholder()
          ? _value.format
          // ignore: cast_nullable_to_non_nullable
          : format as Set<BangFormat>?,
      frequency: frequency == const $CopyWithPlaceholder()
          ? _value.frequency
          // ignore: cast_nullable_to_non_nullable
          : frequency as int?,
      lastUsed: lastUsed == const $CopyWithPlaceholder()
          ? _value.lastUsed
          // ignore: cast_nullable_to_non_nullable
          : lastUsed as DateTime?,
      icon: icon == const $CopyWithPlaceholder()
          ? _value.icon
          // ignore: cast_nullable_to_non_nullable
          : icon as BrowserIcon?,
    );
  }
}

extension $BangDataCopyWith on BangData {
  /// Returns a callable class that can be used as follows: `instanceOfBangData.copyWith(...)` or like so:`instanceOfBangData.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$BangDataCWProxy get copyWith => _$BangDataCWProxyImpl(this);
}
