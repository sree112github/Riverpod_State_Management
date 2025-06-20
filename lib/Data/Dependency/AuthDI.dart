import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpodstatemanagement/Data/Controller/AuthController.dart';
import 'package:riverpodstatemanagement/Data/Dependency/bleDI.dart';
import 'package:riverpodstatemanagement/Data/repository/AuthRepository.dart';
import 'package:riverpodstatemanagement/Data/services/Apiservices/AuthServices.dart';

final authServiceProvider = Provider<AuthService>((ref)=>AuthService());


final authRepositoryProvider = Provider<AuthRepository>((ref){
 final service = ref.read(authServiceProvider);
 return AuthRepository(service);
});


final authControllerProvider = StateNotifierProvider<AuthController,AuthState>((ref){
  final repository = ref.read(authRepositoryProvider);
  return AuthController(repository);
});