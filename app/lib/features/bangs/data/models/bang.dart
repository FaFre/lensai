import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:drift/drift.dart' show Expression, Insertable, Value;
import 'package:fast_equatable/fast_equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:lensai/features/bangs/data/database/database.dart'
    show BangCompanion;

part 'bang.g.dart';

enum BangGroup {
  general(
    'https://raw.githubusercontent.com/kagisearch/bangs/main/data/bangs.json',
  ),
  assistant(
    'https://raw.githubusercontent.com/kagisearch/bangs/main/data/assistant_bangs.json',
  ),
  kagi(
    'https://raw.githubusercontent.com/kagisearch/bangs/main/data/kagi_bangs.json',
  );

  final String url;

  const BangGroup(this.url);
}

enum BangFormat {
  ///When the bang is invoked with no query, opens the base path of the URL (/)
  ///instead of any path given in the template (g., /search)
  @JsonValue('open_base_path')
  openBasePath,

  ///URL encode the search terms. Some sites do not work with this, so it can
  ///be disabled by omitting this.
  @JsonValue('url_encode_placeholder')
  urlEncodePlaceholder,

  ///URL encodes spaces as +, instead of %20. Some sites only work correctly
  ///with one or the other.
  @JsonValue('url_encode_space_to_plus')
  urlEncodeSpaceToPlus,
}

@JsonSerializable()
@CopyWith()
class Bang with FastEquatable implements Insertable<Bang> {
  static const _templateQueryPlaceholder = '{{{s}}}';

  @JsonKey(includeFromJson: false, includeToJson: false)
  final BangGroup? group;

  ///The name of the website associated with the bang.
  @JsonKey(name: 's')
  final String websiteName;

  ///The domain name of the websit
  @JsonKey(name: 'd')
  final String domain;

  ///The specific trigger word or phrase used to invoke the bang.
  @JsonKey(name: 't')
  final String trigger;

  ///The URL template to use when the bang is invoked, where `{{{s}}}` is replaced by the user's query.
  @JsonKey(name: 'u')
  final String urlTemplate;

  ///The category of the website, if applicable
  @JsonKey(name: 'c')
  final String? category;

  ///The subcategory of the website, if applicable
  @JsonKey(name: 'sc')
  final String? subCategory;

  ///The format flags indicating how the query should be processed.
  @JsonKey(name: 'fmt')
  final Set<BangFormat>? format;

  String formatQuery(String input) {
    return (format == null ||
            format!.contains(BangFormat.urlEncodePlaceholder) == true)
        ? (format == null ||
                format?.contains(BangFormat.urlEncodeSpaceToPlus) == true)
            ? Uri.encodeQueryComponent(input)
            : Uri.encodeComponent(input)
        : input;
  }

  Uri getUrl(String? query) {
    final url = (query != null)
        ? urlTemplate.replaceAll(_templateQueryPlaceholder, formatQuery(query))
        : urlTemplate;

    var template = Uri.parse(url);
    if (!template.hasScheme || template.origin.isEmpty) {
      template = Uri.https(domain).replace(
        path: template.path,
        query: template.query,
      );
    }

    return template;
  }

  static Set<BangFormat> decodeFormat(Iterable input) {
    return input.map((e) => $enumDecode(_$BangFormatEnumMap, e)).toSet();
  }

  static List<String> encodeFormat(Iterable<BangFormat> format) {
    return format.map((e) => _$BangFormatEnumMap[e]!).toList();
  }

  Bang({
    required this.websiteName,
    required this.domain,
    required this.trigger,
    required this.urlTemplate,
    this.group,
    this.category,
    this.subCategory,
    this.format,
  });

  factory Bang.fromJson(Map<String, dynamic> json) => _$BangFromJson(json);

  Map<String, dynamic> toJson() => _$BangToJson(this);

  @override
  bool get cacheHash => true;

  @override
  List<Object?> get hashParameters => [
        group,
        websiteName,
        domain,
        trigger,
        urlTemplate,
        category,
        subCategory,
        format,
      ];

  @override
  Map<String, Expression<Object>> toColumns(bool nullToAbsent) {
    return BangCompanion(
      trigger: Value(trigger),
      websiteName: Value(websiteName),
      domain: Value(domain),
      urlTemplate: Value(urlTemplate),
      group: Value.absentIfNull(group),
      category: Value.absentIfNull(category),
      subCategory: Value.absentIfNull(subCategory),
      format: Value.absentIfNull(format),
    ).toColumns(nullToAbsent);
  }
}
