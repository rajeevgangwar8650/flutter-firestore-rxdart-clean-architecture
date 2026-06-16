import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../core/errors/error_handler.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/validators.dart';
import '../../domain/entities/todo_entity.dart';
import '../../domain/usecases/create_todo_usecase.dart';
import '../../domain/usecases/delete_todo_usecase.dart';
import '../../domain/usecases/get_todos_usecase.dart';
import '../../domain/usecases/update_todo_usecase.dart';

@injectable
class TodoBloc {
  final CreateTodoUseCase _createTodoUseCase;
  final GetTodosUseCase _getTodosUseCase;
  final UpdateTodoUseCase _updateTodoUseCase;
  final DeleteTodoUseCase _deleteTodoUseCase;

  final BehaviorSubject<List<TodoEntity>> _todosSubject =
      BehaviorSubject<List<TodoEntity>>.seeded(const <TodoEntity>[]);
  final BehaviorSubject<String> _searchSubject = BehaviorSubject<String>.seeded(
    '',
  );
  final BehaviorSubject<bool> _loadingSubject = BehaviorSubject<bool>.seeded(
    false,
  );
  final BehaviorSubject<String?> _listErrorSubject =
      BehaviorSubject<String?>.seeded(null);
  final PublishSubject<String> _actionErrorSubject = PublishSubject<String>();
  final PublishSubject<String> _successSubject = PublishSubject<String>();

  StreamSubscription<Result<List<TodoEntity>>>? _todosSubscription;

  TodoBloc(
    this._createTodoUseCase,
    this._getTodosUseCase,
    this._updateTodoUseCase,
    this._deleteTodoUseCase,
  );

  Stream<List<TodoEntity>> get todosStream => Rx.combineLatest2(
    _todosSubject.stream,
    _searchSubject.stream.distinct(),
    _filterTodos,
  );

  Stream<bool> get loadingStream => _loadingSubject.stream.distinct();

  Stream<String?> get listErrorStream => _listErrorSubject.stream.distinct();

  Stream<String> get actionErrorStream => _actionErrorSubject.stream;

  Stream<String> get successStream => _successSubject.stream;

  String get currentSearchQuery => _searchSubject.value;

  void loadTodos() {
    _todosSubscription?.cancel();
    _setLoading(true);
    _listErrorSubject.add(null);

    _todosSubscription = _getTodosUseCase(const NoParams()).listen(
      (result) {
        _setLoading(false);
        result.when(
          success: (todos) {
            _listErrorSubject.add(null);
            _todosSubject.add(todos);
          },
          failure: (failure) {
            _listErrorSubject.add(failure.message);
          },
        );
      },
      onError: (Object error) {
        _setLoading(false);
        _listErrorSubject.add(ErrorHandler.getMessage(error));
      },
    );
  }

  Future<void> refreshTodos() async {
    loadTodos();
    await _todosSubject.stream.first;
  }

  void searchTodos(String query) {
    _searchSubject.add(query.trim());
  }

  Future<bool> createTodo({
    required String title,
    required String description,
  }) async {
    final validationMessage =
        Validators.todoTitle(title) ?? Validators.todoDescription(description);
    if (validationMessage != null) {
      _actionErrorSubject.add(validationMessage);
      return false;
    }

    _setLoading(true);
    final result = await _createTodoUseCase(
      CreateTodoParams(
        TodoEntity.create(title: title, description: description),
      ),
    );
    _setLoading(false);

    return result.when(
      success: (_) {
        _successSubject.add('Todo created.');
        return true;
      },
      failure: (failure) {
        _actionErrorSubject.add(failure.message);
        return false;
      },
    );
  }

  Future<bool> updateTodo({
    required TodoEntity todo,
    required String title,
    required String description,
  }) async {
    final validationMessage =
        Validators.todoTitle(title) ?? Validators.todoDescription(description);
    if (validationMessage != null) {
      _actionErrorSubject.add(validationMessage);
      return false;
    }

    _setLoading(true);
    final result = await _updateTodoUseCase(
      UpdateTodoParams(
        todo.copyWith(
          title: title.trim(),
          description: description.trim(),
          updatedAt: DateTime.now(),
        ),
      ),
    );
    _setLoading(false);

    return result.when(
      success: (_) {
        _successSubject.add('Todo updated.');
        return true;
      },
      failure: (failure) {
        _actionErrorSubject.add(failure.message);
        return false;
      },
    );
  }

  Future<bool> toggleTodoCompletion(TodoEntity todo) async {
    _setLoading(true);
    final result = await _updateTodoUseCase(
      UpdateTodoParams(
        todo.copyWith(
          isCompleted: !todo.isCompleted,
          updatedAt: DateTime.now(),
        ),
      ),
    );
    _setLoading(false);

    return result.when(
      success: (_) {
        _successSubject.add(
          todo.isCompleted ? 'Todo marked active.' : 'Todo completed.',
        );
        return true;
      },
      failure: (failure) {
        _actionErrorSubject.add(failure.message);
        return false;
      },
    );
  }

  Future<bool> deleteTodo(String id) async {
    _setLoading(true);
    final result = await _deleteTodoUseCase(DeleteTodoParams(id));
    _setLoading(false);

    return result.when(
      success: (_) {
        _successSubject.add('Todo deleted.');
        return true;
      },
      failure: (failure) {
        _actionErrorSubject.add(failure.message);
        return false;
      },
    );
  }

  void _setLoading(bool isLoading) {
    if (_loadingSubject.isClosed) {
      return;
    }

    _loadingSubject.add(isLoading);
  }

  List<TodoEntity> _filterTodos(List<TodoEntity> todos, String query) {
    if (query.isEmpty) {
      return todos;
    }

    final normalizedQuery = query.toLowerCase();
    return todos
        .where(
          (todo) =>
              todo.title.toLowerCase().contains(normalizedQuery) ||
              todo.description.toLowerCase().contains(normalizedQuery),
        )
        .toList(growable: false);
  }

  void dispose() {
    _todosSubscription?.cancel();
    _todosSubject.close();
    _searchSubject.close();
    _loadingSubject.close();
    _listErrorSubject.close();
    _actionErrorSubject.close();
    _successSubject.close();
  }
}
