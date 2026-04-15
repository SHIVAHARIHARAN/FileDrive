import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';
  static const String _userNameKey = 'user_name';

  static const storage = FlutterSecureStorage();

  // Save token
  static Future<void> saveToken(String token) async {
    await storage.write(key: _tokenKey, value: token);
  }

  // Get token
  static Future<String?> getToken() async {
    return await storage.read(key: _tokenKey);
  }

  // Delete token
  static Future<void> deleteToken() async {
    await storage.delete(key: _tokenKey);
  }

  // Save user data
  static Future<void> saveUserData({
    required String userId,
    required String email,
    required String userName,
  }) async {
    await storage.write(key: _userIdKey, value: userId);
    await storage.write(key: _userEmailKey, value: email);
    await storage.write(key: _userNameKey, value: userName);
  }

  // Get user ID
  static Future<String?> getUserId() async {
    return await storage.read(key: _userIdKey);
  }

  // Get user email
  static Future<String?> getUserEmail() async {
    return await storage.read(key: _userEmailKey);
  }

  // Get user name
  static Future<String?> getUserName() async {
    return await storage.read(key: _userNameKey);
  }

  // Clear all data (logout)
  static Future<void> clearAll() async {
    await storage.deleteAll();
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
