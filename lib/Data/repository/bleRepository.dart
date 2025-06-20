
import 'package:riverpodstatemanagement/Data/Controller/bleController.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../services/BluetoothServices/bleService.dart';

class BluetoothRepository {
  final BluetoothServices _bluetoothServices;

  BluetoothRepository(this._bluetoothServices);

  Future<bool> connectToDevice(String targetDeviceId) {
    return _bluetoothServices.startScanAndConnect(targetDeviceId: targetDeviceId);
  }

  Future<void> disconnect() async {
    await _bluetoothServices.disconnect();
  }

  Future<void> sendData(String data) async {
    await _bluetoothServices.sendData(data);
  }

  Stream<String> get receivedDataStream => _bluetoothServices.receivedDataStream;

  Stream<BluetoothConnectionState>? get deviceConnectionStateStream =>
      _bluetoothServices.deviceConnectionStateStream;

  Stream<BluetoothAdapterState> get bluetoothStateStream => _bluetoothServices.bluetoothStateStream;

}
