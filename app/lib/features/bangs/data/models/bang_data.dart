import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:lensai/features/bangs/data/models/bang.dart';
import 'package:lensai/features/geckoview/domain/entities/browser_icon.dart';

part 'bang_data.g.dart';

@CopyWith()
class BangData extends Bang {
  final int frequency;
  final DateTime? lastUsed;

  final BrowserIcon? icon;

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
    this.icon,
  }) : frequency = frequency ?? 0;

  @override
  bool get cacheHash => true;

  @override
  List<Object?> get hashParameters => [
        ...super.hashParameters,
        frequency,
        lastUsed,
        icon,
      ];
}
