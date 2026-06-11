import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/todo_entity.dart';
import '../repositories/todo_repository.dart';

@lazySingleton
class CreateTodoUseCase implements UseCase<Result<void>, CreateTodoParams> {
  final TodoRepository _repository;

  const CreateTodoUseCase(this._repository);

  @override
  Future<Result<void>> call(CreateTodoParams params) {
    return _repository.createTodo(params.todo);
  }
}

class CreateTodoParams extends Equatable {
  final TodoEntity todo;

  const CreateTodoParams(this.todo);

  @override
  List<Object?> get props => [todo];
}
