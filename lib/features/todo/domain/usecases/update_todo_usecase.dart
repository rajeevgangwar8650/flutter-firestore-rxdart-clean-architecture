import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/todo_entity.dart';
import '../repositories/todo_repository.dart';

@lazySingleton
class UpdateTodoUseCase implements UseCase<Result<void>, UpdateTodoParams> {
  final TodoRepository _repository;

  const UpdateTodoUseCase(this._repository);

  @override
  Future<Result<void>> call(UpdateTodoParams params) {
    return _repository.updateTodo(params.todo);
  }
}

class UpdateTodoParams extends Equatable {
  final TodoEntity todo;

  const UpdateTodoParams(this.todo);

  @override
  List<Object?> get props => [todo];
}
