import 'package:flutter/foundation.dart';

enum ActiveDialog { none, camera, clothesCategorySelection, humanPhotoPreview }

class DialogState {
  static final ValueNotifier<ActiveDialog> activeDialog = ValueNotifier(
    ActiveDialog.none,
  );

  static void setActiveDialog(ActiveDialog dialog) {
    if (activeDialog.value != dialog) {
      activeDialog.value = dialog;
    }
  }
}
