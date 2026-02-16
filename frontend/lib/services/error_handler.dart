import 'dart:io';
import 'package:flutter/material.dart';
import '../utils/app_constants.dart';
import '../utils/app_logger.dart';

// Re-export ErrorType from app_constants.dart for backward compatibility
export '../utils/app_constants.dart' show ErrorType;

/// 错误处理服务
class ErrorHandler {
  /// 显示错误对话框
  static void showError({
    required BuildContext context,
    required ErrorType type,
    String? customMessage,
    VoidCallback? onRetry,
  }) {
    // 记录错误
    logger.e('显示错误对话框: $type - $customMessage');

    final title = ErrorTypeConfig.titles[type]!;
    final message = customMessage ?? ErrorTypeConfig.messages[type]!;
    final icon = ErrorTypeConfig.icons[type]!;
    final colors = ErrorTypeConfig.gradients[type]!;
    final color = ErrorTypeConfig.colors[type]!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConfig.dialogBorderRadius),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 错误图标
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colors[0].withOpacity(0.2),
                    colors[1].withOpacity(0.1),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 32,
                color: color,
              ),
            ),
            const SizedBox(height: 20),

            // 错误标题
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // 错误消息
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.onSurface.withOpacity(0.8),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // 操作按钮
            Row(
              children: [
                if (onRetry != null) ...[
                  // 取消按钮
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: AppColors.primary.withOpacity(0.3),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppConfig.buttonBorderRadius),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        '取消',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.onSurface,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // 重试按钮
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        onRetry();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppConfig.buttonBorderRadius),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                      ),
                      child: const Text(
                        '重试',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  // 仅确定按钮
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppConfig.buttonBorderRadius),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                      ),
                      child: const Text(
                        '确定',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 显示简化的错误提示（SnackBar）
  static void showErrorToast({
    required BuildContext context,
    required ErrorType type,
    String? customMessage,
  }) {
    final message = customMessage ?? ErrorTypeConfig.messages[type]!;
    final icon = ErrorTypeConfig.icons[type]!;
    final color = ErrorTypeConfig.colors[type]!;

    // 记录错误
    logger.e('显示错误Toast: $type - $message');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConfig.buttonBorderRadius),
        ),
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  /// 显示成功提示
  static void showSuccess({
    required BuildContext context,
    required String message,
  }) {
    // 记录成功
    logger.i('显示成功提示: $message');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConfig.buttonBorderRadius),
        ),
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  /// 根据异常自动判断错误类型
  static ErrorType detectErrorType(dynamic error) {
    final errorStr = error.toString().toLowerCase();

    // 网络错误
    if (error is SocketException ||
        errorStr.contains('socketexception') ||
        errorStr.contains('networkexception') ||
        errorStr.contains('failed host lookup') ||
        errorStr.contains('connection refused') ||
        errorStr.contains('timeout')) {
      logger.d('检测到网络错误');
      return ErrorType.network;
    }

    // 权限错误
    if (errorStr.contains('permissiondenied') ||
        errorStr.contains('permission denied')) {
      logger.d('检测到权限错误');
      return ErrorType.permission;
    }

    // 认证错误
    if (errorStr.contains('401') || errorStr.contains('unauthorized')) {
      logger.d('检测到认证错误');
      return ErrorType.auth;
    }

    logger.d('检测到未知错误');
    return ErrorType.unknown;
  }
}
