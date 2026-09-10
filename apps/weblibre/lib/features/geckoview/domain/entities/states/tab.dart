/*
 * Copyright (c) 2024-2026 Fabian Freund.
 *
 * This file is part of WebLibre
 * (see https://weblibre.eu).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:nullability/nullability.dart';
import 'package:weblibre/data/models/web_page_info.dart';
import 'package:weblibre/domain/entities/equatable_image.dart';
import 'package:weblibre/features/geckoview/domain/entities/browser_icon.dart';
import 'package:weblibre/features/geckoview/domain/entities/states/readerable.dart';
import 'package:weblibre/features/geckoview/domain/entities/states/security.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_mode.dart';

part 'tab.g.dart';

/// Per-tab state the browser chrome and tab ordering depend on.
///
/// Deliberately narrow: the whole `Map<String, TabState>` is watched by the
/// providers feeding the always-visible quick tab switcher and the grouped tab
/// list, so any field added here rebuilds every visible chip whenever it
/// changes on *any* tab. High-churn fields (load progress, thumbnails, session
/// history, find-in-page results, translation) live in per-tab notifiers in
/// `providers/tab_detail_state.dart` instead.
@CopyWith(constructor: '_')
class TabState extends WebPageInfo {
  static final defaultUrl = Uri.parse('about:blank');

  @CopyWithField(immutable: true)
  final String id;

  final String? parentId;

  final String? contextId;

  @override
  String get title => super.title!;

  String get titleOrAuthority => (title.isNotEmpty) ? title : url.authority;

  final EquatableImage? icon;

  @override
  BrowserIcon? get favicon => icon.mapNotNull(
    (icon) => BrowserIcon(
      image: icon,
      dominantColor: null,
      source: IconSource.memory,
    ),
  );

  final TabMode tabMode;
  String? get isolationContextId => tabMode.isolationContextId;

  /// Whether the engine has reported this tab's content state.
  ///
  /// Icons, security info and readerable state all seed an entry from
  /// [TabState.$default], which claims a regular, non-isolated tab sitting at
  /// [defaultUrl]. Those defaults are fine to render, but a caller that acts on
  /// the tab's identity — reopening it in another container, say — would carry
  /// a private or isolated tab over as a regular one. It has to wait for the
  /// content event instead; see `TabStates.awaitContentState`.
  ///
  /// Unlike the other fields here this one only ever flips once per tab, so it
  /// costs the tab list a single extra rebuild.
  final bool hasContentState;

  final bool isFullScreen;
  final bool isLoading;
  final bool showToolbarAsExpanded;

  final SecurityState securityInfoState;
  final ReaderableState readerableState;

  TabState({
    required this.id,
    required this.parentId,
    required this.contextId,
    required super.url,
    required String title,
    required this.icon,
    this.tabMode = TabMode.regular,
    this.hasContentState = false,
    required this.isFullScreen,
    required this.isLoading,
    required this.showToolbarAsExpanded,
    required this.securityInfoState,
    required this.readerableState,
  }) : super(title: title.trim());

  TabState._({
    required this.id,
    required this.parentId,
    required this.contextId,
    required super.url,
    required super.title,
    required this.icon,
    required this.tabMode,
    required this.hasContentState,
    required this.isFullScreen,
    required this.isLoading,
    required this.showToolbarAsExpanded,
    required this.securityInfoState,
    required this.readerableState,
  });

  factory TabState.$default(String tabId) => TabState(
    id: tabId,
    parentId: null,
    contextId: null,
    url: defaultUrl,
    title: "",
    icon: null,
    isFullScreen: false,
    isLoading: false,
    showToolbarAsExpanded: false,
    securityInfoState: SecurityState.$default(),
    readerableState: ReaderableState.$default(),
  );

  @override
  List<Object?> get hashParameters => [
    ...super.hashParameters,
    id,
    parentId,
    contextId,
    icon,
    tabMode,
    hasContentState,
    isFullScreen,
    isLoading,
    showToolbarAsExpanded,
    securityInfoState,
    readerableState,
  ];
}
