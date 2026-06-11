import '../../../../core/utils/result.dart';
import '../entities/todo_entity.dart';

abstract class TodoRepository {
  Future<Result<void>> createTodo(TodoEntity todo);

  Stream<Result<List<TodoEntity>>> getTodos();

  Future<Result<void>> updateTodo(TodoEntity todo);

  Future<Result<void>> deleteTodo(String id);
}
