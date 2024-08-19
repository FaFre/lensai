import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class ConsistentController {
  final InAppWebViewController? value;

  const ConsistentController(this.value);

  @override
  // ignore: avoid_dynamic_calls
  int get hashCode => value?.platform.id.hashCode ?? -1;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ConsistentController) return false;
    return hashCode == other.hashCode;
  }
}
