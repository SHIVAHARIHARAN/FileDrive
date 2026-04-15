import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'storage_service.dart';
import 'package:path_provider/path_provider.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.1.40:5000/api';
  static const String baseFileUrl = 'http://192.168.1.40:5000';

  // Get Authorization Header with token
  static Future<Map<String, String>> getAuthHeaders() async {
    final token = await StorageService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Login API
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['token'] != null) {
          await StorageService.saveToken(data['token']);
          if (data['user'] != null) {
            await StorageService.saveUserData(
              userId: data['user']['id'],
              email: data['user']['email'],
              userName: data['user']['name'],
            );
          }
        }
        return {'success': true, ...data};
      } else {
        return {
          'success': false,
          'message': 'Login failed: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // Signup API
  static Future<Map<String, dynamic>> signup(
    String username,
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['token'] != null) {
          await StorageService.saveToken(data['token']);
          if (data['user'] != null) {
            await StorageService.saveUserData(
              userId: data['user']['id'],
              email: data['user']['email'],
              userName: data['user']['name'],
            );
          }
        }
        return {'success': true, ...data};
      } else {
        return {
          'success': false,
          'message': 'Signup failed: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // Create folder
  static Future<Map<String, dynamic>> createFolder(
    String name,
    String userId, {
    String? parentFolderId,
  }) async {
    try {
      final headers = await getAuthHeaders();
      final response = await http.post(
        Uri.parse("$baseUrl/folders"),
        headers: headers,
        body: jsonEncode({
          "name": name,
          "userId": userId,
          if (parentFolderId != null) "parentFolderId": parentFolderId,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Failed to create folder: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // Get folders
  static Future<Map<String, dynamic>> getFolders(
    String userId, {
    String? parentFolderId,
  }) async {
    try {
      String url = "$baseUrl/folders?userId=$userId";
      if (parentFolderId != null) {
        url += "&parentFolderId=$parentFolderId";
      }

      final headers = await getAuthHeaders();
      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'success': false, 'message': 'Failed to fetch folders'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // Upload file
  static Future<Map<String, dynamic>> uploadFile(
    dynamic fileData,
    String folderId,
    String fileName,
  ) async {
    try {
      final token = await StorageService.getToken();
      final userId = await StorageService.getUserId();

      if (token == null || userId == null) {
        return {'success': false, 'message': 'User not authenticated'};
      }

      var request = http.MultipartRequest('POST', Uri.parse("$baseUrl/files"));
      request.headers['Authorization'] = 'Bearer $token';

      request.fields['folderId'] = folderId;
      request.fields['userId'] = userId;

      if (kIsWeb || fileData is List<int>) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'file',
            fileData is List<int>
                ? fileData
                : await File(fileData).readAsBytes(),
            filename: fileName,
          ),
        );
      } else {
        request.files.add(await http.MultipartFile.fromPath('file', fileData));
      }

      var response = await request.send();
      final responseData = await response.stream.bytesToString();

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {'success': true, ...jsonDecode(responseData)};
      } else {
        return {
          'success': false,
          'message': 'Failed to upload file: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // Get files
  static Future<Map<String, dynamic>> getFiles(String folderId) async {
    try {
      final headers = await getAuthHeaders();
      final response = await http.get(
        Uri.parse("$baseUrl/files?folderId=$folderId"),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'success': false, 'message': 'Failed to fetch files'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // Delete file
  static Future<Map<String, dynamic>> deleteFile(String fileId) async {
    try {
      final headers = await getAuthHeaders();
      final response = await http.delete(
        Uri.parse("$baseUrl/files/$fileId"),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'success': false, 'message': 'Failed to delete file'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // Rename file
  static Future<Map<String, dynamic>> renameFile(
    String fileId,
    String newName,
  ) async {
    try {
      final headers = await getAuthHeaders();
      final response = await http.put(
        Uri.parse("$baseUrl/files/$fileId/rename"),
        headers: headers,
        body: jsonEncode({"newName": newName}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'success': false, 'message': 'Failed to rename file'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // Download file
  static Future<Map<String, dynamic>> downloadFile(
    String fileUrl,
    String fileName,
  ) async {
    try {
      final fullUrl = '$baseFileUrl$fileUrl';
      final response = await http.get(Uri.parse(fullUrl));

      if (response.statusCode == 200) {
        if (kIsWeb) {
          // Web: return file bytes for browser download
          return {
            'success': true,
            'bytes': response.bodyBytes,
            'fileName': fileName,
          };
        } else {
          // Mobile: save to downloads directory
          try {
            final downloadsDirectory = await getDownloadsDirectory();
            if (downloadsDirectory == null) {
              return {
                'success': false,
                'message': 'Could not access downloads directory',
              };
            }

            final file = File('${downloadsDirectory.path}/$fileName');
            await file.writeAsBytes(response.bodyBytes);

            return {
              'success': true,
              'path': file.path,
              'message': 'File downloaded to ${file.path}',
            };
          } catch (e) {
            return {'success': false, 'message': 'Error saving file: $e'};
          }
        }
      } else {
        return {
          'success': false,
          'message': 'Failed to download file: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // Logout
  static Future<void> logout() async {
    await StorageService.clearAll();
  }
}
