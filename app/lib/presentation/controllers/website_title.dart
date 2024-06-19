import 'package:bang_navigator/domain/entities/web_page_info.dart';
import 'package:bang_navigator/domain/services/generic_website.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'website_title.g.dart';

@Riverpod(keepAlive: true)
Future<WebPageInfo> pageInfo(PageInfoRef ref, Uri url) {
  final websiteService = ref.watch(genericWebsiteServiceProvider.notifier);
  return websiteService.getInfo(url).then((value) => value.value);
}
