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
  final _formKey = GlobalKey<FormState>();
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleFirebaseAuth(BuildContext context,
      {required bool register}) async {
    if (!_formKey.currentState!.validate()) return;
    final authProvider = context.read<AuthProvider>();

    if (register) {
      await authProvider.registerWithEmailAndPassword(
        _loginController.text.trim(),
        _passwordController.text.trim(),
      );
    } else {
      await authProvider.signInWithEmailAndPassword(
        _loginController.text.trim(),
        _passwordController.text.trim(),
      );
    }

    if (mounted && authProvider.isAuthenticated && authProvider.error == null) {
      Navigator.pushReplacementNamed(context, ScreenTask.routeName);
    }
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset('images/logo_maple.png'),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _loginController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: getInputDecoration('E-mail corporativo'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Informe seu e-mail';
                    }
                    if (!value.contains('@')) {
                      return 'E-mail inválido';
                    }
                    return null;
                  },
                  enabled: !authProvider.isLoading,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _passwordController,
                  decoration: getInputDecoration('Senha').copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  obscureText: _obscurePassword,
                  enabled: !authProvider.isLoading,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Informe sua senha';
                    }
                    if (value.trim().length < 6) {
                      return 'A senha deve ter ao menos 6 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: authProvider.isLoading
                      ? null
                      : () => _handleFirebaseAuth(context, register: false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MyColors.orangeDark,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: Text(
                    authProvider.isLoading
                        ? 'Processando...'
                        : 'Entrar com Firebase',
                  ),
                ),
                TextButton(
                  onPressed: authProvider.isLoading
                      ? null
                      : () => _handleFirebaseAuth(context, register: true),
                  child: const Text('Criar conta com Firebase'),
                ),
                const SizedBox(height: 16),
                Row(
                  children: const [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text('ou'),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 16),
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
                    backgroundColor: Colors.white,
                    foregroundColor: MyColors.orangeDark,
                    side: const BorderSide(color: MyColors.orangeDark),
                    minimumSize: const Size.fromHeight(48),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Ao acessar com Firebase conectaremos seu Workspace para '
                  'sincronizar tarefas.',
                  textAlign: TextAlign.center,
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
      ),
    );
  }
}
