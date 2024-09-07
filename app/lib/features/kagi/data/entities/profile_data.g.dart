// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Profile _$ProfileFromJson(Map<String, dynamic> json) => Profile(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String,
      model: json['model'] as String,
      modelProvider: json['model_provider'] as String,
      modelInputLimit: (json['model_input_limit'] as num).toInt(),
      internetAccess: json['internet_access'] as bool,
      personalizations: json['personalizations'] as bool,
    );

Map<String, dynamic> _$ProfileToJson(Profile instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'model': instance.model,
      'model_provider': instance.modelProvider,
      'model_input_limit': instance.modelInputLimit,
      'internet_access': instance.internetAccess,
      'personalizations': instance.personalizations,
    };

Lens _$LensFromJson(Map<String, dynamic> json) => Lens(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      description: json['description'] as String?,
    );

Map<String, dynamic> _$LensToJson(Lens instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
    };

ProfileData _$ProfileDataFromJson(Map<String, dynamic> json) => ProfileData(
      profiles: (json['profiles'] as List<dynamic>)
          .map((e) => Profile.fromJson(e as Map<String, dynamic>))
          .toList(),
      lenses: (json['lenses'] as List<dynamic>)
          .map((e) => Lens.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ProfileDataToJson(ProfileData instance) =>
    <String, dynamic>{
      'profiles': instance.profiles,
      'lenses': instance.lenses,
    };
