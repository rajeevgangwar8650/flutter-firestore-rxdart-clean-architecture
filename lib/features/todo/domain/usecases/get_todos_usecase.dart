import 'package:injectable/injectable.dart';

import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/todo_entity.dart';
import '../repositories/todo_repository.dart';

@lazySingleton
class GetTodosUseCase
    implements StreamUseCase<Result<List<TodoEntity>>, NoParams> {
  final TodoRepository _repository;

  const GetTodosUseCase(this._repository);

  @override
  Stream<Result<List<TodoEntity>>> call(NoParams params) {
    return _repository.getTodos();
  }
}
