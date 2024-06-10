const barewordConcat = ' ';

sealed class Bareword {
  final String word;

  @override
  int get hashCode => word.hashCode;

  Bareword(String word) : word = word.replaceAll('"', '""');

  @override
  bool operator ==(Object other) {
    if (other is Bareword) {
      return word == other.word;
    }

    return false;
  }

  JoinedBareword join(Bareword other) {
    return JoinedBareword(other.word, this);
  }
}

final class SimpleBareword extends Bareword {
  SimpleBareword(super.word);

  @override
  String toString() => word;
}

final class EnclosedBareword extends Bareword {
  EnclosedBareword(super.word);

  @override
  String toString() {
    return '"$word"';
  }
}

final class JoinedBareword extends Bareword {
  final Bareword parent;

  JoinedBareword(super.bareword, this.parent);

  bool hasDependency(Bareword other) {
    if (parent is JoinedBareword) {
      return (parent as JoinedBareword).hasDependency(other);
    } else {
      return parent == other;
    }
  }

  Iterable<Bareword> get dependencies {
    final depencies = <Bareword>[parent];
    while (depencies.last is JoinedBareword) {
      depencies.add((depencies.last as JoinedBareword).parent);
    }

    return depencies.reversed;
  }

  @override
  String toString() {
    final deps = dependencies
        .map((bareword) => bareword.toString())
        .join(barewordConcat);
    return '"$deps$barewordConcat$word"';
  }
}
