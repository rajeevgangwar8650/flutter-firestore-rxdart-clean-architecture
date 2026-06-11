import 'package:flutter_firestore_with_rxdart_project/core/errors/exceptions.dart';
import 'package:flutter_firestore_with_rxdart_project/core/utils/result.dart';
import 'package:flutter_firestore_with_rxdart_project/features/todo/data/datasources/todo_remote_data_source.dart';
import 'package:flutter_firestore_with_rxdart_project/features/todo/data/models/todo_model.dart';
import 'package:flutter_firestore_with_rxdart_project/features/todo/data/repositories/todo_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockTodoRemoteDataSource extends Mock implements TodoRemoteDataSource {}

void main() {
  late MockTodoRemoteDataSource remoteDataSource;
  late TodoRepositoryImpl repository;
  late TodoModel todo;

  setUpAll(() {
    final now = DateTime(2026);
    registerFallbackValue(
      TodoModel(
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
    remoteDataSource = MockTodoRemoteDataSource();
    repository = TodoRepositoryImpl(remoteDataSource);
    todo = TodoModel(
      id: 'todo-1',
      title: 'Repository test',
      description: 'Success path',
      isCompleted: false,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );
  });

  group('createTodo', () {
    test('returns Success when the remote data source succeeds', () async {
      when(() => remoteDataSource.createTodo(any())).thenAnswer((_) async {});

      final result = await repository.createTodo(todo);

      expect(result, const Success<void>(null));
      verify(() => remoteDataSource.createTodo(todo)).called(1);
    });

    test('returns FailureResult when the remote data source throws', () async {
      when(
        () => remoteDataSource.createTodo(any()),
      ).thenThrow(const FirebaseDataException(message: 'Create failed'));

      final result = await repository.createTodo(todo);

      expect(result, isA<FailureResult<void>>());
      expect((result as FailureResult<void>).error.message, 'Create failed');
    });
  });

  group('getTodos', () {
    test('maps remote models to a Success stream', () {
      when(
        remoteDataSource.getTodos,
      ).thenAnswer((_) => Stream<List<TodoModel>>.value([todo]));

      expect(
        repository.getTodos(),
        emits(
          isA<Success<List>>()
              .having((result) => result.data.length, 'length', 1)
              .having((result) => result.data.first.title, 'title', todo.title),
        ),
      );
    });

    test('maps remote stream errors to FailureResult', () {
      when(remoteDataSource.getTodos).thenAnswer(
        (_) => Stream<List<TodoModel>>.error(
          const FirebaseDataException(message: 'Stream failed'),
        ),
      );

      expect(
        repository.getTodos(),
        emits(
          isA<FailureResult<List>>().having(
            (result) => result.error.message,
            'message',
            'Stream failed',
          ),
        ),
      );
    });
  });

  group('updateTodo', () {
    test('returns Success when the remote data source succeeds', () async {
      when(() => remoteDataSource.updateTodo(any())).thenAnswer((_) async {});

      final result = await repository.updateTodo(todo);

      expect(result, const Success<void>(null));
      verify(() => remoteDataSource.updateTodo(todo)).called(1);
    });

    test('returns FailureResult when the remote data source throws', () async {
      when(
        () => remoteDataSource.updateTodo(any()),
      ).thenThrow(const FirebaseDataException(message: 'Update failed'));

      final result = await repository.updateTodo(todo);

      expect(result, isA<FailureResult<void>>());
      expect((result as FailureResult<void>).error.message, 'Update failed');
    });
  });

  group('deleteTodo', () {
    test('returns Success when the remote data source succeeds', () async {
      when(() => remoteDataSource.deleteTodo(any())).thenAnswer((_) async {});

      final result = await repository.deleteTodo(todo.id);

      expect(result, const Success<void>(null));
      verify(() => remoteDataSource.deleteTodo(todo.id)).called(1);
    });

    test('returns FailureResult when the remote data source throws', () async {
      when(
        () => remoteDataSource.deleteTodo(any()),
      ).thenThrow(const FirebaseDataException(message: 'Delete failed'));

      final result = await repository.deleteTodo(todo.id);

      expect(result, isA<FailureResult<void>>());
      expect((result as FailureResult<void>).error.message, 'Delete failed');
    });
  });
}
