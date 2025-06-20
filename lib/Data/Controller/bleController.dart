import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpodstatemanagement/Data/services/encryptionServices/encryptioservice.dart';
import '../repository/bleRepository.dart';


class BluetoothState {
  final bool isConnected;
  final String? receivedData;
  final bool isSending;

  BluetoothState({required this.isConnected, this.receivedData,required this.isSending});

  BluetoothState copyWith({bool? isConnected, String? receivedData,bool? isSending}) {
    return BluetoothState(
      isConnected: isConnected ?? this.isConnected,
      receivedData: receivedData ?? this.receivedData,
      isSending: isSending ?? this.isSending
    );
  }
}


class BluetoothController extends StateNotifier<BluetoothState> {
  final BluetoothRepository _repository;

  BluetoothController(this._repository) : super(BluetoothState(isConnected: false,isSending: false)) {
    _listenToIncomingData();
  }

  Future<void> connect(String deviceId) async {
    final success = await _repository.connectToDevice(deviceId);
    state = state.copyWith(isConnected: success);
  }

  Future<void> disconnect() async {
    await _repository.disconnect();
    state = state.copyWith(isConnected: false);
  }

  Future<void> sendData(String data) async {

    state = state.copyWith(isSending: true);
    final encryptData = EncryptionService.encrypt(data, "4d3ffcdc1ac23dc6a87ddc7a53e30aeb");
    await _repository.sendData(encryptData);
  }

  void _listenToIncomingData() {
    _repository.receivedDataStream.listen((data) {
      state = state.copyWith(receivedData: data,isSending: false);
    });
  }
}
