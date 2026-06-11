import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_firestore_with_rxdart_project/core/errors/failures.dart';
import 'package:flutter_firestore_with_rxdart_project/core/usecases/usecase.dart';
import 'package:flutter_firestore_with_rxdart_project/core/utils/result.dart';
import 'package:flutter_firestore_with_rxdart_project/features/todo/domain/entities/todo_entity.dart';
import 'package:flutter_firestore_with_rxdart_project/features/todo/domain/usecases/create_todo_usecase.dart';
import 'package:flutter_firestore_with_rxdart_project/features/todo/domain/usecases/delete_todo_usecase.dart';
import 'package:flutter_firestore_with_rxdart_project/features/todo/domain/usecases/get_todos_usecase.dart';
import 'package:flutter_firestore_with_rxdart_project/features/todo/domain/usecases/update_todo_usecase.dart';
import 'package:flutter_firestore_with_rxdart_project/features/todo/presentation/bloc/todo_bloc.dart';
import 'package:flutter_firestore_with_rxdart_project/features/todo/presentation/ui/add_todo_page.dart';
import 'package:flutter_firestore_with_rxdart_project/features/todo/presentation/ui/edit_todo_page.dart';
import 'package:flutter_firestore_with_rxdart_project/features/todo/presentation/ui/todo_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCreateTodoUseCase extends Mock implements CreateTodoUseCase {}

class MockGetTodosUseCase extends Mock implements GetTodosUseCase {}

class MockUpdateTodoUseCase extends Mock implements UpdateTodoUseCase {}

class MockDeleteTodoUseCase extends Mock implements DeleteTodoUseCase {}

