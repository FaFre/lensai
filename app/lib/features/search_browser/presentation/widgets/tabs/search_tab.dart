import 'package:bang_navigator/features/bangs/domain/providers.dart';
import 'package:bang_navigator/features/bangs/domain/repositories/bang_data.dart';
import 'package:bang_navigator/features/bangs/presentation/widgets/bang_icon.dart';
import 'package:bang_navigator/features/kagi/domain/repositories/autosuggest.dart';
import 'package:bang_navigator/features/search_browser/domain/providers.dart';
import 'package:bang_navigator/features/search_browser/presentation/widgets/bang_chips.dart';
import 'package:bang_navigator/features/search_browser/presentation/widgets/sheets/shared_content_sheet.dart';
import 'package:bang_navigator/features/search_browser/presentation/widgets/speech_to_text_button.dart';
import 'package:bang_navigator/features/share_intent/domain/entities/shared_content.dart';
import 'package:bang_navigator/presentation/widgets/autocomplete.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// The default Material-style Autocomplete options.
class _AutocompleteOptions<T extends Object> extends StatelessWidget {
  const _AutocompleteOptions({
    super.key,
    required this.displayStringForOption,
    required this.onSelected,
    required this.openDirection,
    required this.options,
    required this.maxOptionsHeight,
  });

  final AutocompleteOptionToString<T> displayStringForOption;

  final AutocompleteOnSelected<T> onSelected;
  final OptionsViewOpenDirection openDirection;

  final Iterable<T> options;
  final double maxOptionsHeight;

