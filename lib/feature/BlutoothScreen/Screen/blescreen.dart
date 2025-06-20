import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../Data/Dependency/bleDI.dart';

class BluetoothScreen extends ConsumerWidget {
  final String deviceId;

  BluetoothScreen({required this.deviceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(bluetoothControllerProvider.notifier);
    log("Entire widget is rebuilding");

    return Scaffold(
      appBar: AppBar(
        title: const Text('BLE Example'),
        actions: [
          IconButton(
            icon: Icon(Icons.link_off),
            onPressed: () => controller.disconnect(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Consumer(
              builder: (context, ref, child) {
                log("COnnection widget rebuild");
                final isConnected = ref.watch(bluetoothControllerProvider.select((state)=>state.isConnected));
                return isConnected?Text(
                  "Connection status: ${isConnected
                      ? "Connected"
                      : "Disconnected"}",
                ): CircularProgressIndicator();
              }),

            const SizedBox(height: 16),
            Consumer(
              builder: (context,ref,child) {
                log("recieved data part rebuild");
                final isSending = ref.watch(bluetoothControllerProvider.select((state)=>state.isSending));
                final receivedData = ref.watch(bluetoothControllerProvider.select((state)=> state.receivedData));
                 if(receivedData != null) {
                   return isSending ? CircularProgressIndicator() : Text(
                       "Recieved Data: ${receivedData}");
                 }else{
                   return Text("Data is not found");
                 }
                 
              }),

            const Spacer(),
            Consumer(
              builder: (context, ref, child) {
                log("send hello button rebuild");
                final state = ref.watch(bluetoothControllerProvider);

                return ElevatedButton(
                  onPressed: state.isConnected
                      ? () => controller.sendData("scanNetworks")
                      : null,
                  child: const Text("Send Hello"),
                );
              },
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
