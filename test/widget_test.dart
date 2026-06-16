import 'package:flutter/material.dart';
import 'package:flutter_firestore_with_rxdart_project/app.dart';
import 'package:flutter_firestore_with_rxdart_project/config/di/injection_container.dart';
import 'package:flutter_firestore_with_rxdart_project/config/routes/app_routes.dart';
import 'package:flutter_firestore_with_rxdart_project/config/routes/route_generator.dart';
import 'package:flutter_firestore_with_rxdart_project/core/usecases/usecase.dart';
import 'package:flutter_firestore_with_rxdart_project/core/utils/result.dart';
import 'package:flutter_firestore_with_rxdart_project/features/todo/domain/entities/todo_entity.dart';
import 'package:flutter_firestore_with_rxdart_project/features/todo/domain/usecases/create_todo_usecase.dart';
import 'package:flutter_firestore_with_rxdart_project/features/todo/domain/usecases/delete_todo_usecase.dart';
import 'package:flutter_firestore_with_rxdart_project/features/todo/domain/usecases/get_todos_usecase.dart';
import 'package:flutter_firestore_with_rxdart_project/features/todo/domain/usecases/update_todo_usecase.dart';
import 'package:flutter_firestore_with_rxdart_project/features/todo/presentation/bloc/todo_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCreateTodoUseCase extends Mock implements CreateTodoUseCase {}

class MockGetTodosUseCase extends Mock implements GetTodosUseCase {}

class MockUpdateTodoUseCase extends Mock implements UpdateTodoUseCase {}

class MockDeleteTodoUseCase extends Mock implements DeleteTodoUseCase {}

void main() {
  setUpAll(() {
    final fallbackTodo = TodoEntity(
      id: 'fallback',
      title: 'Fallback',
      description: '',
      isCompleted: false,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );
    registerFallbackValue(const NoParams());
    registerFallbackValue(CreateTodoParams(fallbackTodo));
    registerFallbackValue(UpdateTodoParams(fallbackTodo));
    registerFallbackValue(const DeleteTodoParams('fallback'));
  });

  tearDown(() async {
    await injector.reset();
  });

  testWidgets('App launches the Todo list route', (tester) async {
    injector.registerFactory<TodoBloc>(
      () =>
          _buildBloc(todosStream: Stream.value(const Success(<TodoEntity>[]))),
    );

    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    expect(find.text('Todos'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
  });

  testWidgets('Add todo FAB navigates to the add route', (tester) async {
    injector.registerFactory<TodoBloc>(
      () =>
          _buildBloc(todosStream: Stream.value(const Success(<TodoEntity>[]))),
    );
    final router = RouteGenerator.createRouter(initialLocation: AppRoutes.todo);
    addTearDown(router.dispose);

    await tester.pumpWidget(App(router: router));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    expect(find.text('Add Todo'), findsOneWidget);
    expect(router.state.uri.path, AppRoutes.addTodo);
  });

  testWidgets('App opens the Add Todo route directly', (tester) async {
    injector.registerFactory<TodoBloc>(
      () =>
          _buildBloc(todosStream: Stream.value(const Success(<TodoEntity>[]))),
    );
    final router = RouteGenerator.createRouter(
      initialLocation: AppRoutes.addTodo,
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(App(router: router));
    await tester.pumpAndSettle();

    expect(find.text('Add Todo'), findsOneWidget);
    expect(find.byKey(const Key('todo_title_field')), findsOneWidget);
    expect(router.state.uri.path, AppRoutes.addTodo);
  });
}

TodoBloc _buildBloc({required Stream<Result<List<TodoEntity>>> todosStream}) {
  final createTodoUseCase = MockCreateTodoUseCase();
  final getTodosUseCase = MockGetTodosUseCase();
  final updateTodoUseCase = MockUpdateTodoUseCase();
  final deleteTodoUseCase = MockDeleteTodoUseCase();

  when(() => getTodosUseCase(any())).thenAnswer((_) => todosStream);
  when(
    () => createTodoUseCase(any()),
  ).thenAnswer((_) async => const Success<void>(null));
  when(
    () => updateTodoUseCase(any()),
  ).thenAnswer((_) async => const Success<void>(null));
  when(
    () => deleteTodoUseCase(any()),
  ).thenAnswer((_) async => const Success<void>(null));

  return TodoBloc(
    createTodoUseCase,
    getTodosUseCase,
    updateTodoUseCase,
    deleteTodoUseCase,
  );
}
