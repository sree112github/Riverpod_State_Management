import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'package:riverpodstatemanagement/AppCore/CenteralExceptionHandling.dart';
import 'package:riverpodstatemanagement/Data/models/AuthModel.dart';
import '../../../AppCore/baserurl.dart';

class AuthService {
  Future<AuthModel> userLogin(String email, String password) async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      log("Connectivity status: $connectivityResult");
      if (connectivityResult == ConnectivityResult.none) {
        throw NetworkConnectionException();
      }
      final url = Uri.parse("$baseUrl/login");

      final response = await http
          .post(
            url,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({"email": email, "password": password}),
          )
          .timeout(Duration(seconds: 20));

      log("Login response status: ${response.statusCode}");

      switch (response.statusCode) {
        case 200:
          final responseData = jsonDecode(response.body);
          return AuthModel.fromJson(responseData);
        case 401:
          log("Invalid credentials: ${response.body}");
          throw InvalidCredentialException();
        case 403:
          log("Access denied: ${response.body}");
          throw AccessDeniedException();
        default:
          log("Unhandled error: ${response.statusCode} - ${response.body}");
          throw UnknownException();
      }
    } on TimeoutException {
      throw ServerTimeOutException();
    } on SocketException {
      log("Socket exception during User login");
      throw ServerUnReachableException();
    }
    on Exception catch (e) {
      if (e is AppException) rethrow;
      log("Unhandled exception in userLogin: $e");
      throw UnknownException();
    }
  }
}
