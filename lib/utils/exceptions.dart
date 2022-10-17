class ApiException implements Exception {
  String errorMessage;

  ApiException(this.errorMessage);

  @override
  String toString() {
    return errorMessage;
  }
}

class NetworkException implements Exception {
  String errorMessage;

  NetworkException(this.errorMessage);

  @override
  String toString() {
    return errorMessage;
  }
}
