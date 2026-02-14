import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/memo.dart';

class ApiService {
  // Updated to port 80 (default HTTP port)
  static const String baseUrl = 'http://118.145.114.187'; 
  // For local emulator use: 'http://10.0.2.2:8000';

  String? _token;

  void setToken(String token) {
    _token = token;
  }

  Map<String, String> get _headers {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  Future<String> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/token'),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'username': username,
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final token = body['access_token'];
      _token = token;
      return token;
    } else {
      throw Exception('Failed to login: ${response.body}');
    }
  }

  Future<void> register(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to register: ${response.body}');
    }
  }

  Future<List<Memo>> getMemos() async {
    final response = await http.get(
      Uri.parse('$baseUrl/memos'),
      headers: _headers,
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

  Future<Memo> uploadAudio(String filePath) async {
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/upload'));
    
    // Add Authorization header manually for MultipartRequest
    if (_token != null) {
      request.headers['Authorization'] = 'Bearer $_token';
    }

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
