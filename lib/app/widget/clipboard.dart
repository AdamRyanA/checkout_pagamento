import 'package:flutter/services.dart';

class ClipboardHelper {
  static Future<void> copy(String value) async {
    await Clipboard.setData(ClipboardData(text: value));
  }

  static Future<String> paste() async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    return clipboardData?.text ?? '';
  }

  static Future<bool> hasData() async => Clipboard.hasStrings();
}
