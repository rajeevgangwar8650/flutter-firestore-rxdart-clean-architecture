import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firestore_with_rxdart_project/app.dart';
import 'package:flutter_firestore_with_rxdart_project/config/di/injection_container.dart';
import 'package:flutter_firestore_with_rxdart_project/features/todo/data/datasources/todo_remote_data_source.dart';
import 'package:flutter_firestore_with_rxdart_project/features/todo/data/repositories/todo_repository_impl.dart';
import 'package:flutter_firestore_with_rxdart_project/features/todo/domain/usecases/create_todo_usecase.dart';
import 'package:flutter_firestore_with_rxdart_project/features/todo/domain/usecases/delete_todo_usecase.dart';
import 'package:flutter_firestore_with_rxdart_project/features/todo/domain/usecases/get_todos_usecase.dart';
import 'package:flutter_firestore_with_rxdart_project/features/todo/domain/usecases/update_todo_usecase.dart';
import 'package:flutter_firestore_with_rxdart_project/features/todo/presentation/bloc/todo_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() async {
    await injector.reset();
  });

  testWidgets('Scenario 1: launch app, add todo, verify in list', (
    tester,
  ) async {
    await _pumpFakeApp(tester);

    await _addTodo(tester, title: 'Buy coffee', description: 'Whole beans');

    expect(find.text('Buy coffee'), findsOneWidget);
    expect(find.text('Whole beans'), findsOneWidget);
  });

  testWidgets('Scenario 2: edit todo and verify update', (tester) async {
    await _pumpFakeApp(tester);
    await _addTodo(tester, title: 'Draft notes', description: 'First pass');

    await tester.tap(find.text('Draft notes'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('todo_title_field')),
      'Draft release notes',
    );
    await tester.tap(find.byKey(const Key('todo_submit_button')));
    await tester.pumpAndSettle();

    expect(find.text('Draft release notes'), findsOneWidget);
    expect(find.text('Draft notes'), findsNothing);
  });

  testWidgets('Scenario 3: delete todo and verify removal', (tester) async {
    await _pumpFakeApp(tester);
    await _addTodo(tester, title: 'Delete me', description: 'Temporary');

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirm_delete_button')));
    await tester.pumpAndSettle();

    expect(find.text('Delete me'), findsNothing);
    expect(find.byKey(const Key('todo_empty_state')), findsOneWidget);
  });

  testWidgets('Scenario 4: toggle completion and verify UI update', (
    tester,
  ) async {
    await _pumpFakeApp(tester);
    await _addTodo(tester, title: 'Toggle me', description: 'Check it off');

    expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isFalse);

    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();

    expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isTrue);
  });
}

Future<void> _pumpFakeApp(WidgetTester tester) async {
  final firestore = FakeFirebaseFirestore();
  final dataSource = TodoRemoteDataSourceImpl(firestore);
  final repository = TodoRepositoryImpl(dataSource);

  injector.registerFactory<TodoBloc>(
    () => TodoBloc(
      CreateTodoUseCase(repository),
      GetTodosUseCase(repository),
      UpdateTodoUseCase(repository),
      DeleteTodoUseCase(repository),
    ),
  );

  await tester.pumpWidget(const App());
  await tester.pumpAndSettle();
}

Future<void> _addTodo(
  WidgetTester tester, {
  required String title,
  required String description,
}) async {
  await tester.tap(find.byIcon(Icons.add));
  await tester.pumpAndSettle();
  await tester.enterText(find.byKey(const Key('todo_title_field')), title);
  await tester.enterText(
    find.byKey(const Key('todo_description_field')),
    description,
  );
  await tester.tap(find.byKey(const Key('todo_submit_button')));
  await tester.pumpAndSettle();
}
