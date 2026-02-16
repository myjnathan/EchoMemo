import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/memo.dart';

class ApiService {
  // Updated to port 80 (default HTTP port)
  static const String baseUrl = 'http://118.145.114.187';
  // For local emulator use: 'http://10.0.2.2:8000';

  // MVP模式：移除认证依赖
  // String? _token;
  //
  // void setToken(String token) {
  //   _token = token;
  // }

  Map<String, String> get _headers {
    // MVP模式：不需要Authorization头
    return {
      'Content-Type': 'application/json',
    };
    // 原认证代码已移除：
    // if (_token != null) {
    //   headers['Authorization'] = 'Bearer $_token';
    // }
  }

  // MVP模式：移除登录和注册方法
  // Future<String> login(String username, String password) async { ... }
  // Future<void> register(String username, String password) async { ... }

  Future<List<Memo>> getMemos() async {
    final response = await http.get(
      Uri.parse('$baseUrl/memos'),
      headers: _headers,  // MVP模式：不需要Authorization
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      return body.map((dynamic item) => Memo.fromJson(item)).toList();
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized');
    } else {
      throw Exception('Failed to load memos: ${response.statusCode}');
    }
  }

  Future<Memo> getMemo(int memoId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/memos/$memoId'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return Memo.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else if (response.statusCode == 404) {
      throw Exception('Memo not found');
    } else {
      throw Exception('Failed to load memo: ${response.statusCode}');
    }
  }

  Future<void> deleteMemo(int memoId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/memos/$memoId'),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete memo: ${response.statusCode}');
    }
  }

  Future<Memo> uploadAudio(String filePath) async {
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/upload'));

    // MVP模式：移除Authorization头
    // 原认证代码已移除：
    // if (_token != null) {
    //   request.headers['Authorization'] = 'Bearer $_token';
    // }

    request.files.add(await http.MultipartFile.fromPath('file', filePath));

    var response = await request.send();

    if (response.statusCode == 200) {
      var responseData = await response.stream.bytesToString();
      return Memo.fromJson(jsonDecode(responseData));
    } else {
      throw Exception('Failed to upload audio: ${response.statusCode}');
    }
  }
}
