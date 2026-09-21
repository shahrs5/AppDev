import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'post.dart';

class NoInternetException implements Exception {
  final String message;
  NoInternetException(this.message);

  @override
  String toString() => message;
}

class ServerException implements Exception {
  final String message;
  ServerException(this.message);

  @override
  String toString() => message;
}

class DataParsingException implements Exception {
  final String message;
  DataParsingException(this.message);

  @override
  String toString() => message;
}

class ApiResponse<T> {
  const ApiResponse({
    required this.statusCode,
    required this.data
  });

  final int statusCode;
  final T data;
}

class PostsApi {
  PostsApi({http.Client? client}) : _client = client ?? http.Client();

  static final _base = Uri.parse('https://jsonplaceholder.typicode.com/users');

  final http.Client _client;

  Future<ApiResponse<List<UserModel>>> fetchUsers() async {
    try {
    final response = await _client.get(_base).timeout(const Duration(seconds: 8));
    if (response.statusCode != 200) {
      throw ServerException('Server error: GET /users failed: ${response.statusCode}');
    }
    final body = jsonDecode(response.body) as List<dynamic>;
    final users = body
      .cast<Map<String,dynamic>>()
      .map(UserModel.fromJson)
      .toList();
    return ApiResponse(statusCode: response.statusCode, data: users);
    } on SocketException {
      throw NoInternetException('No internet connection');
    } on http.ClientException {
      throw NoInternetException('No internet connection');
    } on TimeoutException {
      throw NoInternetException('Request timed out, check your connection');
    } on FormatException {
      throw DataParsingException('Invalid data received');
    } on TypeError {
      throw DataParsingException('Invalid data received');
    }
  }

  Future<ApiResponse<UserModel>> fetchUserById(int id) async {
    try {
    final response = await _client.get(Uri.parse('https://jsonplaceholder.typicode.com/users/$id')).timeout(const Duration(seconds: 8));
    if (response.statusCode != 200) {
      throw ServerException('Server error: GET /users/$id failed: ${response.statusCode}');
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return ApiResponse(statusCode: response.statusCode, data: UserModel.fromJson(body));
    } on SocketException {
      throw NoInternetException('No internet connection');
    } on http.ClientException {
      throw NoInternetException('No internet connection');
    } on TimeoutException {
      throw NoInternetException('Request timed out, check your connection');
    } on FormatException {
      throw DataParsingException('Invalid data received');
    } on TypeError {
      throw DataParsingException('Invalid data received');
    }
  }
}