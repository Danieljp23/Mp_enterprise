import 'package:flutter/material.dart';
import 'package:maple/modals/modal_creates_tasks.dart';
import 'package:maple/providers/auth_provider.dart';
import 'package:maple/providers/task_provider.dart';
import 'package:maple/screens/screen_first.dart';
import 'package:maple/styles/colors.dart';
import 'package:provider/provider.dart';

class ScreenTask extends StatefulWidget {
  const ScreenTask({super.key});

  static const routeName = '/tasks';

  @override
  State<ScreenTask> createState() => _ScreenTaskState();
}

class _ScreenTaskState extends State<ScreenTask> {
  bool _redirecting = false;
  bool _requestedInitialLoad = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tryLoadTasks();
    });
  }

  void _tryLoadTasks() {
    if (!mounted) return;
    final authProvider = context.read<AuthProvider>();
    final taskProvider = context.read<TaskProvider>();
    if (authProvider.workspaceLinked && !_requestedInitialLoad) {
      _requestedInitialLoad = true;
      taskProvider.loadTasks();
    }
  }

  Future<void> _signOut(BuildContext context) async {
    await context.read<AuthProvider>().signOut();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, FirstScreen.routeName);
  }

  Future<void> _handleLinkWorkspace() async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.linkWorkspaceAccount();
    if (!mounted) return;
    if (authProvider.workspaceLinked) {
      _requestedInitialLoad = false;
      _tryLoadTasks();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    if (user == null && !_redirecting) {
      _redirecting = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, FirstScreen.routeName);
        }
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (authProvider.workspaceLinked && !_requestedInitialLoad) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _tryLoadTasks());
    }

    final taskProvider = context.watch<TaskProvider>();

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tarefas Workspace',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              user?.email ?? '',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
        backgroundColor: MyColors.orangeDark,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: authProvider.workspaceLinked
                ? () => context.read<TaskProvider>().loadTasks()
                : null,
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: MyColors.orangeDark,
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: MyColors.orangeMediun),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  (user?.displayName ?? 'M')[0],
                  style: const TextStyle(color: MyColors.orangeDark),
                ),
              ),
              accountName: Text(user?.displayName ?? 'Usuário'),
              accountEmail: Text(user?.email ?? ''),
            ),
            ListTile(
              leading: const Icon(Icons.menu_book_rounded, color: Colors.white),
              title: const Text('Sobre aplicativo',
                  style: TextStyle(color: Colors.white)),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.white),
              title:
                  const Text('Deslogar', style: TextStyle(color: Colors.white)),
              onTap: () => _signOut(context),
            ),
            ListTile(
              leading: const Icon(Icons.arrow_back, color: Colors.white),
              title:
                  const Text('Fechar', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: authProvider.workspaceLinked ? () => modalTask(context) : null,
        backgroundColor: MyColors.orangeDark,
        label: const Row(
          children: [
            Icon(
              Icons.add,
              color: Colors.white,
            ),
            SizedBox(width: 8),
            Text(
              'Nova Tarefa',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      body: authProvider.workspaceLinked
          ? _buildTaskBody(taskProvider)
          : _buildWorkspaceLinkCallout(authProvider      ),
    );
  }

  Widget _buildWorkspaceLinkCallout(AuthProvider authProvider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off,
              size: 64,
              color: MyColors.orangeDark,
            ),
            const SizedBox(height: 16),
            const Text(
              'Conecte seu Google Workspace para visualizar e criar tarefas.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: authProvider.isLoading ? null : _handleLinkWorkspace,
              style: ElevatedButton.styleFrom(
                backgroundColor: MyColors.orangeDark,
                foregroundColor: Colors.white,
                minimumSize: const Size(200, 48),
              ),
              child: Text(
                authProvider.isLoading ? 'Conectando...' : 'Conectar Workspace',
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
    );
  }

  Widget _buildTaskBody(TaskProvider taskProvider) {
    if (taskProvider.isLoading && taskProvider.tasks.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (taskProvider.error != null && taskProvider.tasks.isEmpty) {
      return Center(
        child: Text(
          taskProvider.error!,
          textAlign: TextAlign.center,
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: taskProvider.loadTasks,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: taskProvider.tasks.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final task = taskProvider.tasks[index];
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              title: Text(task.summary),
              subtitle: Text(
                task.notes.isEmpty ? 'Sem descrição' : task.notes,
              ),
              trailing: Text(task.status),
            ),
          );
        },
      ),
    );
  }
}
