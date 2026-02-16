import 'package:flutter/material.dart';

/// 错误类型枚举
enum ErrorType {
  network,      // 网络错误
  upload,       // 上传失败
  transcription,// 转写失败
  permission,   // 权限错误
  auth,         // 认证错误（预留，MVP模式暂不使用）
  unknown,      // 未知错误
}

/// 错误处理服务
class ErrorHandler {
  /// 显示错误对话框
  static void showError({
    required BuildContext context,
    required ErrorType type,
    String? customMessage,
    VoidCallback? onRetry,
  }) {
    final errorInfo = _getErrorInfo(type, customMessage);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
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
                    errorInfo.color.withOpacity(0.2),
                    errorInfo.color.withOpacity(0.1),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                errorInfo.icon,
                size: 32,
                color: errorInfo.color,
              ),
            ),
            const SizedBox(height: 20),

            // 错误标题
            Text(
              errorInfo.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF164E63),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // 错误消息
            Text(
              errorInfo.message,
              style: TextStyle(
                fontSize: 14,
                color: const Color(0xFF164E63).withOpacity(0.8),
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
                          color: const Color(0xFF0891B2).withOpacity(0.3),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        '取消',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF164E63),
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
                        backgroundColor: const Color(0xFF0891B2),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
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
                        backgroundColor: const Color(0xFF0891B2),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
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
    final errorInfo = _getErrorInfo(type, customMessage);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              errorInfo.icon,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                errorInfo.message,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: errorInfo.color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
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
        backgroundColor: const Color(0xFF059669),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  /// 获取错误信息
  static _ErrorInfo _getErrorInfo(ErrorType type, String? customMessage) {
    switch (type) {
      case ErrorType.network:
        return _ErrorInfo(
          title: '网络错误',
          message: customMessage ?? '请检查网络连接后重试',
          icon: Icons.wifi_off,
          color: const Color(0xFFDC2626), // 红色
        );

      case ErrorType.upload:
        return _ErrorInfo(
          title: '上传失败',
          message: customMessage ?? '音频文件上传失败，请重试',
          icon: Icons.cloud_off,
          color: const Color(0xFFF59E0B), // 橙色
        );

      case ErrorType.transcription:
        return _ErrorInfo(
          title: '转写失败',
          message: customMessage ?? '语音转写失败，请重新录制',
          icon: Icons.error_outline,
          color: const Color(0xFFDC2626), // 红色
        );

      case ErrorType.permission:
        return _ErrorInfo(
          title: '权限错误',
          message: customMessage ?? '请授予麦克风权限以使用录音功能',
          icon: Icons.mic_off,
          color: const Color(0xFF8B5CF6), // 紫色
        );

      case ErrorType.auth:
        return _ErrorInfo(
          title: '认证错误',
          message: customMessage ?? '登录已过期，请重新登录',
          icon: Icons.lock_outline,
          color: const Color(0xFFDC2626), // 红色
        );

      case ErrorType.unknown:
        return _ErrorInfo(
          title: '发生错误',
          message: customMessage ?? '未知错误，请重试',
          icon: Icons.error,
          color: const Color(0xFF6B7280), // 灰色
        );
    }
  }

  /// 根据异常自动判断错误类型
  static ErrorType detectErrorType(dynamic error) {
    if (error.toString().contains('SocketException') ||
        error.toString().contains('NetworkException') ||
        error.toString().contains('Failed host lookup')) {
      return ErrorType.network;
    }

    if (error.toString().contains('PermissionDenied') ||
        error.toString().contains('Permission denied')) {
      return ErrorType.permission;
    }

    if (error.toString().contains('401') || error.toString().contains('Unauthorized')) {
      return ErrorType.auth;
    }

    return ErrorType.unknown;
  }
}

class _ErrorInfo {
  final String title;
  final String message;
  final IconData icon;
  final Color color;

  _ErrorInfo({
    required this.title,
    required this.message,
    required this.icon,
    required this.color,
  });
}
