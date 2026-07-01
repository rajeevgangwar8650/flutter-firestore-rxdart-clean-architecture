import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/di/injection_container.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../domain/entities/todo_entity.dart';
import '../bloc/todo_bloc.dart';
import '../widgets/todo_empty_state.dart';
import '../widgets/todo_tile.dart';

class TodoPage extends StatefulWidget {
  final TodoBloc? bloc;

  const TodoPage({super.key, this.bloc});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  late final TodoBloc _bloc;
  late final bool _ownsBloc;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _ownsBloc = widget.bloc == null;
    _bloc = widget.bloc ?? injector<TodoBloc>();
    _bloc.loadTodos();
  }

  @override
  void dispose() {
    if (_ownsBloc) {
      _bloc.dispose();
    }
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Todos',style: TextStyle(fontSize: MediaQuery.of(context).size.width> 600 ? 20 : 16),),
        centerTitle: false,
        actions: [
          StreamBuilder<bool>(
            stream: _bloc.loadingStream,
            initialData: false,
            builder: (context, snapshot) {
              return IconButton(
                tooltip: 'Refresh',
                onPressed: snapshot.data == true ? null : _bloc.loadTodos,
                icon: const Icon(Icons.refresh),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add todo',
        onPressed: () => _openAddTodo(context),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final maxWidth = width >= 1100
                ? 920.0
                : width >= 700
                ? 720.0
                : double.infinity;
            final horizontalPadding = width >= 700 ? 32.0 : 16.0;

            return Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    16,
                    horizontalPadding,
                    0,
                  ),
                  child: Column(
                    children: [
                      TextField(
                        key: const Key('todo_search_field'),
                        controller: _searchController,
                        onChanged: (query) {
                          _bloc.searchTodos(query);
                          setState(() {});
                        },
                        decoration: InputDecoration(
                          hintText: 'Search todos',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  tooltip: 'Clear search',
                                  icon: const Icon(Icons.close),
                                  onPressed: () {
                                    _searchController.clear();
                                    _bloc.searchTodos('');
                                    FocusScope.of(context).unfocus();
                                    setState(() {});
                                  },
                                )
                              : const SizedBox.shrink(),
                          border: const OutlineInputBorder(),
                          filled: true,
                          fillColor: colorScheme.surface,
                        ),
                      ),
                      const SizedBox(height: 12),
                      StreamBuilder<bool>(
                        stream: _bloc.loadingStream,
                        initialData: false,
                        builder: (context, snapshot) {
                          return AnimatedSwitcher(
                            duration: const Duration(milliseconds: 180),
                            child: snapshot.data == true
                                ? const LinearProgressIndicator(
                                    key: Key('todo_loading_bar'),
                                  )
                                : const SizedBox(
                                    key: Key('todo_loading_placeholder'),
                                    height: 4,
                                  ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: _bloc.refreshTodos,
                          child: _TodoListContent(
                            bloc: _bloc,
                            onEdit: (todo) => _openEditTodo(context, todo),
                            onDelete: (todo) => _confirmDelete(context, todo),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _openAddTodo(BuildContext context) {
    context.go(AppRoutes.addTodo);
  }

  void _openEditTodo(BuildContext context, TodoEntity todo) {
    context.go(AppRoutes.editTodo, extra: todo);
  }

  Future<void> _confirmDelete(BuildContext context, TodoEntity todo) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete todo?'),
        content: Text('Delete "${todo.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            key: const Key('confirm_delete_button'),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete != true || !context.mounted) {
      return;
    }

    final deleted = await _bloc.deleteTodo(todo.id);
    if (deleted && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Todo deleted.')));
    }
  }
}

class _TodoListContent extends StatelessWidget {
  final TodoBloc bloc;
  final ValueChanged<TodoEntity> onEdit;
  final ValueChanged<TodoEntity> onDelete;

  const _TodoListContent({
    required this.bloc,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String?>(
      stream: bloc.listErrorStream,
      initialData: null,
      builder: (context, errorSnapshot) {
        final errorMessage = errorSnapshot.data;
        if (errorMessage != null) {
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(height: MediaQuery.sizeOf(context).height * 0.22),
              AppErrorWidget(message: errorMessage),
            ],
          );
        }
        return StreamBuilder<List<TodoEntity>>(
          stream: bloc.todosStream,
          initialData: const <TodoEntity>[],
          builder: (context, todoSnapshot) {
            final todos = todoSnapshot.data ?? const <TodoEntity>[];
            if (todoSnapshot.connectionState == ConnectionState.waiting) {
              return const LoadingWidget();
            }

            if (todos.isEmpty) {
              return const TodoEmptyState();
            }

            return ListView.separated(
              key: const Key('todo_list'),
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 96),
              itemCount: todos.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final todo = todos[index];
                return TodoTile(
                  key: ValueKey('todo_tile_${todo.id}'),
                  todo: todo,
                  onToggle: () => bloc.toggleTodoCompletion(todo),
                  onEdit: () => onEdit(todo),
                  onDelete: () => onDelete(todo),
                );
              },
            );
          },
        );
      },
    );
  }
}
