import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:maple/firebase_conection/firebase_auth.dart';
import 'package:maple/firebase_options.dart';
import 'package:maple/providers/auth_provider.dart';
import 'package:maple/providers/task_provider.dart';
import 'package:maple/screens/screen_first.dart';
import 'package:maple/screens/screen_tasks.dart';
import 'package:maple/screens/splash.dart';
import 'package:maple/services/google_workspace_service.dart';
import 'package:maple/styles/colors.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MapleApp());
}

class MapleApp extends StatelessWidget {
  const MapleApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authRepository = FirebaseAuthRepository();
    final workspaceService =
        GoogleWorkspaceService(authRepository: authRepository);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(authRepository)..initialize(),
        ),
        ChangeNotifierProvider<TaskProvider>(
          create: (_) => TaskProvider(workspaceService),
        ),
      ],
      child: MaterialApp(
        title: 'Maple Workspace',
        theme: ThemeData(
          primaryColor: MyColors.orangeDark,
          colorScheme: ColorScheme.fromSeed(
            seedColor: MyColors.orangeDark,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ),
        initialRoute: Splash.routeName,
        routes: {
          Splash.routeName: (_) => const Splash(),
          FirstScreen.routeName: (_) => const FirstScreen(),
          ScreenTask.routeName: (_) => const ScreenTask(),
        },
      ),
    );
  }
}
