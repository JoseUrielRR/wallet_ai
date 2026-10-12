class AppException implements Exception {
  final String message;
  final String? code;

  const AppException(this.message, [this.code]);

  @override
  String toString() => '$runtimeType: $message (code: $code)';
}

class ServerException extends AppException {
  const ServerException([super.message = 'Error en el servidor remoto', super.code]);
}

class AuthException extends AppException {
  const AuthException([super.message = 'Error de autenticación', super.code]);
}

class CacheException extends AppException {
  const CacheException([super.message = 'Error de almacenamiento local', super.code]);
}
