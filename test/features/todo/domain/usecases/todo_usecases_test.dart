import 'package:flutter_firestore_with_rxdart_project/core/usecases/usecase.dart';
import 'package:flutter_firestore_with_rxdart_project/core/utils/result.dart';
import 'package:flutter_firestore_with_rxdart_project/features/todo/domain/entities/todo_entity.dart';
import 'package:flutter_firestore_with_rxdart_project/features/todo/domain/repositories/todo_repository.dart';
import 'package:flutter_firestore_with_rxdart_project/features/todo/domain/usecases/create_todo_usecase.dart';
import 'package:flutter_firestore_with_rxdart_project/features/todo/domain/usecases/delete_todo_usecase.dart';
import 'package:flutter_firestore_with_rxdart_project/features/todo/domain/usecases/get_todos_usecase.dart';
import 'package:flutter_firestore_with_rxdart_project/features/todo/domain/usecases/update_todo_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockTodoRepository extends Mock implements TodoRepository {}

void main() {
  late MockTodoRepository repository;
  late TodoEntity todo;

  setUpAll(() {
    final now = DateTime(2026);
    registerFallbackValue(
      TodoEntity(
        id: 'fallback',
        title: 'Fallback',
        description: '',
        isCompleted: false,
        createdAt: now,
        updatedAt: now,
      ),
    );
  });

  setUp(() {
    repository = MockTodoRepository();
    todo = TodoEntity(
      id: 'todo-1',
      title: 'Write tests',
      description: 'Cover the domain layer',
      isCompleted: false,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );
  });

  group('CreateTodoUseCase', () {
    test('delegates todo creation to the repository', () async {
      final useCase = CreateTodoUseCase(repository);
      when(
        () => repository.createTodo(any()),
      ).thenAnswer((_) async => const Success<void>(null));

      final result = await useCase(CreateTodoParams(todo));

      expect(result, const Success<void>(null));
      verify(() => repository.createTodo(todo)).called(1);
    });
  });

  group('GetTodosUseCase', () {
    test('returns the repository realtime stream', () {
      final useCase = GetTodosUseCase(repository);
      final stream = Stream<Result<List<TodoEntity>>>.value(Success([todo]));
      when(repository.getTodos).thenAnswer((_) => stream);

      expect(useCase(const NoParams()), emits(Success([todo])));
      verify(repository.getTodos).called(1);
    });
  });

  group('UpdateTodoUseCase', () {
    test('delegates todo updates to the repository', () async {
      final useCase = UpdateTodoUseCase(repository);
      when(
        () => repository.updateTodo(any()),
      ).thenAnswer((_) async => const Success<void>(null));

      final result = await useCase(UpdateTodoParams(todo));

      expect(result, const Success<void>(null));
      verify(() => repository.updateTodo(todo)).called(1);
    });
  });

  group('DeleteTodoUseCase', () {
    test('delegates todo deletion to the repository', () async {
      final useCase = DeleteTodoUseCase(repository);
      when(
        () => repository.deleteTodo(any()),
      ).thenAnswer((_) async => const Success<void>(null));

      final result = await useCase(const DeleteTodoParams('todo-1'));

      expect(result, const Success<void>(null));
      verify(() => repository.deleteTodo('todo-1')).called(1);
    });
  });
}
