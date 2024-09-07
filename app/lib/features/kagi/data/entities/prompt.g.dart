// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prompt.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Focus _$FocusFromJson(Map<String, dynamic> json) => Focus(
      threadId: json['thread_id'] as String?,
      branchId: json['branch_id'] as String,
      prompt: json['prompt'] as String,
      messageId: json['message_id'] as String?,
    );

Map<String, dynamic> _$FocusToJson(Focus instance) => <String, dynamic>{
      'thread_id': instance.threadId,
      'branch_id': instance.branchId,
      'prompt': instance.prompt,
      'message_id': instance.messageId,
    };

Profile _$ProfileFromJson(Map<String, dynamic> json) => Profile(
      id: (json['id'] as num?)?.toInt(),
      lensId: (json['lens_id'] as num).toInt(),
      model: json['model'] as String,
      internetAccess: json['internet_access'] as bool,
    );

Map<String, dynamic> _$ProfileToJson(Profile instance) => <String, dynamic>{
      'id': instance.id,
      'lens_id': instance.lensId,
      'model': instance.model,
      'internet_access': instance.internetAccess,
    };

Prompt _$PromptFromJson(Map<String, dynamic> json) => Prompt(
      focus: Focus.fromJson(json['focus'] as Map<String, dynamic>),
      profile: Profile.fromJson(json['profile'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PromptToJson(Prompt instance) => <String, dynamic>{
      'focus': instance.focus,
      'profile': instance.profile,
    };
