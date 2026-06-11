import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../core/errors/error_handler.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/todo_entity.dart';
import '../../domain/repositories/todo_repository.dart';
import '../datasources/todo_remote_data_source.dart';
import '../models/todo_model.dart';

@LazySingleton(as: TodoRepository)
class TodoRepositoryImpl implements TodoRepository {
  final TodoRemoteDataSource _remoteDataSource;

  const TodoRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<void>> createTodo(TodoEntity todo) async {
    try {
      await _remoteDataSource.createTodo(TodoModel.fromEntity(todo));
      return const Success<void>(null);
    } catch (error) {
      return FailureResult<void>(ErrorHandler.toFailure(error));
    }
  }

  @override
  Stream<Result<List<TodoEntity>>> getTodos() {
    return _remoteDataSource
        .getTodos()
        .map<Result<List<TodoEntity>>>((todos) => Success(todos))
        .onErrorReturnWith(
          (error, _) => FailureResult(ErrorHandler.toFailure(error)),
        );
  }

  @override
  Future<Result<void>> updateTodo(TodoEntity todo) async {
    try {
      await _remoteDataSource.updateTodo(TodoModel.fromEntity(todo));
      return const Success<void>(null);
    } catch (error) {
      return FailureResult<void>(ErrorHandler.toFailure(error));
    }
  }

  @override
  Future<Result<void>> deleteTodo(String id) async {
    try {
      await _remoteDataSource.deleteTodo(id);
      return const Success<void>(null);
    } catch (error) {
      return FailureResult<void>(ErrorHandler.toFailure(error));
    }
  }
}
