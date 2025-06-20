import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class BluetoothServices {
  final String targetServiceUUID = "4fafc201-1fb5-459e-8fcc-c5c9c331914b";
  final String targetCharacteristicUUID = "beb5483e-36e1-4688-b7f5-ea07361b26a8";


  StreamSubscription<List<ScanResult>>? _scanSubscription;
  StreamSubscription<List<int>>? _characteristicSubscription;

  final StreamController<String> _receivedDataController = StreamController<String>.broadcast();
  Stream<String> get receivedDataStream => _receivedDataController.stream;

  StreamSubscription<BluetoothConnectionState>? _deviceConnectionSubscription;

  BluetoothCharacteristic? _writeCharacteristic;
  BluetoothDevice? _connectedDevice;

  Future<void> requestPermissions() async {
    await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.bluetoothAdvertise,
      Permission.locationWhenInUse,
    ].request();
  }

  Future<bool> isSupported() async {
    return await FlutterBluePlus.isSupported;
  }

  Future<void> turnOnBluetoothIfPossible() async {
    if (Platform.isAndroid) {
      await FlutterBluePlus.turnOn();
    }
  }

  Future<bool> startScanAndConnect({required String targetDeviceId}) async {
    await requestPermissions();
    await turnOnBluetoothIfPossible();

    if (!await FlutterBluePlus.isSupported) {
      print("Bluetooth not supported on this device.");
      return false;
    }

    if (!await Permission.bluetoothScan.isGranted) {
      print("Bluetooth scan permission not granted.");
      return false;
    }

    final completer = Completer<bool>();

    // Start scan
    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));

    // Set a fallback timeout to return false after 15 seconds
    Future.delayed(const Duration(seconds: 15), () async {
      if (!completer.isCompleted) {
        await stopScan();
        print("❌ No device found within 15 seconds.");
        completer.complete(false);
      }
    });

    _scanSubscription = FlutterBluePlus.scanResults.listen((results) async {
      for (ScanResult r in results) {
        print("Found device: ${r.device.platformName} [${r.device.remoteId.str}]");

        if (r.device.remoteId.str.toLowerCase() == targetDeviceId.toLowerCase()) {
          await stopScan();
          final isConnected = await connectToDeviceAndListen(r.device);
          if (!completer.isCompleted) {
            completer.complete(isConnected ?? false);
          }
          break;
        }
      }
    });

    return completer.future;
  }


  Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
    await _scanSubscription?.cancel();
    _scanSubscription = null;
  }

  Future<bool?> connectToDeviceAndListen(BluetoothDevice device) async {
    await device.connect(autoConnect: false);
    _connectedDevice = device;

    await _deviceConnectionSubscription?.cancel();
    _deviceConnectionSubscription = device.connectionState.listen((state) {
      print("Device connection state: $state");
    });

    // ✅ Discover services
    List<BluetoothService> services = await device.discoverServices();

    // ✅ DEBUG: Print all discovered services and characteristics
    print("Discovered ${services.length} services");
    for (var s in services) {
      print("Service: ${s.uuid}");
      for (var c in s.characteristics) {
        print("  Characteristic: ${c.uuid}");
      }
    }


    for (BluetoothService service in services) {
      if (service.uuid.toString().toLowerCase() == targetServiceUUID.toLowerCase()) {
        for (BluetoothCharacteristic c in service.characteristics) {
          if (c.uuid.toString().toLowerCase() == targetCharacteristicUUID.toLowerCase()) {
            _writeCharacteristic = c;

            await c.setNotifyValue(true);

            await _characteristicSubscription?.cancel();
            _characteristicSubscription = c.lastValueStream.listen((value) {
              final decoded = utf8.decode(value);
              print("Received from ESP32: $decoded");
              _receivedDataController.add(decoded);
            });

            await sendData("Hello from Flutter");

            return device.isConnected; // ✅ EXIT after successful connection
          }
        }
      }
    }
    return null;

  }

  Future<void> sendData(String data) async {
    if (_writeCharacteristic == null) {
      print("❌ No connected characteristic to write to.");
      return;
    }

    try {
      await _writeCharacteristic!.write(
        utf8.encode(data),
        withoutResponse: false,
      );
      print("✅ Sent data: $data");
    } catch (e) {
      print("❌ Error sending data: $e");
    }
  }

  Future<void> disconnect() async {
    try {
      await stopScan();
      if (_connectedDevice != null) {
        await _connectedDevice!.disconnect();
        print("Disconnected from ${_connectedDevice!.platformName}");
      }
      _writeCharacteristic = null;
      _connectedDevice = null;

      await _characteristicSubscription?.cancel();
      _characteristicSubscription = null;

      await _deviceConnectionSubscription?.cancel();
      _deviceConnectionSubscription = null;

    } catch (e) {
      print("Error during disconnect: $e");
    }
  }


  Future<BluetoothAdapterState> getBluetoothState() async {
    await FlutterBluePlus.turnOn();
    return await FlutterBluePlus.adapterState.first;
  }

  Stream<BluetoothConnectionState>? get deviceConnectionStateStream => _connectedDevice?.connectionState;


  Stream<BluetoothAdapterState> get bluetoothStateStream => FlutterBluePlus.adapterState;
}