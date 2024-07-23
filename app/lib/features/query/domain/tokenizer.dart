import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:lensai/features/query/domain/entities/abstract/i_query_builder.dart';
import 'package:lensai/features/query/domain/entities/bareword.dart';

typedef _Phrase = List<Bareword>;

sealed class QueryBuilder {
  ///Matching quoted strings like "xda bda" (group 1), as well as strings delimetered by
  ///a whitespace (group 2)
  static final _tokenizePattern = RegExp('"([^"]+)"|([^ ]+)');

  ///Reserved FTS5 baewords
  static const _reservedBarewords = {'AND', 'OR', 'NOT'};

  ///Checks if string is an bareword accoring to:
  ///https://www.sqlite.org/fts5.html#fts5_strings
  ///
  ///Elsewise ths string needs to get quoted
  static final _barewordPattern =
      RegExp(r'^([^\x00-\x7F]|[\w]|[\d]|[_]|[\x1A])+$');

  static bool _isReservedBareword(Bareword input) =>
      _reservedBarewords.contains(input.word);

  late final _Phrase _tokens;

  QueryBuilder.tokenize({
    required String input,
    required int minTokenLength,
    required int tokenLimit,
  }) {
    final matches = _tokenizePattern.allMatches(input);

    final barewords = matches
        .map((match) {
          if (match.group(1) != null) {
            return EnclosedBareword(match.group(1)!);
          } else if (_barewordPattern.hasMatch(match.group(2)!)) {
            return SimpleBareword(match.group(2)!);
          } else {
            return EnclosedBareword(match.group(2)!);
          }
        })
        .where((token) => token.word.isNotEmpty)
        .whereNot(_isReservedBareword)
        .toList();

    //Merge short tokens
    _mergeShortBarewords(barewords, minTokenLength);

    _tokens = barewords.take(tokenLimit).toList();
  }

  static void _mergeShortBarewords(
    List<Bareword> barewords,
    int minTokenLength,
  ) {
    for (var i = 0; i < barewords.length; i++) {
      final bareword = barewords[i];

      if (i != 0) {
        if (bareword.word.length < minTokenLength) {
          barewords[i] = barewords[i - 1].join(bareword);
        }
      }
    }
  }

  //Get weighted groups of tokens
  //Weight depends on order
  static List<_Phrase> _getWeighted(List<Bareword> tokens) {
    if (tokens.isEmpty) {
      return [];
    }

    final phrases = List.generate(
      tokens.length - 1,
      (index) => tokens.sublist(0, tokens.length - index),
    );

    phrases.addAll(tokens.map((token) => [token]));

    return phrases;
  }

  //Get all combinations of input tokens and treat them as equally
  //Match of bigger group will have greater score
  static List<_Phrase> _getCombinations(List<Bareword> tokens) {
    if (tokens.isEmpty) {
      return [];
    }

    final combinations = <_Phrase>[];
    final slent = math.pow(2, tokens.length);

    for (var i = 0; i < slent; i++) {
      final temp = <Bareword>[];

      for (var j = 0; j < tokens.length; j++) {
        if ((i & math.pow(2, j).toInt()) > 0) {
          temp.add(tokens[j]);
        }
      }

      if (temp.isNotEmpty) {
        combinations.add(temp);
      }
    }

    return combinations;
  }

  //If we have multiple unenclosed token, combine them into quoted to
  //get a better full range match
  //TODO: Before migration this was only used for non-prefix tokens, check for side effects
  static List<_Phrase> _combineUnenclosed(_Phrase phrase) {
    return [
      phrase,
      if (phrase.length > 2 &&
          phrase.every((bareword) => bareword is SimpleBareword))
        [EnclosedBareword(phrase.join(barewordConcat))],
    ];
  }

  //Decinding query strategy
  static List<_Phrase> _generatePhrases(List<Bareword> tokens) {
    if (tokens.length <= 4) {
      return _getCombinations(tokens);
    } else if (tokens.length <= 8) {
      return _getWeighted(tokens);
    } else {
      return [tokens];
    }
  }

  static _Phrase _removeDependendBarewords(List<Bareword> phrase) {
    final joinedPhrase = List.of(phrase);

    for (var i = 0; i < joinedPhrase.length; i++) {
      final bareword = joinedPhrase[i];

      //Remove dependend phrases
      if (joinedPhrase.whereType<JoinedBareword>().any(
            (joined) => joined.dependencies.contains(bareword),
          )) {
        joinedPhrase.removeAt(i);
        i--;
      }
    }

    return joinedPhrase;
  }

  String _buildQuery(
    List<Bareword> tokens,
    String Function(List<Bareword> phrase) barewordConcat,
    String phraseConcat,
  ) {
    final phrases = _generatePhrases(tokens)
        .map(_removeDependendBarewords)
        .expand(_combineUnenclosed);

    return phrases
        .where((phrase) => phrase.isNotEmpty)
        .sortedBy<num>((x) => x.length)
        .reversed
        .map(barewordConcat)
        .toSet()
        .join(phraseConcat);
  }

  String build();
}

final class PrefixQueryBuilder extends QueryBuilder {
  PrefixQueryBuilder.tokenize({
    required super.input,
    required super.minTokenLength,
    required super.tokenLimit,
  }) : super.tokenize();

  @override
  String build() {
    return _buildQuery(
      _tokens,
      (phrase) {
        if (phrase.length == 1) {
          return '${phrase.first}*';
        }

        return 'NEAR(${phrase.map((bareword) => '$bareword*').join(' ')})';
      },
      ' OR ',
    );
  }
}

final class TrigramQueryBuilder extends QueryBuilder {
  TrigramQueryBuilder.tokenize({
    required super.input,
    required super.minTokenLength,
    required super.tokenLimit,
  }) : super.tokenize();

  @override
  String build() {
    return _buildQuery(
      _tokens,
      (phrase) => phrase.join(' '),
      ' OR ',
    );
  }
}

mixin PrefixQueryBuilderMixin implements IQueryBuilder {
  @override
  String buildQuery(String input) {
    final queryBuilder = PrefixQueryBuilder.tokenize(
      input: input,
      minTokenLength: ftsMinTokenLength,
      tokenLimit: ftsTokenLimit,
    );

    return queryBuilder.build();
  }
}

mixin TrigramQueryBuilderMixin implements IQueryBuilder {
  @override
  String buildQuery(String input) {
    final queryBuilder = TrigramQueryBuilder.tokenize(
      input: input,
      minTokenLength: ftsMinTokenLength,
      tokenLimit: ftsTokenLimit,
    );

    return queryBuilder.build();
  }
}
