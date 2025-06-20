import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../feature/BlutoothScreen/Screen/blescreen.dart';
import '../feature/LoginScreen/Screen/loginScreen.dart';


// GoRouter provider (Riverpod way)
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/bluetooth/:deviceId',
        builder: (context, state) {
          final deviceId = state.pathParameters['deviceId']!;
          return BluetoothScreen(deviceId: deviceId);
        },
      ),
    ],
  );
});
