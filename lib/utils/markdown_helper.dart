import 'package:flutter/material.dart';

/// Helper class for markdown text manipulation
class MarkdownHelper {
  MarkdownHelper._(); // Private constructor

  /// Insert markdown syntax at cursor position
  static void insertMarkdown({
    required TextEditingController controller,
    required String prefix,
    String suffix = '',
    String? placeholder,
  }) {
    final text = controller.text;
    final selection = controller.selection;
    final start = selection.start;
    final end = selection.end;

    String newText;
    int newCursorPos;

    if (selection.isValid && start != end) {
      // Text is selected
      final selectedText = text.substring(start, end);
      final wrappedText = '$prefix$selectedText$suffix';
      newText = text.replaceRange(start, end, wrappedText);
      newCursorPos = start + wrappedText.length;
    } else {
      // No selection, insert placeholder
      final placeholderText = placeholder ?? 'text';
      final wrappedText = '$prefix$placeholderText$suffix';
      final insertPos = selection.start >= 0 ? selection.start : text.length;
      newText = text.substring(0, insertPos) +
          wrappedText +
          text.substring(insertPos);
      newCursorPos = insertPos + prefix.length + placeholderText.length;
    }

    controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newCursorPos),
    );
  }

  /// Insert bold markdown
  static void insertBold(TextEditingController controller) {
    insertMarkdown(
      controller: controller,
      prefix: '**',
      suffix: '**',
      placeholder: 'bold text',
    );
  }

  /// Insert italic markdown
  static void insertItalic(TextEditingController controller) {
    insertMarkdown(
      controller: controller,
      prefix: '*',
      suffix: '*',
      placeholder: 'italic text',
    );
  }

  /// Insert heading markdown
  static void insertHeading(
    TextEditingController controller, {
    int level = 1,
  }) {
    final prefix = '${'#' * level} ';
    final text = controller.text;
    final selection = controller.selection;
    final start = selection.start >= 0 ? selection.start : text.length;

    // Find the start of the current line
    int lineStart = start;
    while (lineStart > 0 && text[lineStart - 1] != '\n') {
      lineStart--;
    }

    // Check if line already has heading syntax
    final lineText = text.substring(lineStart, start);
    final headingMatch = RegExp(r'^(#{1,6} )').firstMatch(lineText);

    String newText;
    int newCursorPos;

    if (headingMatch != null) {
      // Remove existing heading
      newText = text.replaceRange(
        lineStart,
        lineStart + headingMatch.group(0)!.length,
        prefix,
      );
      newCursorPos = lineStart + prefix.length;
    } else {
      // Add heading
      newText = text.substring(0, lineStart) +
          prefix +
          text.substring(lineStart);
      newCursorPos = start + prefix.length;
    }

    controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newCursorPos),
    );
  }

  /// Insert bullet list item
  static void insertBulletList(TextEditingController controller) {
    final text = controller.text;
    final selection = controller.selection;
    final start = selection.start >= 0 ? selection.start : text.length;

    // Find the start of the current line
    int lineStart = start;
    while (lineStart > 0 && text[lineStart - 1] != '\n') {
      lineStart--;
    }

    final prefix = lineStart == 0 ? '- ' : '\n- ';
    final newText = text.substring(0, start) + prefix + text.substring(start);
    final newCursorPos = start + prefix.length;

    controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newCursorPos),
    );
  }

  /// Insert numbered list item
  static void insertNumberedList(TextEditingController controller) {
    final text = controller.text;
    final selection = controller.selection;
    final start = selection.start >= 0 ? selection.start : text.length;

    // Find the start of the current line
    int lineStart = start;
    while (lineStart > 0 && text[lineStart - 1] != '\n') {
      lineStart--;
    }

    final prefix = lineStart == 0 ? '1. ' : '\n1. ';
    final newText = text.substring(0, start) + prefix + text.substring(start);
    final newCursorPos = start + prefix.length;

    controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newCursorPos),
    );
  }

  /// Insert code block
  static void insertCodeBlock(TextEditingController controller) {
    final text = controller.text;
    final selection = controller.selection;
    final start = selection.start >= 0 ? selection.start : text.length;

    final codeBlock = selection.isValid && selection.start != selection.end
        ? '\n```\n${text.substring(selection.start, selection.end)}\n```\n'
        : '\n```\ncode here\n```\n';

    final newText = text.substring(0, start) +
        codeBlock +
        text.substring(selection.end >= 0 ? selection.end : start);
    final newCursorPos = start + '\n```\n'.length;

    controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newCursorPos),
    );
  }

  /// Insert inline code
  static void insertInlineCode(TextEditingController controller) {
    insertMarkdown(
      controller: controller,
      prefix: '`',
      suffix: '`',
      placeholder: 'code',
    );
  }

  /// Insert link
  static void insertLink(
    TextEditingController controller, {
    String? url,
    String? linkText,
  }) {
    final text = controller.text;
    final selection = controller.selection;
    final start = selection.start >= 0 ? selection.start : 0;
    final end = selection.end >= 0 ? selection.end : text.length;

    final selectedText = selection.isValid && start != end
        ? text.substring(start, end)
        : (linkText ?? 'link text');
    final urlText = url ?? 'https://example.com';
    final link = '[$selectedText]($urlText)';

    final newText = text.substring(0, start) +
        link +
        text.substring(selection.end >= 0 ? selection.end : start);
    final newCursorPos = start + link.length;

    controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newCursorPos),
    );
  }

  /// Insert blockquote
  static void insertBlockquote(TextEditingController controller) {
    final text = controller.text;
    final selection = controller.selection;
    final start = selection.start >= 0 ? selection.start : text.length;

    // Find the start of the current line
    int lineStart = start;
    while (lineStart > 0 && text[lineStart - 1] != '\n') {
      lineStart--;
    }

    final prefix = lineStart == 0 ? '> ' : '\n> ';
    final newText = text.substring(0, start) + prefix + text.substring(start);
    final newCursorPos = start + prefix.length;

    controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newCursorPos),
    );
  }

  /// Get word count
  static int getWordCount(String text) {
    if (text.trim().isEmpty) return 0;
    return text
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .length;
  }

  /// Get character count (excluding spaces)
  static int getCharacterCount(String text, {bool includeSpaces = true}) {
    if (includeSpaces) {
      return text.length;
    }
    return text.replaceAll(RegExp(r'\s'), '').length;
  }

  /// Get line count
  static int getLineCount(String text) {
    if (text.isEmpty) return 0;
    return '\n'.allMatches(text).length + 1;
  }
}
