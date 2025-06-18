import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'bleDI.dart';


class BluetoothScreen extends ConsumerWidget {
  final String deviceId;

  BluetoothScreen({required this.deviceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(bluetoothControllerProvider.notifier);
    final state = ref.watch(bluetoothControllerProvider);


    return Scaffold(
      appBar: AppBar(
        title: const Text('BLE Example'),
        actions: [
          IconButton(
            icon: Icon(Icons.link_off),
            onPressed: () => controller.disconnect(),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [

            Text("Connection status: ${state.isConnected ? "Connected" : "Disconnected"}"),
            const SizedBox(height: 16),
            if (state.receivedData != null)
              Text("Received: ${state.receivedData}"),

            if(state.isSending)...[
              CircularProgressIndicator()
            ],
            const Spacer(),
            ElevatedButton(
              onPressed: state.isConnected ? () => controller.sendData("scanNetworks") : null,
              child: const Text("Send Hello"),
            ),
            ElevatedButton(
              onPressed: () => controller.connect(deviceId),
              child: const Text("Connect"),
            ),
          ],
        ),
      ),
    );
  }
}
