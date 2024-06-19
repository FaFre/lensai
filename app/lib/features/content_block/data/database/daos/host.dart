import 'package:bang_navigator/features/content_block/data/database/database.dart';
import 'package:bang_navigator/features/content_block/data/models/host.dart';
import 'package:drift/drift.dart';

part 'host.g.dart';

@DriftAccessor()
class HostDao extends DatabaseAccessor<HostDatabase> with _$HostDaoMixin {
  HostDao(super.db);

  Selectable<HostData> getHostList({Iterable<HostSource>? sources}) {
    final selectable = select(db.host);
    if (sources != null) {
      selectable.where((t) => t.source.isInValues(sources));
    }

    return selectable;
  }

  SingleSelectable<int> getHostCount({Iterable<HostSource>? sources}) {
    return db.host.count(
      where: (sources != null) ? (t) => t.source.isInValues(sources) : null,
    );
  }
}
