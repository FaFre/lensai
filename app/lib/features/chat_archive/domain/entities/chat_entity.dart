class ChatEntity {
  static final _namePattern = RegExp(r"^(.*?) - (.*?)\.md$");

  final String fileName;

  final String? name;
  final DateTime? dateTime;

  ChatEntity._(this.fileName, {this.name, this.dateTime});

  factory ChatEntity.fromFileName(String fileName) {
    final match = _namePattern.firstMatch(fileName);

    return ChatEntity._(
      fileName,
      name: match?.group(1),
      dateTime: (match != null) ? DateTime.tryParse(match.group(2)!) : null,
    );
  }

  @override
  String toString() => name ?? fileName;
}
