import 'package:flutter/material.dart';

import '../../domain/entities/todo_entity.dart';
import '../bloc/todo_bloc.dart';
import '../widgets/todo_form.dart';

class EditTodoPage extends StatelessWidget {
  final TodoBloc bloc;
  final TodoEntity todo;

  const EditTodoPage({super.key, required this.bloc, required this.todo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Todo')),
      body: TodoForm(
        bloc: bloc,
        initialTitle: todo.title,
        initialDescription: todo.description,
        submitLabel: 'Update',
        onSubmit: (title, description) async {
          final updated = await bloc.updateTodo(
            todo: todo,
            title: title,
            description: description,
          );
          if (updated && context.mounted) {
            Navigator.of(context).pop();
          }
        },
      ),
    );
  }
}
