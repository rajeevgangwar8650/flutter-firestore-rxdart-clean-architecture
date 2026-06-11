class ServerException implements Exception {
  final String message;
  final String? code;

  const ServerException({required this.message, this.code});

  @override
  String toString() => message;
}

class FirebaseDataException implements Exception {
  final String message;
  final String? code;

  const FirebaseDataException({required this.message, this.code});

  @override
  String toString() => message;
}

class NetworkException implements Exception {
  final String message;
  final String? code;

  const NetworkException({required this.message, this.code});

  @override
  String toString() => message;
}

class ValidationException implements Exception {
  final String message;
  final String? code;

  const ValidationException({required this.message, this.code});

  @override
  String toString() => message;
}

class CacheException implements Exception {
  final String message;
  final String? code;

  const CacheException({required this.message, this.code});

  @override
  String toString() => message;
}
