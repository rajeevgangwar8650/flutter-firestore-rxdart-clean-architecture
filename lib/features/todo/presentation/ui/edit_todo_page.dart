import 'package:flutter/material.dart';

import '../../../../config/di/injection_container.dart';
import '../../domain/entities/todo_entity.dart';
import '../bloc/todo_bloc.dart';
import '../widgets/todo_form.dart';

class EditTodoPage extends StatefulWidget {
  final TodoBloc? bloc;
  final TodoEntity todo;
  final VoidCallback? onCancel;
  final VoidCallback? onSaved;

  const EditTodoPage({
    super.key,
    this.bloc,
    required this.todo,
    this.onCancel,
    this.onSaved,
  });

  @override
  State<EditTodoPage> createState() => _EditTodoPageState();
}

class _EditTodoPageState extends State<EditTodoPage> {
  late final TodoBloc _bloc;
  late final bool _ownsBloc;

  @override
  void initState() {
    super.initState();
    _ownsBloc = widget.bloc == null;
    _bloc = widget.bloc ?? injector<TodoBloc>();
  }

  @override
  void dispose() {
    if (_ownsBloc) {
      _bloc.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: widget.onCancel == null
            ? null
            : BackButton(onPressed: widget.onCancel),
        title: const Text('Edit Todo'),
      ),
      body: TodoForm(
        bloc: _bloc,
        initialTitle: widget.todo.title,
        initialDescription: widget.todo.description,
        submitLabel: 'Update',
        onSubmit: (title, description) async {
          final updated = await _bloc.updateTodo(
            todo: widget.todo,
            title: title,
            description: description,
          );
          if (updated && context.mounted) {
            if (widget.onSaved != null) {
              widget.onSaved!();
            } else if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          }
        },
      ),
    );
  }
}
