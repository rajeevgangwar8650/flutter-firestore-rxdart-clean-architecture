import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/result.dart';
import '../repositories/todo_repository.dart';

@lazySingleton
class DeleteTodoUseCase implements UseCase<Result<void>, DeleteTodoParams> {
  final TodoRepository _repository;

  const DeleteTodoUseCase(this._repository);

  @override
  Future<Result<void>> call(DeleteTodoParams params) {
    return _repository.deleteTodo(params.id);
  }
}

class DeleteTodoParams extends Equatable {
  final String id;

  const DeleteTodoParams(this.id);

  @override
  List<Object?> get props => [id];
}
