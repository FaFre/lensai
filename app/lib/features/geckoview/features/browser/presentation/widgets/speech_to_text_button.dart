import 'package:flutter/material.dart';
import 'package:lensai/utils/ui_helper.dart' as ui_helper;
import 'package:speech_to_text_google_dialog/speech_to_text_google_dialog.dart';

class SpeechToTextButton extends StatelessWidget {
  final Function(dynamic data) onTextReceived;

  const SpeechToTextButton({required this.onTextReceived, super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () async {
        final isServiceAvailable =
            await SpeechToTextGoogleDialog.getInstance().showGoogleDialog(
          onTextReceived: onTextReceived,
          // locale: "en-US",
        );

        if (!isServiceAvailable) {
          if (context.mounted) {
            ui_helper.showErrorMessage(
              context,
              'Service is not available',
            );
          }
        }
      },
      icon: const Icon(Icons.mic),
    );
  }
}
