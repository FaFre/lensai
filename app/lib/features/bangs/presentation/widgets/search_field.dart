// The default Material-style Autocomplete options.
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lensai/features/bangs/data/models/bang_data.dart';
import 'package:lensai/features/bangs/presentation/widgets/bang_icon.dart';
import 'package:lensai/features/kagi/domain/repositories/autosuggest.dart';
import 'package:lensai/features/search_browser/presentation/widgets/speech_to_text_button.dart';
import 'package:lensai/features/settings/data/models/settings.dart';
import 'package:lensai/features/settings/data/repositories/settings_repository.dart';
import 'package:lensai/presentation/widgets/autocomplete.dart';

class SearchField extends HookConsumerWidget {
  static const defaultMaxOptionsHeight = 158.0;

  final TextEditingController textController;
  final BangData? activeBang;
  final OptionsViewOpenDirection openDirection;
  final double maxOptionsHeight;
  final void Function(String)? onFieldSubmitted;

  const SearchField({
    required this.textController,
    required this.activeBang,
    this.openDirection = OptionsViewOpenDirection.up,
    this.maxOptionsHeight = defaultMaxOptionsHeight,
    this.onFieldSubmitted,
    super.key,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incognitoEnabled = ref.watch(
      settingsRepositoryProvider.select(
        (value) => (value.valueOrNull ?? Settings.withDefaults()).incognitoMode,
      ),
    );

    final optionsStream = ref.watch(autosuggestRepositoryProvider);

    final focusNode = useFocusNode();

    final quickAnswer = useListenableSelector(
      textController,
      () => textController.text.endsWith('?'),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ExternalResultsAutocomplete<String>(
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
              displayStringForOption: RawAutocomplete.defaultStringForOption,
              onSelected: onSelected,
              options: options,
              //Must match RawAutocomplete parent
              openDirection: openDirection,
              maxOptionsHeight: maxOptionsHeight,
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
              enableIMEPersonalizedLearning: !incognitoEnabled,
              focusNode: focusNode,
              decoration: InputDecoration(
                prefixIcon: (activeBang != null)
                    ? Padding(
                        padding: const EdgeInsetsDirectional.all(12.0),
                        child: BangIcon(activeBang!, iconSize: 24.0),
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
              onFieldSubmitted: this.onFieldSubmitted,
            );
          },
        ),
        if (activeBang?.domain.endsWith('kagi.com') == true)
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
      ],
    );
  }
}

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
