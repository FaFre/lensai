import 'package:uuid/data.dart';
import 'package:uuid/rng.dart';
import 'package:uuid/uuid.dart';

final uuid = Uuid(goptions: GlobalOptions(CryptoRNG()));
