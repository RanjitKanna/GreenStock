abstract class Failure {
  const Failure(this.message);
  final String message;
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Network error. Please check your connection.']);
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error. Please try again later.']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Local storage error.']);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Data not found.']);
}
