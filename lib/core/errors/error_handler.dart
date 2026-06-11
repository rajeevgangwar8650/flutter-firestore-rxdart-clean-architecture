import 'package:cloud_firestore/cloud_firestore.dart';

import 'exceptions.dart';
import 'failures.dart';

class ErrorHandler {
  static Failure toFailure(Object error) {
    if (error is FirebaseException) {
      return FirebaseFailure(
        message: _firebaseMessage(error),
        code: error.code,
      );
    }

    if (error is FirebaseDataException) {
      return FirebaseFailure(message: error.message, code: error.code);
    }

    if (error is NetworkException) {
      return NetworkFailure(message: error.message, code: error.code);
    }

    if (error is ValidationException) {
      return ValidationFailure(message: error.message, code: error.code);
    }

    if (error is ServerException) {
      return ServerFailure(message: error.message, code: error.code);
    }

    return UnknownFailure(message: getMessage(error));
  }

  static String getMessage(Object error) {
    if (error is Failure) {
      return error.message;
    }

    if (error is Exception) {
      final message = error.toString().replaceFirst('Exception: ', '');
      return message.isEmpty ? 'Something went wrong.' : message;
    }

    final message = error.toString();
    return message.isEmpty ? 'Something went wrong.' : message;
  }


  static String _firebaseMessage(FirebaseException error) {
    return switch (error.code) {
      'permission-denied' => 'You do not have permission to access todos.',
      'unavailable' => 'Firestore is currently unavailable. Please try again.',
      'not-found' => 'The requested todo was not found.',
      'cancelled' => 'The Firestore request was cancelled.',
      _ => error.message ?? 'A Firebase error occurred.',
    };
  }
}
