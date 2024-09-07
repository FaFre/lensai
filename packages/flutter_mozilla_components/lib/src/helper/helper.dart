import 'package:flutter_mozilla_components/src/data/models/source.dart';

/// Maps an int category (as it can be obtained from a package manager) to our internal representation.
PackageCategory packageCategoryfromInt(int? id) {
  return PackageCategory.values.firstWhere(
    (category) => category.id == id,
    orElse: () => PackageCategory.unknown,
  );
}
