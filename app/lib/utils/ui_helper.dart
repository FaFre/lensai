import 'package:flutter/material.dart';

void showErrorMessage(BuildContext context, String message) {
  final snackBar = SnackBar(
    content: Text(
      message,
      style: TextStyle(
        color: Theme.of(context).colorScheme.error,
      ),
    ),
    backgroundColor: Theme.of(context).colorScheme.onError,
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
