import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'AppCore/Approutes.dart';
import 'feature/BlutoothScreen/Screen/blescreen.dart';
import 'feature/LoginScreen/Screen/loginScreen.dart';




void main(){
  runApp(ProviderScope(child:MyApp()));
}


class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider); // watch the router

    return MaterialApp.router(
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      title: 'My App',
    );
  }
}