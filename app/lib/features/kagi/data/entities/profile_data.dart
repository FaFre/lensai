import 'package:json_annotation/json_annotation.dart';

part 'profile_data.g.dart';

@JsonSerializable()
class Profile {
  final int? id;
  final String name;
  final String model;
  @JsonKey(name: 'model_provider')
  final String modelProvider;
  @JsonKey(name: 'model_input_limit')
  final int modelInputLimit;
  @JsonKey(name: 'internet_access')
  final bool internetAccess;
  final bool personalizations;

  Profile({
    this.id,
    required this.name,
    required this.model,
    required this.modelProvider,
    required this.modelInputLimit,
    required this.internetAccess,
    required this.personalizations,
  });

  factory Profile.fromJson(Map<String, dynamic> json) =>
      _$ProfileFromJson(json);
  Map<String, dynamic> toJson() => _$ProfileToJson(this);
}

@JsonSerializable()
class Lens {
  final int id;
  final String name;
  final String? description;

  Lens({
    required this.id,
    required this.name,
    this.description,
  });

  factory Lens.fromJson(Map<String, dynamic> json) => _$LensFromJson(json);
  Map<String, dynamic> toJson() => _$LensToJson(this);
}

@JsonSerializable()
class ProfileData {
  final List<Profile> profiles;
  final List<Lens> lenses;

  ProfileData({
    required this.profiles,
    required this.lenses,
  });

  factory ProfileData.fromJson(Map<String, dynamic> json) =>
      _$ProfileDataFromJson(json);
  Map<String, dynamic> toJson() => _$ProfileDataToJson(this);
}
