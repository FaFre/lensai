import 'package:json_annotation/json_annotation.dart';

part 'prompt.g.dart';

@JsonSerializable()
class Focus {
  @JsonKey(name: 'thread_id')
  final String? threadId;
  @JsonKey(name: 'branch_id')
  final String branchId;
  final String prompt;
  @JsonKey(name: 'message_id')
  final String? messageId;

  Focus({
    this.threadId,
    required this.branchId,
    required this.prompt,
    this.messageId,
  });

  factory Focus.fromJson(Map<String, dynamic> json) => _$FocusFromJson(json);
  Map<String, dynamic> toJson() => _$FocusToJson(this);
}

@JsonSerializable()
class Profile {
  final int? id;
  @JsonKey(name: 'lens_id')
  final int lensId;
  final String model;
  @JsonKey(name: 'internet_access')
  final bool internetAccess;

  Profile({
    this.id,
    required this.lensId,
    required this.model,
    required this.internetAccess,
  });

  factory Profile.fromJson(Map<String, dynamic> json) =>
      _$ProfileFromJson(json);
  Map<String, dynamic> toJson() => _$ProfileToJson(this);
}

@JsonSerializable()
class Prompt {
  final Focus focus;
  final Profile profile;

  Prompt({required this.focus, required this.profile});

  factory Prompt.fromJson(Map<String, dynamic> json) => _$PromptFromJson(json);
  Map<String, dynamic> toJson() => _$PromptToJson(this);
}
