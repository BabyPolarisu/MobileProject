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
    if (authToken != null) 'Authorization': 'Bearer $authToken',
  };

  /// Check whether the Django backend server is online
  Future<bool> checkServerHealth() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/health/')).timeout(
        const Duration(seconds: 3),
      );
      if (response.statusCode >= 200 && response.statusCode < 400) {
        return true;
      }
    } catch (_) {}

    try {
      final response = await http.get(Uri.parse('$baseUrl/')).timeout(
        const Duration(seconds: 3),
      );
      return response.statusCode >= 200 && response.statusCode < 500;
    } catch (_) {
      return false;
    }
  }

  /// Fetch initial mobile app configuration from backend
  Future<Map<String, dynamic>?> fetchMobileConfig() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/mobile/config/')).timeout(
        const Duration(seconds: 4),
      );
      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      }
    } catch (_) {}
    return null;
  }

  /// Register mobile client device info with backend
  Future<void> registerMobileDevice({required String platform, required String model}) async {
    try {
      await http.post(
        Uri.parse('$baseUrl/api/mobile/devices/register/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'platform': platform,
          'device_model': model,
          'app_version': '1.0.0',
        }),
      ).timeout(const Duration(seconds: 3));
    } catch (_) {}
  }


  /// Fetch products with optional filtering
  Future<List<ProductModel>> fetchProducts({
    int? categoryId,
    String? condition,
    String? search,
    String? status,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (categoryId != null) queryParams['category'] = categoryId.toString();
      if (condition != null && condition.isNotEmpty) queryParams['condition'] = condition;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (status != null && status.isNotEmpty) queryParams['status'] = status;

      final uri = Uri.parse('$baseUrl/api/products/').replace(queryParameters: queryParams.isEmpty ? null : queryParams);
      final response = await http.get(uri, headers: _headers).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final List data = jsonDecode(utf8.decode(response.bodyBytes));
        return data.map((e) => ProductModel.fromJson(e)).toList();
      }
    } catch (_) {}
    return [];
  }

  /// Create a new product on the backend
  Future<ProductModel?> createProduct({
    required String name,
    required String description,
    required double price,
    required String condition,
    required int categoryId,
    required int sellerId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/products/'),
        headers: _headers,
        body: jsonEncode({
          'name': name,
          'description': description,
          'price': price,
          'condition': condition,
          'category_id': categoryId,
          'seller_id': sellerId,
        }),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return ProductModel.fromJson(data);
      }
    } catch (_) {}
    return null;
  }

  /// Update an existing product on the backend
  Future<ProductModel?> updateProduct({
    required int id,
    required String name,
    required String description,
    required double price,
    required String condition,
    int? categoryId,
    String? status,
  }) async {
    try {
      final body = <String, dynamic>{
        'name': name,
        'description': description,
        'price': price,
        'condition': condition,
      };
      if (categoryId != null) body['category_id'] = categoryId;
      if (status != null) body['status'] = status;

      final response = await http.put(
        Uri.parse('$baseUrl/api/products/$id/'),
        headers: _headers,
        body: jsonEncode(body),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return ProductModel.fromJson(data);
      }
    } catch (_) {}
    return null;
  }

  /// Delete a product from backend
  Future<bool> deleteProduct(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/products/$id/'),
        headers: _headers,
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (_) {
      return false;
    }
  }

  /// Toggle product favorite
  Future<bool?> toggleFavorite(int productId, int userId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/products/$productId/favorite/'),
        headers: _headers,
        body: jsonEncode({'user_id': userId}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['is_favorite'] as bool?;
      }
    } catch (_) {}
    return null;
  }

  /// Fetch categories from backend
  Future<List<CategoryModel>> fetchCategories() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/categories/'), headers: _headers);
      if (response.statusCode == 200) {
        final List data = jsonDecode(utf8.decode(response.bodyBytes));
        return data.map((e) => CategoryModel.fromJson(e)).toList();
      }
    } catch (_) {}
    return [];
  }

  /// User Login
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

  /// User Registration (enforcing @ubu.ac.th email domain)
  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    String? displayName,
    String? phoneNumber,
    String? firstName,
    String? lastName,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/register/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
          'display_name': displayName,
          'phone_number': phoneNumber,
          'first_name': firstName,
          'last_name': lastName,
        }),
      ).timeout(const Duration(seconds: 8));

      final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      if (response.statusCode == 201 || response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'error': data['error'] ?? 'การสมัครสมาชิกล้มเหลว'};
      }
    } catch (e) {
      return {'success': false, 'error': 'ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้: $e'};
    }
  }

  /// Admin moderate product
  Future<bool> adminProductAction(int productId, String action) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/admin/products/$productId/action/'),
        headers: _headers,
        body: jsonEncode({'action': action}),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Send chat message
  Future<bool> sendChatMessage(int roomId, String content, int senderId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/chat/rooms/$roomId/messages/'),
        headers: _headers,
        body: jsonEncode({'content': content, 'user_id': senderId}),
      );
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Submit report
  Future<bool> submitReport({
    required int reporterId,
    required String reason,
    required String details,
    int? productId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/reports/'),
        headers: _headers,
        body: jsonEncode({
          'reporter_id': reporterId,
          'reason': reason,
          'details': details,
          'product_id': ?productId,
        }),
      );
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
