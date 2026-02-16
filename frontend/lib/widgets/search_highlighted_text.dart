import 'package:flutter/material.dart';
import '../utils/app_constants.dart';

class SearchHighlightedText extends StatelessWidget {
  final String text;
  final String query;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;

  const SearchHighlightedText({
    Key? key,
    required this.text,
    required this.query,
    this.style,
    this.maxLines,
    this.overflow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 如果没有搜索查询或文本为空，直接返回普通文本
    if (query.isEmpty || text.isEmpty) {
      return Text(
        text,
        style: style,
        maxLines: maxLines,
        overflow: overflow,
      );
    }

    // 如果不包含查询文本，直接返回普通文本
    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    if (!lowerText.contains(lowerQuery)) {
      return Text(
        text,
        style: style,
        maxLines: maxLines,
        overflow: overflow,
      );
    }

    // 查找所有匹配位置
    final matches = <_TextMatch>[];
    int start = 0;
    while (true) {
      final index = lowerText.indexOf(lowerQuery, start);
      if (index == -1) break;
      matches.add(_TextMatch(index, index + query.length));
      start = index + 1;
    }

    if (matches.isEmpty) {
      return Text(
        text,
        style: style,
        maxLines: maxLines,
        overflow: overflow,
      );
    }

    // 构建高亮文本（使用新的常量）
    final defaultStyle = style ?? const TextStyle(color: AppColors.onSurface, fontSize: 14);
    final highlightStyle = defaultStyle.copyWith(
      backgroundColor: AppColors.highlight,
      color: Colors.black,
      fontWeight: FontWeight.bold,
    );

    List<TextSpan> spans = [];
    int lastEnd = 0;

    for (final match in matches) {
      // 添加匹配前的文本
      if (match.start > lastEnd) {
        spans.add(TextSpan(
          text: text.substring(lastEnd, match.start),
          style: defaultStyle,
        ));
      }

      // 添加高亮的匹配文本
      spans.add(TextSpan(
        text: text.substring(match.start, match.end),
        style: highlightStyle,
      ));

      lastEnd = match.end;
    }

    // 添加剩余的文本
    if (lastEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastEnd),
        style: defaultStyle,
      ));
    }

    return RichText(
      text: TextSpan(children: spans),
      maxLines: maxLines,
      overflow: overflow ?? TextOverflow.clip,
    );
  }
}

class _TextMatch {
  final int start;
  final int end;
  _TextMatch(this.start, this.end);
}

