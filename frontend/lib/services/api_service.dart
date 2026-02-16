import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/memo.dart';
import '../utils/app_constants.dart';
import '../utils/app_logger.dart';

class ApiService {
  final String baseUrl;

  ApiService({this.baseUrl = AppConfig.apiBaseUrl});

  // 缓存相关
  List<Memo>? _cachedMemos;
  DateTime? _cacheTime;

  Map<String, String> get _headers {
    return {
      'Content-Type': 'application/json',
    };
  }

  // MVP模式：移除登录和注册方法
  // Future<String> login(String username, String password) async { ... }
  // Future<void> register(String username, String password) async { ... }

  Future<List<Memo>> getMemos({bool forceRefresh = false}) async {
    // 检查缓存
    if (!forceRefresh &&
        _cachedMemos != null &&
        _cacheTime != null &&
        DateTime.now().difference(_cacheTime!).inSeconds <
            AppConfig.apiCacheDurationSeconds) {
      logger.i('使用缓存的 memos 数据');
      return _cachedMemos!;
    }

    // 请求新数据
    logger.i('请求 memos 数据');
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/memos'),
        headers: _headers,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          logger.e('获取 memos 超时');
          throw SocketException('Connection timeout');
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
        final memos = body.map((dynamic item) => Memo.fromJson(item)).toList();

        // 更新缓存
        _cachedMemos = memos;
        _cacheTime = DateTime.now();
        logger.i('成功获取 ${memos.length} 条 memos');

        return memos;
      } else if (response.statusCode == 401) {
        logger.e('获取 memos 失败: Unauthorized');
        throw Exception('Unauthorized');
      } else {
        logger.e('获取 memos 失败: ${response.statusCode}');
        throw Exception('Failed to load memos: ${response.statusCode}');
      }
    } on SocketException catch (e, stackTrace) {
      logger.e('网络错误', error: e, stackTrace: stackTrace);
      rethrow;
    } on HttpException catch (e, stackTrace) {
      logger.e('HTTP错误', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<Memo> getMemo(int memoId) async {
    logger.i('请求 memo #$memoId');
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/memos/$memoId'),
        headers: _headers,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          logger.e('获取 memo 超时');
          throw SocketException('Connection timeout');
        },
      );

      if (response.statusCode == 200) {
        final memo = Memo.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
        logger.i('成功获取 memo #$memoId');
        return memo;
      } else if (response.statusCode == 404) {
        logger.e('Memo #$memoId 不存在');
        throw Exception('Memo not found');
      } else {
        logger.e('获取 memo 失败: ${response.statusCode}');
        throw Exception('Failed to load memo: ${response.statusCode}');
      }
    } on SocketException catch (e, stackTrace) {
      logger.e('网络错误', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> deleteMemo(int memoId) async {
    logger.i('删除 memo #$memoId');
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/memos/$memoId'),
        headers: _headers,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          logger.e('删除 memo 超时');
          throw SocketException('Connection timeout');
        },
      );

      if (response.statusCode == 200) {
        // 清除缓存
        _invalidateCache();
        logger.i('成功删除 memo #$memoId');
      } else {
        logger.e('删除 memo 失败: ${response.statusCode}');
        throw Exception('Failed to delete memo: ${response.statusCode}');
      }
    } on SocketException catch (e, stackTrace) {
      logger.e('网络错误', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<Memo> updateMemo(int memoId, {
    String? transcription,
    String? summary,
    List<String>? tags,
  }) async {
    logger.i('更新 memo #$memoId');

    // 构建请求体（只包含非null字段）
    final Map<String, dynamic> requestBody = {};
    if (transcription != null) requestBody['transcription'] = transcription;
    if (summary != null) requestBody['summary'] = summary;
    if (tags != null) requestBody['tags'] = tags;

    if (requestBody.isEmpty) {
      logger.w('没有提供要更新的字段');
      throw Exception('No fields to update');
    }

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/memos/$memoId'),
        headers: _headers,
        body: jsonEncode(requestBody),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          logger.e('更新 memo 超时');
          throw SocketException('Connection timeout');
        },
      );

      if (response.statusCode == 200) {
        final memo = Memo.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));

        // 清除缓存，因为数据已更新
        _invalidateCache();
        logger.i('成功更新 memo #$memoId');

        return memo;
      } else {
        logger.e('更新 memo 失败: ${response.statusCode}');
        throw Exception('Failed to update memo: ${response.statusCode}');
      }
    } on SocketException catch (e, stackTrace) {
      logger.e('网络错误', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<Memo> uploadAudio(String filePath) async {
    logger.i('上传音频: $filePath');
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/upload'));

      request.files.add(await http.MultipartFile.fromPath('file', filePath));

      var response = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          logger.e('上传音频超时');
          throw SocketException('Upload timeout');
        },
      );

      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        final memo = Memo.fromJson(jsonDecode(responseData));

        // 清除缓存，因为有了新的memo
        _invalidateCache();
        logger.i('成功上传音频，memo #${memo.id}');

        return memo;
      } else {
        logger.e('上传音频失败: ${response.statusCode}');
        throw Exception('Failed to upload audio: ${response.statusCode}');
      }
    } on SocketException catch (e, stackTrace) {
      logger.e('网络错误', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<List<Memo>> getRelatedMemos(int memoId, {int limit = 5}) async {
    logger.i('获取 memo #$memoId 的相关笔记');
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/memos/$memoId/related?limit=$limit'),
        headers: _headers,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          logger.e('获取相关笔记超时');
          throw SocketException('Connection timeout');
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
        final memos = body.map((dynamic item) => Memo.fromJson(item)).toList();
        logger.i('成功获取 ${memos.length} 个相关笔记');
        return memos;
      } else {
        logger.e('获取相关笔记失败: ${response.statusCode}');
        return [];
      }
    } on SocketException catch (e, stackTrace) {
      logger.e('网络错误', error: e, stackTrace: stackTrace);
      return [];
    }
  }

  /// 清除缓存
  void _invalidateCache() {
    _cachedMemos = null;
    _cacheTime = null;
    logger.d('缓存已清除');
  }

  /// 强制刷新（清除缓存并重新获取）
  Future<List<Memo>> refreshMemos() async {
    return getMemos(forceRefresh: true);
  }
}
