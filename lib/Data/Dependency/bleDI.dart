import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../Controller/bleController.dart';
import '../repository/bleRepository.dart';
import '../services/BluetoothServices/bleService.dart';

// Service Provider
final bluetoothServicesProvider = Provider<BluetoothServices>((ref) {
  return BluetoothServices();
});

// Repository Provider
final bluetoothRepositoryProvider = Provider<BluetoothRepository>((ref) {
  final service = ref.read(bluetoothServicesProvider);
  return BluetoothRepository(service);
});

// Controller (StateNotifier) Provider
final bluetoothControllerProvider =
StateNotifierProvider<BluetoothController, BluetoothState>((ref) {
  final repository = ref.read(bluetoothRepositoryProvider);
  return BluetoothController(repository);
});
