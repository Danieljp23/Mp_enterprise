import 'package:flutter/material.dart';
import 'package:maple/providers/auth_provider.dart';
import 'package:maple/screens/screen_tasks.dart';
import 'package:maple/styles/colors.dart';
import 'package:maple/styles/inputDecoration.dart';
import 'package:provider/provider.dart';

class FirstScreen extends StatefulWidget {
  const FirstScreen({super.key});

  static const routeName = '/login';

  @override
  State<FirstScreen> createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleGoogleSignIn(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.signInWithGoogle();
    if (mounted && authProvider.isAuthenticated) {
      Navigator.pushReplacementNamed(context, ScreenTask.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset('images/logo_maple.png'),
              const SizedBox(height: 20),
              TextFormField(
                controller: _loginController,
                decoration: getInputDecoration('Login corporativo'),
                enabled: false,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _passwordController,
                decoration: getInputDecoration('Senha'),
                enabled: false,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: authProvider.isLoading
                    ? null
                    : () => _handleGoogleSignIn(context),
                icon: const Icon(Icons.account_circle),
                label: Text(
                  authProvider.isLoading
                      ? 'Entrando...'
                      : 'Entrar com Google Workspace',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: MyColors.orangeDark,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
              if (authProvider.error != null) ...[
                const SizedBox(height: 16),
                Text(
                  authProvider.error!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
