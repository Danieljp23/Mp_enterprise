import 'package:flutter/material.dart';
import 'package:maple/providers/auth_provider.dart';
import 'package:maple/screens/screen_first.dart';
import 'package:maple/screens/screen_tasks.dart';
import 'package:provider/provider.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  static const routeName = '/splash';

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authProvider = context.read<AuthProvider>();
      
      // Aguarda o AuthProvider terminar de inicializar
      while (authProvider.isLoading && mounted) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      
      // Aguarda um tempo mínimo para mostrar a splash
      await Future.delayed(const Duration(seconds: 2));
      
      if (!mounted) return;
      
      if (authProvider.isAuthenticated) {
        Navigator.pushReplacementNamed(context, ScreenTask.routeName);
      } else {
        Navigator.pushReplacementNamed(context, FirstScreen.routeName);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'images/logo_maple.png',
              width: 150,
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(
              color: Colors.deepOrange,
            ),
          ],
        ),
      ),
    );
  }
}
