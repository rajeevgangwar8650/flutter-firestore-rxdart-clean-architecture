import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_textfield.dart';
import '../bloc/todo_bloc.dart';

class TodoForm extends StatefulWidget {
  final TodoBloc bloc;
  final String? initialTitle;
  final String? initialDescription;
  final String submitLabel;
  final Future<void> Function(String title, String description) onSubmit;

  const TodoForm({
    super.key,
    required this.bloc,
    required this.submitLabel,
    required this.onSubmit,
    this.initialTitle,
    this.initialDescription,
  });

  @override
  State<TodoForm> createState() => _TodoFormState();
}

class _TodoFormState extends State<TodoForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  StreamSubscription<String>? _errorSubscription;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _descriptionController = TextEditingController(
      text: widget.initialDescription,
    );
    _errorSubscription = widget.bloc.actionErrorStream.listen((message) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    });
  }

  @override
  void dispose() {
    _errorSubscription?.cancel();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final maxWidth = width >= 900
            ? 720.0
            : width >= 600
            ? 640.0
            : double.infinity;
        final horizontalPadding = width >= 600 ? 32.0 : 16.0;

        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                24,
                horizontalPadding,
                24,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppTextField(
                      key: const Key('todo_title_field'),
                      controller: _titleController,
                      label: 'Title',
                      textInputAction: TextInputAction.next,
                      validator: Validators.todoTitle,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      key: const Key('todo_description_field'),
                      controller: _descriptionController,
                      label: 'Description',
                      maxLines: 5,
                      textInputAction: TextInputAction.newline,
                      validator: Validators.todoDescription,
                    ),
                    const SizedBox(height: 24),
                    StreamBuilder<bool>(
                      stream: widget.bloc.loadingStream,
                      initialData: false,
                      builder: (context, snapshot) {
                        final isLoading = snapshot.data == true;
                        return AppButton(
                          key: const Key('todo_submit_button'),
                          label: widget.submitLabel,
                          isLoading: isLoading,
                          onPressed: isLoading ? null : _submit,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    await widget.onSubmit(_titleController.text, _descriptionController.text);
  }
}
