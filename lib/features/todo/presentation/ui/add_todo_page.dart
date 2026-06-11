import 'package:flutter/material.dart';

import '../bloc/todo_bloc.dart';
import '../widgets/todo_form.dart';

class AddTodoPage extends StatelessWidget {
  final TodoBloc bloc;

  const AddTodoPage({super.key, required this.bloc});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Todo')),
      body: TodoForm(
        bloc: bloc,
        submitLabel: 'Save',
        onSubmit: (title, description) async {
          final created = await bloc.createTodo(
            title: title,
            description: description,
          );
          if (created && context.mounted) {
            Navigator.of(context).pop();
          }
        },
      ),
    );
  }
}
