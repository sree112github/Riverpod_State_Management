import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpodstatemanagement/Data/Controller/AuthController.dart';
import 'package:riverpodstatemanagement/Data/Dependency/AuthDI.dart';
import 'package:go_router/go_router.dart';


class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context,WidgetRef ref) {
    
    ref.listen<AuthState>(authControllerProvider,(previous,next){
      if(next is AuthSuccess){
        context.go('/bluetooth/7c:87:ce:2f:ed:82');
      }
    });

    final emailController = TextEditingController();
    final passwordController = TextEditingController();


    final authController = ref.read(authControllerProvider.notifier);

    return Scaffold(
      body:Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          TextField(controller: emailController),
            TextField(controller: passwordController,),

            SizedBox(height: 10,),

            ElevatedButton(onPressed: (){
              authController.userLogin(emailController.text.trim(), passwordController.text.trim());
            }, child: Text("login")),

            Consumer(builder:(context,ref,child){
              final authState = ref.watch(authControllerProvider);
              if(authState is AuthLoading){
                return CircularProgressIndicator();
              }else if(authState is AuthFailure){
                return Text(authState.error);
              }else if(authState is AuthSuccess){
                return Text(authState.user.userName);
              }
              else{
                return Text("Please login ");
              }

            })
          ],
        ),
      ),
    );
  }
}
