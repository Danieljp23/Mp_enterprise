import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/tasks/v1.dart' as tasks_api;
import 'package:http/http.dart' as http;
import 'package:maple/firebase_conection/firebase_auth.dart';
import 'package:maple/models/task.dart';
import 'package:maple/services/google_auth_client.dart';

class WorkspaceAuthException implements Exception {
  WorkspaceAuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

class GoogleWorkspaceService {
  GoogleWorkspaceService({
    required FirebaseAuthRepository authRepository,
    http.Client? httpClient,
  })  : _authRepository = authRepository,
        _httpClient = httpClient ?? http.Client();

  final FirebaseAuthRepository _authRepository;
  final http.Client _httpClient;
  static const String _defaultTaskList = '@default';

  Future<tasks_api.TasksApi> _getTasksApi() async {
    await _authRepository.refreshGoogleSignIn();
    final GoogleSignInAccount? account = _authRepository.currentGoogleUser;
    if (account == null) {
      throw WorkspaceAuthException(
        'Conecte sua conta do Google Workspace para acessar as tarefas.',
      );
    }

    final headers = await account.authHeaders;
    final client = GoogleAuthClient(headers, _httpClient);
    return tasks_api.TasksApi(client);
  }

  Future<List<MapleTask>> fetchTasks() async {
    final api = await _getTasksApi();
    final response =
        await api.tasks.list(_defaultTaskList, showCompleted: true);

    final items = response.items ?? [];
    return items
        .map(
          (item) => MapleTask(
            id: item.id ?? '',
            summary: item.title ?? 'Sem título',
            notes: item.notes ?? '',
            start: item.due ?? DateTime.now().toUtc().toIso8601String(),
            end: item.completed ?? item.due,
            status: item.status ?? 'needsAction',
          ),
        )
        .toList();
  }

  Future<MapleTask> createTask({
    required String summary,
    String? notes,
    DateTime? dueDate,
  }) async {
    final api = await _getTasksApi();
    final task = tasks_api.Task()
      ..title = summary
      ..notes = notes
      ..due = dueDate?.toUtc().toIso8601String();

    final created = await api.tasks.insert(task, _defaultTaskList);
    return MapleTask(
      id: created.id ?? '',
      summary: created.title ?? summary,
      notes: created.notes ?? notes ?? '',
      start: created.due ?? DateTime.now().toUtc().toIso8601String(),
      end: created.completed ?? created.due,
      status: created.status ?? 'needsAction',
    );
  }

  Future<void> deleteTask(String taskId) async {
    final api = await _getTasksApi();
    await api.tasks.delete(_defaultTaskList, taskId);
  }
}
