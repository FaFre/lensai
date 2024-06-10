import 'package:bang_navigator/features/bangs/data/models/bang.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:drift/drift.dart';

part 'bang_data.g.dart';

@CopyWith()
class BangData extends Bang {
  final int frequency;
  final DateTime? lastUsed;

  final Uint8List? iconData;

  BangData({
    required super.websiteName,
    required super.domain,
    required super.trigger,
    required super.urlTemplate,
    super.category,
    super.subCategory,
    super.format,
    int? frequency,
    this.lastUsed,
    this.iconData,
  }) : frequency = frequency ?? 0;

  @override
  bool get cacheHash => true;

  @override
  List<Object?> get hashParameters => [
        ...super.hashParameters,
        frequency,
        lastUsed,
        iconData,
      ];
}
