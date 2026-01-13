class StatusCode {
  static const int success = 200;
  static const int successCreated = 201;
  static const int successButNoContent = 204;

  static const int badRequest = 400;
  static const int errorRequest = 422;
  static const int unauthorized = 401;
  static const int forbidden = 403;
  static const int notFound = 404;
  static const int conflict = 409;
  static const int internalServerError = 500;
  static const int serverDownError = 503;
}
