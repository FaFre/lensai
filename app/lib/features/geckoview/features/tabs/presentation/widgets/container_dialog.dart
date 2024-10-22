import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:lensai/features/geckoview/features/tabs/presentation/widgets/material_color_picker.dart';

typedef ContainerResult = ({String? name, Color color});

enum _DialogMode { create, edit }

class ContainerDialog extends HookWidget {
  final _DialogMode _mode;

  final String? initialName;
  final Color initialColor;

  const ContainerDialog._({
    required _DialogMode mode,
    required this.initialColor,
    this.initialName,
  }) : _mode = mode;

  factory ContainerDialog.create({required Color initialColor}) {
    return ContainerDialog._(
      mode: _DialogMode.create,
      initialColor: initialColor,
    );
  }

  factory ContainerDialog.edit({
    required String? name,
    required Color initialColor,
  }) {
    return ContainerDialog._(
      mode: _DialogMode.edit,
      initialColor: initialColor,
      initialName: name,
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedColor = useState<Color>(initialColor);
    final textController = useTextEditingController(text: initialName);

    return SimpleDialog(
      titlePadding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 16.0),
      contentPadding: const EdgeInsets.only(
        left: 20.0,
        right: 20.0,
        bottom: 24.0,
      ),
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 20.0,
        vertical: 24.0,
      ),
      title: Text(
        switch (_mode) {
          _DialogMode.create => 'New Container',
          _DialogMode.edit => 'Edit Container',
        },
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: TextField(
            decoration: InputDecoration(
              prefixIcon: Padding(
                padding: const EdgeInsets.all(10.0),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 24,
                  width: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selectedColor.value,
                  ),
                ),
              ),
              label: const Text('Name'),
            ),
            controller: textController,
          ),
        ),
        const SizedBox(height: 16),
        MaterialPicker(
          pickerColor: selectedColor.value,
          onColorChanged: (value) {
            selectedColor.value = value;
          },
        ),
        const SizedBox(height: 24),
        OverflowBar(
          alignment: MainAxisAlignment.end,
          spacing: 8.0,
          children: [
            TextButton(
              onPressed: () {
                Navigator.pop<ContainerResult?>(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final name = textController.text.trim();
                Navigator.pop<ContainerResult?>(
                  context,
                  (
                    name: name.isNotEmpty ? name : null,
                    color: selectedColor.value,
                  ),
                );
              },
              child: Text(
                switch (_mode) {
                  _DialogMode.create => 'Add',
                  _DialogMode.edit => 'Edit',
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
