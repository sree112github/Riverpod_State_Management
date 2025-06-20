import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpodstatemanagement/AppCore/CenteralExceptionHandling.dart';
import 'package:riverpodstatemanagement/Data/models/AuthModel.dart';
import 'package:riverpodstatemanagement/Data/repository/AuthRepository.dart';

/// Sealed class for auth states
sealed class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final AuthModel user;
  AuthSuccess(this.user);
}

class AuthFailure extends AuthState {
  final String error;
  AuthFailure(this.error);
}

/// Auth Controller using StateNotifier
class AuthController extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthController(this._authRepository) : super(AuthInitial());

  Future<void> userLogin(String email, String password) async {
    state = AuthLoading();
    try {
      final user = await _authRepository.userLogin(email, password);
      state = AuthSuccess(user);
    } on NetworkConnectionException {
      state = AuthFailure("Check Your Internet Conncetion");
    } on ServerUnReachableException {
      state = AuthFailure("Server is currently unreachable Check Your Connection");
    }
    on InvalidCredentialException {
      state = AuthFailure("Invalid email or password.");
    } on AccessDeniedException {
      state = AuthFailure("You don't have access.");
    } on ServerTimeOutException{
      state = AuthFailure("TimeOut error");
    }
    on UnknownException {
      state = AuthFailure("An unexpected error occurred.");
    }
  }
}