void main() {
  late MockCreateTodoUseCase createTodoUseCase;
  late MockGetTodosUseCase getTodosUseCase;
  late MockUpdateTodoUseCase updateTodoUseCase;
  late MockDeleteTodoUseCase deleteTodoUseCase;
  late TodoEntity todo;

  setUpAll(() {
    final fallbackTodo = _todo(id: 'fallback');
    registerFallbackValue(const NoParams());
    registerFallbackValue(CreateTodoParams(fallbackTodo));
    registerFallbackValue(UpdateTodoParams(fallbackTodo));
    registerFallbackValue(const DeleteTodoParams('fallback'));
  });

  setUp(() {
    createTodoUseCase = MockCreateTodoUseCase();
    getTodosUseCase = MockGetTodosUseCase();
    updateTodoUseCase = MockUpdateTodoUseCase();
    deleteTodoUseCase = MockDeleteTodoUseCase();
    todo = _todo(id: 'todo-1', title: 'Plan release');

    when(
      () => createTodoUseCase(any()),
    ).thenAnswer((_) async => const Success<void>(null));
    when(
      () => updateTodoUseCase(any()),
    ).thenAnswer((_) async => const Success<void>(null));
    when(
      () => deleteTodoUseCase(any()),
    ).thenAnswer((_) async => const Success<void>(null));
  });

  TodoBloc buildBloc() {
    return TodoBloc(
      createTodoUseCase,
      getTodosUseCase,
      updateTodoUseCase,
      deleteTodoUseCase,
    );
  }

  group('Todo List Screen', () {
    testWidgets('shows loading state while waiting for todos', (tester) async {
      final controller = StreamController<Result<List<TodoEntity>>>();
      when(() => getTodosUseCase(any())).thenAnswer((_) => controller.stream);
      final bloc = buildBloc();

      await tester.pumpWidget(_wrap(TodoPage(bloc: bloc)));
      await tester.pump();

      expect(find.byKey(const Key('todo_loading_bar')), findsOneWidget);

      await _disposeBloc(tester, bloc);
      unawaited(controller.close());
    });

    testWidgets('shows empty state when there are no todos', (tester) async {
      when(
        () => getTodosUseCase(any()),
      ).thenAnswer((_) => Stream.value(const Success(<TodoEntity>[])));
      final bloc = buildBloc();

      await tester.pumpWidget(_wrap(TodoPage(bloc: bloc)));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('todo_empty_state')), findsOneWidget);
      expect(find.text('No todos yet'), findsOneWidget);

      await _disposeBloc(tester, bloc);
    });

    testWidgets('shows success state with todo list', (tester) async {
      when(
        () => getTodosUseCase(any()),
      ).thenAnswer((_) => Stream.value(Success(<TodoEntity>[todo])));
      final bloc = buildBloc();

      await tester.pumpWidget(_wrap(TodoPage(bloc: bloc)));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('todo_list')), findsOneWidget);
      expect(find.text(todo.title), findsOneWidget);

      await _disposeBloc(tester, bloc);
    });

    testWidgets('shows error state when loading todos fails', (tester) async {
      when(() => getTodosUseCase(any())).thenAnswer(
        (_) => Stream.value(
          const FailureResult<List<TodoEntity>>(
            ServerFailure(message: 'Unable to load todos'),
          ),
        ),
      );
      final bloc = buildBloc();

      await tester.pumpWidget(_wrap(TodoPage(bloc: bloc)));
      await tester.pumpAndSettle();

      expect(find.text('Unable to load todos'), findsOneWidget);

      await _disposeBloc(tester, bloc);
    });
  });

  group('Add Todo Screen', () {
    testWidgets('validates title before saving', (tester) async {
      when(
        () => getTodosUseCase(any()),
      ).thenAnswer((_) => Stream.value(const Success(<TodoEntity>[])));
      final bloc = buildBloc();

      await tester.pumpWidget(_wrap(AddTodoPage(bloc: bloc)));
      await tester.tap(find.byKey(const Key('todo_submit_button')));
      await tester.pump();

      expect(find.text('Title is required.'), findsOneWidget);
      verifyNever(() => createTodoUseCase(any()));

      await _disposeBloc(tester, bloc);
    });

    testWidgets('saves a valid todo when the button is tapped', (tester) async {
      when(
        () => getTodosUseCase(any()),
      ).thenAnswer((_) => Stream.value(const Success(<TodoEntity>[])));
      final bloc = buildBloc();

      await tester.pumpWidget(_wrap(AddTodoPage(bloc: bloc)));
      await tester.enterText(
        find.byKey(const Key('todo_title_field')),
        'Ship Todo CRUD',
      );
      await tester.enterText(
        find.byKey(const Key('todo_description_field')),
        'With tests and Firestore.',
      );
      await tester.tap(find.byKey(const Key('todo_submit_button')));
      await tester.pumpAndSettle();

      verify(() => createTodoUseCase(any())).called(1);

      await _disposeBloc(tester, bloc);
    });
  });

  group('Edit Todo Screen', () {
    testWidgets('shows existing todo data', (tester) async {
      when(
        () => getTodosUseCase(any()),
      ).thenAnswer((_) => Stream.value(Success(<TodoEntity>[todo])));
      final bloc = buildBloc();

      await tester.pumpWidget(_wrap(EditTodoPage(bloc: bloc, todo: todo)));

      expect(find.text(todo.title), findsOneWidget);
      expect(find.text(todo.description), findsOneWidget);

      await _disposeBloc(tester, bloc);
    });

    testWidgets('updates a todo from the form', (tester) async {
      when(
        () => getTodosUseCase(any()),
      ).thenAnswer((_) => Stream.value(Success(<TodoEntity>[todo])));
      final bloc = buildBloc();

      await tester.pumpWidget(_wrap(EditTodoPage(bloc: bloc, todo: todo)));
      await tester.enterText(
        find.byKey(const Key('todo_title_field')),
        'Updated release plan',
      );
      await tester.tap(find.byKey(const Key('todo_submit_button')));
      await tester.pumpAndSettle();

      verify(() => updateTodoUseCase(any())).called(1);

      await _disposeBloc(tester, bloc);
    });
  });
}

Widget _wrap(Widget child) {
  return MaterialApp(home: child);
}

Future<void> _disposeBloc(WidgetTester tester, TodoBloc bloc) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump();
  bloc.dispose();
}

TodoEntity _todo({
  required String id,
  String title = 'Test todo',
  String description = 'Test description',
  bool isCompleted = false,
}) {
  return TodoEntity(
    id: id,
    title: title,
    description: description,
    isCompleted: isCompleted,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );
}
