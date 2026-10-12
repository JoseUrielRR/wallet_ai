abstract class Failure {
  final String message;
  final String? code;

  const Failure(this.message, {this.code});

  @override
  String toString() => '$runtimeType(message: $message, code: $code)';
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Ocurrió un error en el servidor.', String? code])
      : super(code: code);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Error de autenticación.', String? code])
      : super(code: code);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No hay conexión a internet disponible.', String? code])
      : super(code: code);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Error de almacenamiento local.', String? code])
      : super(code: code);
}

class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Los datos proporcionados no son válidos.', String? code])
      : super(code: code);
}
