import 'package:flutter/material.dart';
import 'package:maple/models/task.dart';
import 'package:maple/services/google_workspace_service.dart';

class TaskProvider extends ChangeNotifier {
  TaskProvider(this._workspaceService);

  final GoogleWorkspaceService _workspaceService;

  List<MapleTask> _tasks = [];
  bool _isLoading = false;
  String? _error;

  List<MapleTask> get tasks => List.unmodifiable(_tasks);
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadTasks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _tasks = await _workspaceService.fetchTasks();
    } catch (e) {
      _error = 'Erro ao carregar tarefas: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createTask({
    required String summary,
    String? description,
    DateTime? dueDate,
  }) async {
    _error = null;
    _isLoading = true;
    notifyListeners();
    try {
      final created = await _workspaceService.createTask(
        summary: summary,
        notes: description,
        dueDate: dueDate,
      );
      _tasks = [..._tasks, created];
    } catch (e) {
      _error = 'Erro ao criar tarefa: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
