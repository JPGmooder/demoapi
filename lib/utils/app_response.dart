import 'package:backend/models/service/response_model.dart';
import 'package:conduit/conduit.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';

class AppResponse extends Response {
  AppResponse.ok({dynamic body, String? message})
      : super.ok(CustomResponseModel(data: body, message: message));
  AppResponse.serverError(dynamic error, String message)
      : super.serverError(body: _getResponseModel(error, message: message));

  static CustomResponseModel _getResponseModel(_error, {String? message}) {
    if (_error is QueryException || _error is JwtException) {
      return CustomResponseModel(
          error: _error.toString(), message: message ?? _error.message);
    }
    return CustomResponseModel(
        error: _error.toString(), message: message ?? "Неизвестная ошибка");
  }
}
