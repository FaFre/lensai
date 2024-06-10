abstract interface class IQueryBuilder {
  int get ftsTokenLimit;
  int get ftsMinTokenLength;

  String buildQuery(String input);
}
