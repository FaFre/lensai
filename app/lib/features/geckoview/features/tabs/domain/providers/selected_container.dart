import 'package:lensai/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:lensai/features/geckoview/features/tabs/data/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'selected_container.g.dart';

@Riverpod(keepAlive: true)
class SelectedContainer extends _$SelectedContainer {
  void setContainerId(String id) {
    state = id;
  }

  void toggleContainer(String id) {
    if (state == id) {
      clearContainer();
    } else {
      setContainerId(id);
    }
  }

  void clearContainer() {
    state = null;
  }

  @override
  String? build() {
    return null;
  }
}

@Riverpod()
Stream<ContainerData?> selectedContainerData(SelectedContainerDataRef ref) {
  final db = ref.watch(tabDatabaseProvider);
  final selectedContainer = ref.watch(selectedContainerProvider);

  if (selectedContainer != null) {
    return db.containerDao
        .getContainerData(selectedContainer)
        .watchSingleOrNull();
  }

  return Stream.value(null);
}
