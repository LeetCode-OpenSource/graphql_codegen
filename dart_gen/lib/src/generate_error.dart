class DartCodeGenerateError extends Error {
  DartCodeGenerateError(this.message) : super();

  final String message;
}
