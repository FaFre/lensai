// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bang.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$BangCWProxy {
  Bang websiteName(String websiteName);

  Bang domain(String domain);

  Bang trigger(String trigger);

  Bang urlTemplate(String urlTemplate);

  Bang group(BangGroup? group);

  Bang category(String? category);

  Bang subCategory(String? subCategory);

  Bang format(Set<BangFormat>? format);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Bang(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Bang(...).copyWith(id: 12, name: "My name")
  /// ````
  Bang call({
    String? websiteName,
    String? domain,
    String? trigger,
    String? urlTemplate,
    BangGroup? group,
    String? category,
    String? subCategory,
    Set<BangFormat>? format,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfBang.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfBang.copyWith.fieldName(...)`
class _$BangCWProxyImpl implements _$BangCWProxy {
  const _$BangCWProxyImpl(this._value);

  final Bang _value;

  @override
  Bang websiteName(String websiteName) => this(websiteName: websiteName);

  @override
  Bang domain(String domain) => this(domain: domain);

  @override
  Bang trigger(String trigger) => this(trigger: trigger);

  @override
  Bang urlTemplate(String urlTemplate) => this(urlTemplate: urlTemplate);

  @override
  Bang group(BangGroup? group) => this(group: group);

  @override
  Bang category(String? category) => this(category: category);

  @override
  Bang subCategory(String? subCategory) => this(subCategory: subCategory);

  @override
  Bang format(Set<BangFormat>? format) => this(format: format);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Bang(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Bang(...).copyWith(id: 12, name: "My name")
  /// ````
  Bang call({
    Object? websiteName = const $CopyWithPlaceholder(),
    Object? domain = const $CopyWithPlaceholder(),
    Object? trigger = const $CopyWithPlaceholder(),
    Object? urlTemplate = const $CopyWithPlaceholder(),
    Object? group = const $CopyWithPlaceholder(),
    Object? category = const $CopyWithPlaceholder(),
    Object? subCategory = const $CopyWithPlaceholder(),
    Object? format = const $CopyWithPlaceholder(),
  }) {
    return Bang(
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
      group: group == const $CopyWithPlaceholder()
          ? _value.group
          // ignore: cast_nullable_to_non_nullable
          : group as BangGroup?,
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
    );
  }
}

extension $BangCopyWith on Bang {
  /// Returns a callable class that can be used as follows: `instanceOfBang.copyWith(...)` or like so:`instanceOfBang.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$BangCWProxy get copyWith => _$BangCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Bang _$BangFromJson(Map<String, dynamic> json) => Bang(
      websiteName: json['s'] as String,
      domain: json['d'] as String,
      trigger: json['t'] as String,
      urlTemplate: json['u'] as String,
      category: json['c'] as String?,
      subCategory: json['sc'] as String?,
      format: (json['fmt'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$BangFormatEnumMap, e))
          .toSet(),
    );

Map<String, dynamic> _$BangToJson(Bang instance) => <String, dynamic>{
      's': instance.websiteName,
      'd': instance.domain,
      't': instance.trigger,
      'u': instance.urlTemplate,
      'c': instance.category,
      'sc': instance.subCategory,
      'fmt': instance.format?.map((e) => _$BangFormatEnumMap[e]!).toList(),
    };

const _$BangFormatEnumMap = {
  BangFormat.openBasePath: 'open_base_path',
  BangFormat.urlEncodePlaceholder: 'url_encode_placeholder',
  BangFormat.urlEncodeSpaceToPlus: 'url_encode_space_to_plus',
};
