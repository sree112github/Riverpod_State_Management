import 'package:riverpodstatemanagement/Data/services/Apiservices/AuthServices.dart';

import '../models/AuthModel.dart';

class AuthRepository {
  final AuthService _authService;
  AuthRepository(this._authService);

  Future<AuthModel> userLogin(String email, String password) {
    return _authService.userLogin(email, password);
  }
}
