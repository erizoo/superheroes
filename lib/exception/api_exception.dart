class ApiException implements Exception {
  final String message;

  ApiException(this.message) {
    print(message);
  }

  static ApiException get(final int statusCode) {
    if (statusCode >= 400 && statusCode <= 499 || statusCode == 200) {
      return ApiException("Client error happened");
    } else if (statusCode >= 500 && statusCode <= 599) {
      return ApiException("Server error happened");
    }
    return ApiException("Unknow error happened");
  }

  @override
  String toString() => 'ApiException(message: $message)';
}
