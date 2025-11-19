import 'package:easy_splash_screen/easy_splash_screen.dart';
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
      await Future.delayed(const Duration(seconds: 2));
      final authProvider = context.read<AuthProvider>();
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
    return EasySplashScreen(
      logo: Image.asset(
        'images/logo_maple.png',
      ),
      logoWidth: 150,
      backgroundColor: Colors.white,
      loaderColor: Colors.deepOrange,
      durationInSeconds: 3,
      navigator: Container(),
      showLoader: true,
    );
  }
}
