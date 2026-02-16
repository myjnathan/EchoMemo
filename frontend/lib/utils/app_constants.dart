import 'package:flutter/material.dart';

/// 应用统一的颜色配置
class AppColors {
  // Primary Colors - Cyan主题
  static const Color primary = Color(0xFF0891B2);
  static const Color primaryLight = Color(0xFF22D3EE);
  static const Color primaryDark = Color(0xFF0E7490);

  // Surface Colors
  static const Color surface = Color(0xFFECFEFF);
  static const Color onSurface = Color(0xFF164E63);
  static const Color onSurfaceSecondary = Color(0xFF155E75);

  // Tag Colors
  static const Color tagWork = Color(0xFF0891B2);
  static const Color tagEmotion = Color(0xFF059669);
  static const Color tagIdea = Color(0xFF8B5CF6);
  static const Color tagLife = Color(0xFFEC4899);
  static const Color tagDefault = Color(0xFF0891B2);

  // Status Colors
  static const Color success = Color(0xFF059669);
  static const Color error = Color(0xFFDC2626);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF0891B2);

  // Error Type Colors
  static const Color errorNetwork = Color(0xFFDC2626);
  static const Color errorUpload = Color(0xFFF59E0B);
  static const Color errorPermission = Color(0xFF8B5CF6);
  static const Color errorAuth = Color(0xFFDC2626);
  static const Color errorUnknown = Color(0xFF6B7280);

  // Highlight Color (for search)
  static const Color highlight = Color(0xFFFFEB3B);

  // White
  static const Color white = Color(0xFFFFFFFF);
  static const Color white70 = Color(0xB3FFFFFF);
  static const Color white80 = Color(0xCCFFFFFF);
}

/// 应用统一的配置常量
class AppConfig {
  // API配置
  static const String apiBaseUrl = 'http://118.145.114.187';
  static const String apiBaseUrlLocal = 'http://10.0.2.2:8000';

  // 刷新配置
  static const int processingCheckIntervalSeconds = 3;
  static const int refreshDelayMilliseconds = 500;
  static const int autoRefreshIntervalSeconds = 3;

  // 搜索配置
  static const int searchDebounceMilliseconds = 300;

  // 缓存配置
  static const int apiCacheDurationSeconds = 5;

  // UI配置
  static const double defaultBorderRadius = 20.0;
  static const double cardBorderRadius = 20.0;
  static const double buttonBorderRadius = 12.0;
  static const double dialogBorderRadius = 20.0;

  // 动画配置
  static const int animationDurationMilliseconds = 300;
  static const int waveAnimationDurationMilliseconds = 1500;
}

/// 错误类型枚举
enum ErrorType {
  network,
  upload,
  transcription,
  permission,
  auth,
  unknown,
}

/// 错误类型配置
class ErrorTypeConfig {
  static const Map<ErrorType, String> titles = {
    ErrorType.network: '网络错误',
    ErrorType.upload: '上传失败',
    ErrorType.transcription: '转写失败',
    ErrorType.permission: '权限错误',
    ErrorType.auth: '认证错误',
    ErrorType.unknown: '发生错误',
  };

  static const Map<ErrorType, String> messages = {
    ErrorType.network: '请检查网络连接后重试',
    ErrorType.upload: '上传失败，请重试',
    ErrorType.transcription: '语音转写失败，请重试',
    ErrorType.permission: '请授予麦克风权限以使用录音功能',
    ErrorType.auth: '认证失败，请重新登录',
    ErrorType.unknown: '发生未知错误，请重试',
  };

  static const Map<ErrorType, IconData> icons = {
    ErrorType.network: Icons.wifi_off,
    ErrorType.upload: Icons.cloud_off,
    ErrorType.transcription: Icons.error_outline,
    ErrorType.permission: Icons.mic_off,
    ErrorType.auth: Icons.lock_outline,
    ErrorType.unknown: Icons.error,
  };

  static const Map<ErrorType, List<Color>> gradients = {
    ErrorType.network: [Color(0xFFFECACA), Color(0xFFDC2626)],
    ErrorType.upload: [Color(0xFFFED7AA), Color(0xFFF59E0B)],
    ErrorType.transcription: [Color(0xFFFECACA), Color(0xFFDC2626)],
    ErrorType.permission: [Color(0xFFE9D5FF), Color(0xFF8B5CF6)],
    ErrorType.auth: [Color(0xFFFECACA), Color(0xFFDC2626)],
    ErrorType.unknown: [Color(0xFFE5E7EB), Color(0xFF6B7280)],
  };

  static const Map<ErrorType, Color> colors = {
    ErrorType.network: AppColors.errorNetwork,
    ErrorType.upload: AppColors.errorUpload,
    ErrorType.transcription: AppColors.error,
    ErrorType.permission: AppColors.errorPermission,
    ErrorType.auth: AppColors.errorAuth,
    ErrorType.unknown: AppColors.errorUnknown,
  };
}
