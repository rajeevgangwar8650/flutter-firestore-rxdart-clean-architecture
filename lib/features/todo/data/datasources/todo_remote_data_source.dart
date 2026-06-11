import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/exceptions.dart';
import '../models/todo_model.dart';

abstract class TodoRemoteDataSource {
  Future<void> createTodo(TodoModel todo);

  Stream<List<TodoModel>> getTodos();

  Future<void> updateTodo(TodoModel todo);

  Future<void> deleteTodo(String id);
}

@LazySingleton(as: TodoRemoteDataSource)
class TodoRemoteDataSourceImpl implements TodoRemoteDataSource {
  final FirebaseFirestore _firestore;

  const TodoRemoteDataSourceImpl(this._firestore);

  CollectionReference<Map<String, dynamic>> get _todosCollection =>
      _firestore.collection('todos');

  @override
  Future<void> createTodo(TodoModel todo) async {
    try {
      final document = todo.id.isEmpty
          ? _todosCollection.doc()
          : _todosCollection.doc(todo.id);
      await document.set(todo.copyWith(id: document.id).toFirestore());
    } on FirebaseException catch (error) {
      throw FirebaseDataException(
        message: error.message ?? 'Unable to create todo.',
        code: error.code,
      );
    } catch (error) {
      throw ServerException(message: error.toString());
    }
  }

  @override
  Stream<List<TodoModel>> getTodos() {
    return _todosCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(TodoModel.fromFirestore)
              .toList(growable: false),
        );
  }

  @override
  Future<void> updateTodo(TodoModel todo) async {
    try {
      if (todo.id.isEmpty) {
        throw const ValidationException(message: 'Todo id is required.');
      }

      await _todosCollection.doc(todo.id).update(todo.toFirestore());
    } on FirebaseException catch (error) {
      throw FirebaseDataException(
        message: error.message ?? 'Unable to update todo.',
        code: error.code,
      );
    } on ValidationException {
      rethrow;
    } catch (error) {
      throw ServerException(message: error.toString());
    }
  }

  @override
  Future<void> deleteTodo(String id) async {
    try {
      if (id.isEmpty) {
        throw const ValidationException(message: 'Todo id is required.');
      }

      await _todosCollection.doc(id).delete();
    } on FirebaseException catch (error) {
      throw FirebaseDataException(
        message: error.message ?? 'Unable to delete todo.',
        code: error.code,
      );
    } on ValidationException {
      rethrow;
    } catch (error) {
      throw ServerException(message: error.toString());
    }
  }
}
