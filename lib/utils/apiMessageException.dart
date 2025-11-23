class ApiMessageException implements Exception {
  final String errorMessage;

  ApiMessageException({required this.errorMessage});

  @override
  String toString() => errorMessage;
}
