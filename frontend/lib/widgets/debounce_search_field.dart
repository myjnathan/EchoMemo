import 'dart:async';
import 'package:flutter/material.dart';
import '../utils/app_constants.dart';
import '../utils/app_logger.dart';

/// 防抖搜索输入框
///
/// 特性:
/// - 自动延迟处理用户输入
/// - 可配置的延迟时间
/// - 支持自定义样式
/// - 自动清除功能
class DebounceSearchField extends StatefulWidget {
  final String hintText;
  final ValueChanged<String> onChanged;
  final Duration? debounceDuration;
  final TextStyle? hintStyle;
  final Widget? prefixIcon;
  final Color? iconColor;
  final InputDecoration? decoration;

  const DebounceSearchField({
    super.key,
    required this.hintText,
    required this.onChanged,
    this.debounceDuration,
    this.hintStyle,
    this.prefixIcon,
    this.iconColor,
    this.decoration,
  });

  @override
  State<DebounceSearchField> createState() => _DebounceSearchFieldState();
}

class _DebounceSearchFieldState extends State<DebounceSearchField> {
  Timer? _debounce;
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    // 取消之前的定时器
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    // 设置新的定时器
    _debounce = Timer(
      widget.debounceDuration ??
          const Duration(milliseconds: AppConfig.searchDebounceMilliseconds),
      () {
        if (mounted) {
          logger.d('Search query: $query');
          widget.onChanged(query);
        }
      },
    );
  }

  void _clearSearch() {
    _controller.clear();
    widget.onChanged('');
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration: widget.decoration ??
          InputDecoration(
            hintText: widget.hintText,
            hintStyle: widget.hintStyle,
            prefixIcon: widget.prefixIcon,
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: widget.iconColor,
                    ),
                    onPressed: _clearSearch,
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
      onChanged: _onSearchChanged,
    );
  }
}
