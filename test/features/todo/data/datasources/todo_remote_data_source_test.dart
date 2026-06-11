import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_firestore_with_rxdart_project/features/todo/data/datasources/todo_remote_data_source.dart';
import 'package:flutter_firestore_with_rxdart_project/features/todo/data/models/todo_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late TodoRemoteDataSourceImpl dataSource;
  late TodoModel todo;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    dataSource = TodoRemoteDataSourceImpl(firestore);
    todo = TodoModel(
      id: 'todo-1',
      title: 'Firestore test',
      description: 'Persisted in fake Firestore',
      isCompleted: false,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );
  });

  test('createTodo writes a todo document to Firestore', () async {
    await dataSource.createTodo(todo);

    final snapshot = await firestore.collection('todos').doc(todo.id).get();

    expect(snapshot.exists, isTrue);
    expect(snapshot.data()?['title'], todo.title);
  });

  test('getTodos emits realtime Firestore updates', () async {
    final stream = dataSource.getTodos();

    await dataSource.createTodo(todo);

    final todos = await stream.firstWhere((items) => items.isNotEmpty);
    expect(todos.single.title, todo.title);
  });

  test('updateTodo updates an existing Firestore document', () async {
    await dataSource.createTodo(todo);

    await dataSource.updateTodo(
      todo.copyWith(
        title: 'Updated title',
        isCompleted: true,
        updatedAt: DateTime(2026, 1, 2),
      ),
    );

    final snapshot = await firestore.collection('todos').doc(todo.id).get();
    expect(snapshot.data()?['title'], 'Updated title');
    expect(snapshot.data()?['isCompleted'], isTrue);
  });

  test('deleteTodo removes an existing Firestore document', () async {
    await dataSource.createTodo(todo);

    await dataSource.deleteTodo(todo.id);

    final snapshot = await firestore.collection('todos').doc(todo.id).get();
    expect(snapshot.exists, isFalse);
  });
}
