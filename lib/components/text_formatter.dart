import 'package:flutter/services.dart';

/// 正整数输入格式化器（自动过滤非数字并处理前导零）
class PositiveIntegerInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    // 允许空输入
    if (newValue.text.isEmpty) return newValue;

    // 过滤非数字字符
    if (!RegExp(r'^\d*$').hasMatch(newValue.text)) return oldValue;

    String newText = newValue.text;

    // 处理前导零（如 "0123" → "123"）
    if (newText.startsWith('0') && newText.length > 1) {
      newText = newText.replaceFirst(RegExp(r'^0+'), '');
      return TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length),
      );
    }

    return newValue;
  }
}