  @override
  Widget build(BuildContext context) {
    final AlignmentDirectional optionsAlignment = switch (openDirection) {
      OptionsViewOpenDirection.up => AlignmentDirectional.bottomStart,
      OptionsViewOpenDirection.down => AlignmentDirectional.topStart,
    };
    return Align(
      alignment: optionsAlignment,
      child: Material(
        elevation: 4.0,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxOptionsHeight),
          child: ListView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            reverse: switch (openDirection) {
              OptionsViewOpenDirection.up => true,
              OptionsViewOpenDirection.down => false,
            },
            itemCount: options.length,
            itemBuilder: (BuildContext context, int index) {
              final T option = options.elementAt(index);
              return InkWell(
                onTap: () {
                  onSelected(option);
                },
                child: Builder(
                  builder: (BuildContext context) {
                    final bool highlight =
                        AutocompleteHighlightedOption.of(context) == index;
                    // if (highlight) {
                    //   SchedulerBinding.instance.addPostFrameCallback(
                    //     (Duration timeStamp) async {
                    //       await Scrollable.ensureVisible(
                    //         context,
                    //         alignment: 0.5,
                    //       );
                    //     },
                    //     debugLabel: 'AutocompleteOptions.ensureVisible',
                    //   );
                    // }
                    return Container(
                      color: highlight ? Theme.of(context).focusColor : null,
                      padding: const EdgeInsets.all(16.0),
                      child: Text(displayStringForOption(option)),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class SearchTab extends HookConsumerWidget {
  static const _maxOptionsHeight = 158.0;

  final SharedContent? sharedContent;
  final OnSubmitUri onSubmit;

  const SearchTab({
    required this.sharedContent,
    required this.onSubmit,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useAutomaticKeepAlive();

    final formKey = useMemoized(() => GlobalKey<FormState>());
    final focusNode = useFocusNode();

    final selectedBangAsync = ref.watch(selectedBangDataProvider);
    final defaultSearchBangAsync = ref.watch(kagiSearchBangDataProvider);

    final activeBang =
        selectedBangAsync.valueOrNull ?? defaultSearchBangAsync.valueOrNull;

    final textController =
        useTextEditingController(text: sharedContent?.toString());

    final quickAnswer = useListenableSelector(
      textController,
      () => textController.text.endsWith('?'),
    );

    return Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 4),
          selectedBangAsync.when(
            skipLoadingOnReload: true,
            data: (selectedBang) {
              return BangChips(
                selectedBang: selectedBang,
                onSelected: (trigger) {
                  ref
                      .read(selectedBangTriggerProvider.notifier)
                      .setTrigger(trigger);
                },
                onDeleted: (trigger) {
                  if (ref.read(selectedBangTriggerProvider) == trigger) {
                    ref
                        .read(selectedBangTriggerProvider.notifier)
                        .clearTrigger();
                  }
                },
              );
            },
            error: (error, stackTrace) => SizedBox.shrink(),
            loading: () => SizedBox.shrink(),
          ),
          Consumer(
            builder: (context, ref, child) {
              final optionsStream = ref.watch(autosuggestRepositoryProvider);
              final openDirection = ref.watch(
                bottomSheetExtendProvider.select((value) {
                  final extend = value.valueOrNull;
                  if (extend == null ||
                      (MediaQuery.of(context).size.height * (1 - extend)) >
                          _maxOptionsHeight) {
                    return OptionsViewOpenDirection.up;
                  } else {
                    return OptionsViewOpenDirection.down;
                  }
                }),
              );

              return ExternalResultsAutocomplete<String>(
                textEditingController: textController,
                optionsStream: optionsStream,
                focusNode: focusNode,
                optionsViewOpenDirection: openDirection,
                displayStringForOption:
                    // ignore: avoid_redundant_argument_values
                    RawAutocomplete.defaultStringForOption,
                optionsViewBuilder: (context, onSelected, options) {
                  return _AutocompleteOptions(
                    //Must match RawAutocomplete parent
                    displayStringForOption:
                        RawAutocomplete.defaultStringForOption,
                    onSelected: onSelected,
                    options: options,
                    //Must match RawAutocomplete parent
                    openDirection: openDirection,
                    maxOptionsHeight: _maxOptionsHeight,
                  );
                },
                onTextChanged: (textEditingValue) {
                  ref
                      .read(autosuggestRepositoryProvider.notifier)
                      .addQuery(textEditingValue.text);
                },
                fieldViewBuilder: (
                  context,
                  textEditingController,
                  focusNode,
                  onFieldSubmitted,
                ) {
                  return TextFormField(
                    controller: textEditingController,
                    focusNode: focusNode,
                    decoration: InputDecoration(
                      prefixIcon: (activeBang != null)
                          ? Padding(
                              padding: const EdgeInsetsDirectional.all(12.0),
                              child: BangIcon(activeBang, iconSize: 24.0),
                            )
                          : null,
                      label: const Text('Query'),
                      hintText: 'Ask anything...',
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      suffixIcon: SpeechToTextButton(
                        onTextReceived: (data) {
                          textEditingController.text = data.toString();
                        },
                      ),
                    ),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return '';
                      }

                      return null;
                    },
                    onTapOutside: (event) {
                      focusNode.unfocus();
                    },
                    onFieldSubmitted: (_) async {
                      if (activeBang != null &&
                          (formKey.currentState?.validate() == true)) {
                        await ref
                            .read(bangDataRepositoryProvider.notifier)
                            .increaseFrequency(activeBang.trigger);

                        onSubmit(activeBang.getUrl(textController.text));
                      }
                    },
                  );
                },
              );
            },
          ),
          SwitchListTile(
            value: quickAnswer,
            onChanged: (_) {
              if (textController.text.endsWith('?')) {
                textController.text = textController.text
                    .substring(0, textController.text.length - 1);
              } else {
                textController.text = '${textController.text}?';
              }
            },
            contentPadding: EdgeInsets.zero,
            title: const Text('Quick Answer'),
            secondary: const Icon(MdiIcons.lightningBolt),
          ),
          const SizedBox(
            height: 12,
          ),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () async {
                if (activeBang != null &&
                    (formKey.currentState?.validate() == true)) {
                  await ref
                      .read(bangDataRepositoryProvider.notifier)
                      .increaseFrequency(activeBang.trigger);

                  onSubmit(activeBang.getUrl(textController.text));
                }
              },
              label: const Text('Search'),
              icon: const Icon(MdiIcons.invoiceTextSend),
            ),
          ),
        ],
      ),
    );
  }
}
