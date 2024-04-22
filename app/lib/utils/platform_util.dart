import 'package:flutter/foundation.dart';

bool isAndroid() {
  return !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
}

bool isIOS() {
  return !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
}
