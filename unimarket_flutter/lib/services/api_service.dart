import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';
import '../models/user_model.dart';

class ApiService {
  String baseUrl = 'http://127.0.0.1:8000';
  String? authToken;

  void setBaseUrl(String url) {
    baseUrl = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (authToken != null) 'Authorization': 'Token $authToken',
  };

  Future<bool> checkServerHealth() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/')).timeout(
        const Duration(seconds: 3),
      );
      return response.statusCode >= 200 && response.statusCode < 500;
    } catch (_) {
      return false;
    }
  }

  Future<List<ProductModel>> fetchProducts() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/products/'), headers: _headers);
      if (response.statusCode == 200) {
        final List data = jsonDecode(utf8.decode(response.bodyBytes));
        return data.map((e) => ProductModel.fromJson(e)).toList();
      }
    } catch (e) {
      // Fallback handled by AppState
    }
    return [];
  }

  Future<UserModel?> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login/'),
        headers: _headers,
        body: jsonEncode({'username': username, 'password': password}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        authToken = data['token'];
        return UserModel.fromJson(data['user']);
      }
    } catch (_) {}
    return null;
  }
}
