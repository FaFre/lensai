import 'package:fast_equatable/fast_equatable.dart';

class SecurityState with FastEquatable {
  final bool secure;
  final String host;
  final String issuer;

  SecurityState({
    required this.secure,
    required this.host,
    required this.issuer,
  });

  factory SecurityState.$default() => SecurityState(
        secure: false,
        host: "",
        issuer: "",
      );

  @override
  bool get cacheHash => true;

  @override
  List<Object?> get hashParameters => [secure, host, issuer];
}
