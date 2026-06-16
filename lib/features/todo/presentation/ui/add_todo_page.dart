import 'package:flutter/material.dart';

import '../../../../config/di/injection_container.dart';
import '../bloc/todo_bloc.dart';
import '../widgets/todo_form.dart';

class AddTodoPage extends StatefulWidget {
  final TodoBloc? bloc;
  final VoidCallback? onCancel;
  final VoidCallback? onSaved;

  const AddTodoPage({super.key, this.bloc, this.onCancel, this.onSaved});

  @override
  State<AddTodoPage> createState() => _AddTodoPageState();
}

class _AddTodoPageState extends State<AddTodoPage> {
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
        title: const Text('Add Todo'),
      ),
      body: TodoForm(
        bloc: _bloc,
        submitLabel: 'Save',
        onSubmit: (title, description) async {
          final created = await _bloc.createTodo(
            title: title,
            description: description,
          );
          if (created && context.mounted) {
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
