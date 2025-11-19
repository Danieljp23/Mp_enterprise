import 'package:flutter/material.dart';
import 'package:maple/providers/task_provider.dart';
import 'package:maple/styles/colors.dart';
import 'package:maple/styles/inputDecoration.dart';
import 'package:provider/provider.dart';

void modalTask(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: MyColors.orangeMediun,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(30),
      ),
    ),
    builder: (context) => const ModalTasks(),
  );
}

class ModalTasks extends StatefulWidget {
  const ModalTasks({super.key});

  @override
  State<ModalTasks> createState() => _ModalTasksState();
}

class _ModalTasksState extends State<ModalTasks> {
  final _nameTaskController = TextEditingController();
  final _descriptionTaskController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDate;

  @override
  void dispose() {
    _nameTaskController.dispose();
    _descriptionTaskController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
      initialDate: _selectedDate ?? now,
      helpText: 'Selecionar data de conclusão',
    );
    if (selected != null) {
      setState(() {
        _selectedDate = selected;
      });
    }
  }

  Future<void> _submit(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;
    final taskProvider = context.read<TaskProvider>();
    await taskProvider.createTask(
      summary: _nameTaskController.text.trim(),
      description: _descriptionTaskController.text.trim(),
      dueDate: _selectedDate,
    );
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final viewInsets = MediaQuery.of(context).viewInsets;
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Adicionar Tarefa',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nameTaskController,
              decoration: getInputDecorationAddTask('Nome da tarefa'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Informe um nome para a tarefa';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionTaskController,
              decoration: getInputDecorationAddTask('Descrição'),
              minLines: 2,
              maxLines: 4,
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              style: TextButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: MyColors.orangeDark,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
              onPressed: () => _pickDate(context),
              icon: const Icon(Icons.calendar_today),
              label: Text(
                _selectedDate == null
                    ? 'Selecionar data'
                    : 'Concluir até ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: MyColors.orangeDark,
                minimumSize: const Size.fromHeight(48),
              ),
              onPressed: taskProvider.isLoading ? null : () => _submit(context),
              child: Text(
                taskProvider.isLoading ? 'Salvando...' : 'Criar Tarefa',
                style: const TextStyle(fontSize: 18),
              ),
            ),
            if (taskProvider.error != null) ...[
              const SizedBox(height: 12),
              Text(
                taskProvider.error!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
