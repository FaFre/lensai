import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lensai/features/about/data/repositories/package_info_repository.dart';

class AboutDialogScreen extends HookConsumerWidget {
  const AboutDialogScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packageInfo = ref.watch(
      packageInfoProvider.select(
        //During startup we make sure
        (value) => value.value!,
      ),
    );

    return AboutDialog(
      applicationIcon: SizedBox.square(
        dimension: IconTheme.of(context).size,
        child: Image.asset('assets/icon/icon.png'),
      ),
      applicationName: packageInfo.appName,
      applicationVersion: packageInfo.version,
      applicationLegalese: 'Copyright © Fabian Freund, 2024',
    );
  }
}
