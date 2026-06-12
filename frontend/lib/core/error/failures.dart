abstract class Failure {
  final String message;
  const Failure(this.message);
}

class LocalFailure extends Failure {
  const LocalFailure(super.message);
}

class ApiFailure extends Failure {
  final int? statusCode;
  const ApiFailure(super.message, {this.statusCode});
}
